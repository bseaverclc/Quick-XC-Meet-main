//
//  ViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/24/22.
//

//2.1 on App Store with private meet capabilities


import UIKit
import FirebaseAuth
import Firebase


class AppData{
    static var meets = [Meet]()
    static var allAthletes = [Athlete]()
    //static var schools = [String:String]()
    static var userID = ""
    static var coach = ""
    static var manager = ""
    static var schoolsNew = [School]()
    static var mySchool = ""
    static var fullAccess = false
    static var connected = true
    
}


class ViewController: UIViewController {
    

    @IBOutlet weak var nameOutlet: UILabel!
    
    @IBOutlet weak var logInOutlet: UIButton!
    
    @IBOutlet weak var logOutOutlet: UIButton!
    
    @IBOutlet weak var removeAccountOutlet: UIButton!
    
    @IBOutlet weak var meetsOutlet: UIButton!
    
    @IBOutlet weak var schoolsOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
            print("Connected")
             
              self.navigationController?.navigationBar.backgroundColor = UIColor.white
             
          } else {
            print("Not connected")
              self.navigationController?.navigationBar.backgroundColor = UIColor.systemPink
             
          
             
          }
        })
        
        didSignIn()
        getSchoolsFromFirebase()
       // getAthletesFromFirebase()
        getMeetsFromFirebase()
        //athleteChangedInFirebase2()
        //athleteDeletedInFirebase()
        
        meetsOutlet.layer.cornerRadius = 10
        schoolsOutlet.layer.cornerRadius = 10
        logInOutlet.layer.cornerRadius = 10
        logOutOutlet.layer.cornerRadius = 10
        
       
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        if let user = Auth.auth().currentUser{
            AppData.userID = user.uid
            for school in AppData.schoolsNew{
                for coach in school.coaches{
                    if coach == user.email!{
                        AppData.mySchool = school.full
                        AppData.coach = coach
                        print("my school is \(AppData.mySchool)")
                    }
                }
            }
        }
        if(AppData.userID == "UeneL2Wo2WWNRufYo95UC3hqae42"){
            AppData.fullAccess = true
        }
        else{AppData.fullAccess = false}
    }

    @IBAction func createAccountAction(_ sender: UIButton) {
        
            print("email button hit")
            let alert = UIAlertController(title: "Enter Info", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
               // textField.autocapitalizationType = .allCharacters
                   textField.placeholder = "email"
            })
            alert.addTextField(configurationHandler: { (textField) in
               // textField.autocapitalizationType = .allCharacters
                   textField.placeholder = "password"
            })
            
            alert.addAction(UIAlertAction(title: "create account", style: .default, handler: { (updateAction) in
                
                let email = alert.textFields![0].text!
                let password = alert.textFields![1].text!
                if !self.isEmail(em: email){
                    let emailAlert = UIAlertController(title: "Error", message: "Not a valid email", preferredStyle: .alert)
                    emailAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(emailAlert, animated: true, completion: nil)
                }
                else if password.count < 6{
                    let passwordAlert = UIAlertController(title: "Error", message: "password not long enough", preferredStyle: .alert)
                    passwordAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(passwordAlert, animated: true, completion: nil)
                }
                else{
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let e = error{
                            let errorAlert = UIAlertController(title: "Error", message: "\(e)", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(errorAlert, animated: true, completion: nil)
                        }
                        else{
                            self.didSignIn()
                        }
                    }
                }
        }))
            
            alert.addAction(UIAlertAction(title: "login", style: .default, handler: { (updateAction) in
                
                let email = alert.textFields![0].text!
                let password = alert.textFields![1].text!
                if !self.isEmail(em: email){
                    let emailAlert = UIAlertController(title: "Error", message: "Not a valid email", preferredStyle: .alert)
                    emailAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(emailAlert, animated: true, completion: nil)
                }
                else if password.count < 6{
                    let passwordAlert = UIAlertController(title: "Error", message: "password not long enough", preferredStyle: .alert)
                    passwordAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(passwordAlert, animated: true, completion: nil)
                }
                else{
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                      guard let strongSelf = self else { return }
                        if let e = error{
                            let errorAlert = UIAlertController(title: "Error", message: "\(e)", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            strongSelf.present(errorAlert, animated: true, completion: nil)
                        }
                        else{
                            strongSelf.didSignIn()
                        }
                      
                    }
                }
        }))
            alert.addAction(UIAlertAction(title: "forgot password", style: .default, handler: { (action) in
                self.resetPassword()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)

    }
    
    func isEmail(em: String)-> Bool{
                    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
                    return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: em)
        
    }
    
    func resetPassword(){
        let alert = UIAlertController(title: "reset password", message: "enter email address", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "email address"
        }
        alert.addAction((UIAlertAction(title: "send reset email", style: .default, handler: { (action) in
            Auth.auth().sendPasswordReset(withEmail: alert.textFields![0].text!) { error in
                var message = ""
                if let error = error{
                    message = "\(error)"
                }
                else{
                    message = "password reset email has been sent"
                }
                let confirm = UIAlertController(title: message, message: "", preferredStyle: .alert)
                confirm.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(confirm, animated: true, completion: nil)
            }
        })))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func didSignIn(){
        print("didSignIn being called")
        //if let blah = GID
        if let user = Auth.auth().currentUser{
            print("AppData.userID \(AppData.userID)")
            AppData.userID = user.uid
            print("AppData.schoolsNew count \(AppData.schoolsNew.count)")
            for school in AppData.schoolsNew{
                for coach in school.coaches{
                    if coach == user.email!{
                        AppData.mySchool = school.full
                        AppData.coach = coach
                        print("my school is \(AppData.mySchool)")
                    }
                }
            }
           
            nameOutlet.text = "\(user.email!)"
            logInOutlet.isHidden = true
            logOutOutlet.isHidden = false
            removeAccountOutlet.isHidden = false
            //authorizationButton.isHidden = true
            //emailButtonOutlet.isHidden = true
        }
       else{
            nameOutlet.text = "Not Logged in"
        logInOutlet.isHidden = false
        logOutOutlet.isHidden = true
        removeAccountOutlet.isHidden = true
        //authorizationButton.isHidden = false
        //emailButtonOutlet.isHidden = false
       }
    }
    
    
    @IBAction func logOutAction(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
      do {
        try firebaseAuth.signOut()
        AppData.userID = ""
      } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
      }
        
        //if let blah = GID
        if let user = Auth.auth().currentUser{
            AppData.userID = user.uid
           
            nameOutlet.text = "Welcome \(user.displayName!)"
            logInOutlet.isHidden = true
            logOutOutlet.isHidden = false
            removeAccountOutlet.isHidden = false
            //authorizationButton.isHidden = true
           // emailButtonOutlet.isHidden = true
        }
       else{
            nameOutlet.text = "Not Logged in"
        logInOutlet.isHidden = false
        logOutOutlet.isHidden = true
        removeAccountOutlet.isHidden = true
       // authorizationButton.isHidden = false
       // emailButtonOutlet.isHidden = false
        AppData.mySchool = ""
        AppData.coach = ""
       }
        
    }
  
    
    @IBAction func deleteAccountAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure?", message: "This will permanently this account from the app", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { (action) in
            self.deleteAccount()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAccount(){
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
            print(error)
          } else {
            self.nameOutlet.text = "Not Logged in"
            self.logInOutlet.isHidden = false
            self.logOutOutlet.isHidden = true
            self.removeAccountOutlet.isHidden = true
            //self.authorizationButton.isHidden = false
            //self.emailButtonOutlet.isHidden = false
          }
        }
    }
    
    func getSchoolsFromFirebase(){
//        var ref: DatabaseReference!
//
//        ref = Database.database().reference()
//        ref.child("schools").observe(.childAdded, with: { (snapshot) in
//            Data.schools = snapshot.value as! [String:String]
//        })
        
        // works if a school is there already
//        ref.child("schools").observeSingleEvent(of: .value, with: { (snapshot) in
//            Data.schools = snapshot.value as! [String:String]
//            print("got schools from firebase \(Data.schools)")
//        })
        
        let ref2 = Database.database().reference()
        ref2.child("schoolsNew").observe(.childAdded, with: { (snapshot) in

            let dict = snapshot.value as! [String:Any]
            let s = School(key: snapshot.key, dict: dict)
            if AppData.schoolsNew.contains(where: {$0.uid == s.uid}){
                print("school already in AppData.schoolsNew")
            }
            else{
            AppData.schoolsNew.append(s)
            }
            
            print("added a schoolsNew \(s.full)")
        })
        
        ref2.child("schoolsNew").observe(.childChanged, with: { (snapshot) in
            print("heard a school change")
            let uid = snapshot.key
            let dict = snapshot.value as! [String:Any]

            let school = School(key: snapshot.key, dict: dict)

          for i in 0..<AppData.schoolsNew.count{
                if(AppData.schoolsNew[i].uid == uid){
                   AppData.schoolsNew[i] = school
                   // print("SchoolNew \(i) Changed \(AppData.schoolsNew[i].full)")
                    NotificationCenter.default.post(name: Notification.Name("notifyAthleteChanged"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
                    break
                }
                }
            
//            ref2.child("schoolsNew").child(uid).child("athletes").observe(.childAdded) { snapshot3 in
//                let dict2 = snapshot3.value as! [String:Any]
//                var a = Athlete(key: snapshot3.key, dict: dict2)
//                var added = false
//                for s in AppData.schoolsNew{
//                    if s.full == a.schoolFull{
//                        AppData.allAthletes.append(a)
//                        added = true
//                        print("heard adding an athlete")
//                        NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
//                        return
//                    }
//                }
//
//
//
//            }
          
            
//            ref2.child("schoolsNew").child(uid).child("athletes").observe(.childChanged) { snapshot2 in
//                print("heard athlete changed")
//                let dict2 = snapshot2.value as! [String:Any]
//                var a = Athlete(key: snapshot2.key, dict: dict2)
//                var changed = false
//                for i in 0..<AppData.allAthletes.count{
//                    if AppData.allAthletes[i].uid == a.uid{
//                        AppData.allAthletes[i] = a
//                        changed = true
//                        NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
//                        return
//                    }
//                }
////                if !changed{
////                    AppData.allAthletes.append(a)
////                    NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
////                }
//
//
//            }

        })
        
        ref2.child("schoolsNew").observe(.childRemoved) { (snapshot) in
            print("a school has been removed from firebase")
            let key = snapshot.key
            AppData.schoolsNew.removeAll(where: {$0.uid == key})
            
        }
        
        
       
    }
    
    func getMeetsFromFirebase(){
        var ref: DatabaseReference!

        ref = Database.database().reference()
        ref.child("meets").observe(.childAdded, with: { (snapshot) in
            
            let dict = snapshot.value as! [String:Any]
            AppData.meets.append(Meet(key: snapshot.key, dict: dict))
        })
        
        ref.child("meets").observe(.childChanged, with: { (snapshot) in
            
            let dict = snapshot.value as! [String:Any]
            var m = Meet(key: snapshot.key, dict: dict)
            for i in 0..<AppData.meets.count{
                if AppData.meets[i].name == m.name{
                    AppData.meets[i] = m;
                    NotificationCenter.default.post(name: Notification.Name("notifyMeetChanged"), object: nil)
                    print("updated meet")
                    break;
                }
            }
            
            
        })
        
        
        
//        ref.child("meets").observe(.childRemoved, with: { (snapshot) in
//            let dict = snapshot.value as! [String:Any]
//            for i in 0..<Data.meets.count{
//                if let n = dict["name"] as? String{
//                    if Data.meets[i].name == n{
//                        Data.meets.remove(at: i)
//                        break
//
//                    }
//                }
//            }
//        })
       
    }
    
    
    // This function is not used.  Everything is done in getSchoolsFromFirebase
    func getAthletesFromFirebase(){
        var ref: DatabaseReference!
        var handle1 : UInt! // These did not work!
        var handle2 : UInt!  // These did not work!

        ref = Database.database().reference()
        
        handle1 = ref.child("athletes").observe(.childAdded) { (snapshot) in
            print("observe athlete .childAdded observed")
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error")
                return
            }
            
            var addAth = true
            let a = Athlete(key: uid, dict: dict)
            for ath in AppData.allAthletes{
                if ath.uid == a.uid{
                    addAth = false
                }
            }
           
            
            handle2 = ref.child("athletes").child(uid).child("races").observe(.childAdded) { (snapshot2) in
                print("observe races .childAdded from athletes .childAdded")
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
//                print("printing events")
//                print(dict2)
                var add = true
//                for e in a.races{
//                    if dict2["name"] as! String == e.name && dict2["meetName"] as! String == e.meetName{
//                        add = false
//                    }
//                }
                if add{
               a.addRace(key: snapshot2.key, dict: dict2)
                print("Added Race in firebase")
                    for i in 0..<AppData.allAthletes.count{
                        if(AppData.allAthletes[i].uid == uid){
                            AppData.allAthletes[i] = a
                            NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
                        }
                    
                            
                        }
                    
                //print("\(a.first) \(a.events[a.events.count-1].name)")
                }
                
            }
            
            if addAth{
            AppData.allAthletes.append(a)
                print("Added an athlete \(a.last) to AppData from firebase listener")
                
            //print("Added Athlete to allAthletes \(AppData.allAthletes[Data.allAthletes.count-1].first) ")
            }
           // ref.removeObserver(withHandle: handle2)
            //print("removing handle2")
               }
        
        //ref.removeObserver(withHandle: handle1)
        //print("removing handle1")
        
       // ref.removeAllObservers()
    }
    
    
    // This function is not used.  Everything is done in getSchoolsFromFirebase
    func athleteChangedInFirebase2(){
        var ref: DatabaseReference!

        ref = Database.database().reference()
        
        ref.child("athletes").observe(.childChanged) { (snapshot) in
            print("observe athlete .childChanged")
            print(snapshot)
            let uid = snapshot.key
            //print(uid)
           
            guard let dict = snapshot.value as? [String:Any]
            else{ print("Error in observe child Changed")
                return
            }
            
            
            var a : Athlete!
            for i in 0 ..< AppData.allAthletes.count{
                if(AppData.allAthletes[i].uid == uid){
                    a = AppData.allAthletes[i]
                }
            }
           
            ref.child("athletes").child(uid).child("races").observe(.childRemoved, with: { (snapshot2) in
                print("observe race .childRemoved")
                for i in 0 ..< a.races.count{
                    if a.races[i].uid == snapshot2.key{
                        a.races.remove(at: i)
                        print("found race to remove")
                        NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
                    }
                }
            })
            
            
            ref.child("athletes").child(uid).child("races").observe(.childAdded, with: { (snapshot2) in
                print("observe races .childAdded from athletes .childChanged")
                print(snapshot2)
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
                
                for i in 0 ..< a.races.count{
                    if a.races[i].uid == snapshot2.key{
                        a.races[i] = Race(key: snapshot2.key, dict: dict2)
                        print("found race to change")
                        NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
                    }
                }
                

            })
        
            ref.child("athletes").child(uid).child("races").observe(.childChanged) { (snapshot2) in
                print("observe race .childChanged")
                
                guard let dict2 = snapshot2.value as? [String:Any]
                else{ print("Error")
                    return
                }
                
                for i in 0 ..< a.races.count{
                    if a.races[i].uid == snapshot2.key{
                        a.races[i] = Race(key: snapshot2.key, dict: dict2)
                        print("found race to change")
                        NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
                    }
                }
                
            }
            
//            ref.child("athletes").child(uid).child("races").observe(.childChanged, with: { (snapshot2) in
//                print("observe race .childChanged")
//
//                guard let dict2 = snapshot2.value as? [String:Any]
//                else{ print("Error")
//                    return
//                }
//
//                for i in 0 ..< a.races.count{
//                    if a.races[i].uid == snapshot2.key{
//                        a.races[i] = Race(key: snapshot2.key, dict: dict2)
//                        NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
//                    }
//                }
//
//
//
//            })
        
        
            
        }
          
                
//                print("printing events")
//                print(dict2)
                
    }
    
    // This function is not used.  Everything is done in getSchoolsFromFirebase
    func athleteDeletedInFirebase(){
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        ref.child("athletes").observe(.childRemoved, with: { (snapshot) in
            print("observe athletes .childRemoved")
            for i in 0..<AppData.allAthletes.count{
                
                if AppData.allAthletes[i].uid == snapshot.key{
                    print("\(AppData.allAthletes[i].last) has been removed")
                    AppData.allAthletes.remove(at: i)
                    NotificationCenter.default.post(name: Notification.Name("notifyScreenChange"), object: nil)
                   
                    break
                }
            }
            
        })
    }
    
//    func readCSVURL(csvURL: String, fullSchool: String, initSchool: String){
//            var urlCut = csvURL
//            if csvURL != ""{
//                if let editRange = csvURL.range(of: "/edit"){
//                let start = editRange.lowerBound
//                urlCut = String(csvURL[csvURL.startIndex..<start])
//                }
//                let urlcompleted = urlCut + "/pub?output=csv"
//                let url = URL(string: String(urlcompleted))
//                print(url ?? "URL Reading Didn't work")
//                
//                     guard let requestUrl = url else {
//                        //fatalError()
//                        print("fatal error")
//                        return
//                }
//                     // Create URL Request
//                     var request = URLRequest(url: requestUrl)
//                     // Specify HTTP Method to use
//                     request.httpMethod = "GET"
//                
//                     // Send HTTP Request
//                     let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                       
//                         // Check if Error took place
//                         if let error = error {
//                             print("Error took place \(error)")
//    //                        let alert = UIAlertController(title: "Error!", message: "Could not load athletes", preferredStyle: .alert)
//    //                        let ok = UIAlertAction(title: "ok", style: .default)
//    //                        alert.addAction(ok)
//    //                        self.present(alert, animated: true, completion: nil)
//                            //self.showAlert(errorMessage: "Error loading Athletes from file")
//                             
//                         }
//                         
//                         // Read HTTP Response Status code
//                         if let response = response as? HTTPURLResponse {
//                             print("Response HTTP Status code: \(response.statusCode)")
//                           
//                            //return
//                         }
//                         
//                         
//                         // Convert HTTP Response Data to a simple String
//                         if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                             print("Response data string:\n \(dataString)")
//                             let rows = dataString.components(separatedBy: "\r\n")
//                             for row in rows{
//                                
//                                let person = [String](row.components(separatedBy: ","))
//                                if person[0] != "First"{
//                                    let athlete = Athlete(f: person[0], l: person[1], s: initSchool, g: Int(person[2])!, sf: fullSchool)
//                                print(athlete)
//                                    AppData.allAthletes.append(athlete)
//                                }
//                                 
//                             }
//                         }
//                         
//                            
//                         
//
//                        
//                     }
//                     task.resume()
//            
//        }
//        
//        
//    }
}
    


