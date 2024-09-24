//
//  AthletesTableViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit
import Firebase

class AthletesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var blankLabel1: UILabel!
    
    @IBOutlet weak var blankLabel2: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var coachesButtonOutlet: UIButton!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genderSegOutlet: UISegmentedControl!
    
    @IBOutlet weak var advanceGradesOutlet: UIButton!
    
  //  weak var delegate: DataBackDelegate?
   
    
    var canEditAthletes = false
    var header = ""
    var screenTitle = "Roster"
    //var allAthletes = [Athlete]()
    var eventAthletes = [Athlete]()
    var displayedAthletes = [Athlete]()
    var selectedAthlete : Athlete!
    //var schools = [School]()
    var school : School!
    //var meet : Meet?
    var pvcScreenTitle = ""
    var selectedTab = -1
   // var meets : [Meet]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let ref = Database.database().reference().child("athletes")
 
        self.title = "\(school.inits) Roster"
       // displayedAthletes = AppData.allAthletes
        AppData.allAthletes.removeAll()
      
        // Changing a school name
//        if school.full == "85 BEARSS"{
//            school.full = "85 BEARS"
//            school.inits = "85B"
//            // updates school and athletes in the school
//            school.updateFirebase()
//        }
       
        for a in school.athletes{
//            if a.schoolFull == "ST. THOMAS MORE SCHOOL"{
//                a.schoolFull = "ST THOMAS MORE SCHOOL"
//            }
            
            AppData.allAthletes.append(a)
        }
        
        checkEditAthletes()
        
        if !canEditAthletes{
            uploadButtonOutlet.isHidden = true
            advanceGradesOutlet.isHidden = true
            blankLabel1.isHidden = false
            blankLabel2.isHidden = false
        }
        if !AppData.fullAccess{
            uploadButtonOutlet.isHidden = true
            blankLabel1.isHidden = false
        }

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewDidAppear")
        
        
      
        displayedAthletes.removeAll()
  
        switch genderSegOutlet.selectedSegmentIndex{
        case 0:
            displayAllAthletes()
        case 1:
            filterByWomen()
        case 2: 
            filterByMen()
        default:
            filterByArchived()
        }
       
        
    }
    
    func displayAllAthletes(){
        displayedAthletes.removeAll()
        for a in AppData.allAthletes{
            print("\(school.full) athlete school \(a.schoolFull)")
            if school.full == a.schoolFull && a.last != "??" && a.archived == false{
                displayedAthletes.append(a)
            }
        }
        sortByName()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view disappearing")
//        if isMovingFromParent{
//            if let del = self.delegate{
//        del.savePreferences(athletes: AppData.allAthletes)
//            }
//            else{
//                performSegue(withIdentifier: "unwindtoSchoolsSegue", sender: nil)
//            }
//            print("is moving from parent")
//        }
    }
    
    func sortByName(){
        displayedAthletes = displayedAthletes.sorted { (lhs, rhs) in
//            if lhs.school == rhs.school { // <1>
//                return lhs.last < rhs.last
//            }
            
            return lhs.last < rhs.last // <2>
        }
    }
    
    func checkEditAthletes(){
        if(AppData.userID == "UeneL2Wo2WWNRufYo95UC3hqae42")
        {
            canEditAthletes = true
            return
        }
        
      
        
        if let cu = Auth.auth().currentUser?.email{
            for e in school.coaches{
                print("printing coaches email \(e)")
   
                if cu == e{
                    
                    canEditAthletes = true
                    return
                }
            }
        }
            
        
        canEditAthletes = false
        print("You are not a valid coach for this team or a Meet Manager")
    }
    
    @IBAction func addAthleteAction(_ sender: UIBarButtonItem) {
        
        if canEditAthletes{
            performSegue(withIdentifier: "toAddAthleteSegue", sender: self)
        }
        else{
            let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to add athletes", preferredStyle: .alert)
            denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(denyAlert, animated: true, completion: nil)
            
        }
        
//        if let m = meet{
//
//            if Meet.canManage || Meet.canCoach{
//                performSegue(withIdentifier: "toAddAthleteSegue", sender: self)
//                return
//            }
//
//        }
//        for s in AppData.schoolsNew{
//            if s.full == schools[0]{
//            for e in s.coaches{
//                if Auth.auth().currentUser?.email == e{
//                    performSegue(withIdentifier: "toAddAthleteSegue", sender: self)
//                    return
//                }
//            }
//            }
//        }
//        print("You are not a valid coach for this team or a Meet Manager")
        
        
    }
    
   

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return displayedAthletes.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        
        let athlete = displayedAthletes[indexPath.row]
       
        
        cell.textLabel?.text = "\(athlete.last), \(athlete.first) (\(athlete.grade))"
         cell.detailTextLabel?.text = "\(athlete.school) (\(athlete.gender))"
       
        //print(athlete.grade)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if let user = Auth.auth().currentUser{
        let sf = displayedAthletes[indexPath.row].schoolFull
        for s in AppData.schoolsNew{
            if s.full == sf{
                for coach in s.coaches{
                    
                    if user.email == coach{
                        return true
                    }
                }
            }
        }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if self.canEditAthletes{
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                if !self.canEditAthletes{
                    let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to delete athletes", preferredStyle: .alert)
                    denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(denyAlert, animated: true, completion: nil)
                    
                }
                if !self.canEditAthletes{
                    return
                }
                
                
                
                let alert = UIAlertController(title: "Are you sure?", message: "Deleting this athlete will also delete any results stored for this athlete", preferredStyle:    .alert)
                let ok = UIAlertAction(title: "Delete", style: .destructive) { (a) in
                    let selected = self.displayedAthletes[indexPath.row]
                    AppData.allAthletes.removeAll { (athlete) -> Bool in
                        athlete.equals(other: selected)
                        
                    }
                    selected.deleteFromFirebase()
                    self.displayedAthletes.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(cancel)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
                
                if !self.canEditAthletes{
                    let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to edit athletes", preferredStyle: .alert)
                    denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(denyAlert, animated: true, completion: nil)
                    
                }
                if !self.canEditAthletes{
                    return
                }
                
                let alert = UIAlertController(title: "", message: "Edit Athlete", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.autocapitalizationType = .allCharacters
                    textField.text = self.displayedAthletes[indexPath.row].first
                    
                })
                alert.addTextField(configurationHandler: { (textField) in
                    textField.autocapitalizationType = .allCharacters
                    textField.text = self.displayedAthletes[indexPath.row].last
                    
                })
                //            alert.addTextField(configurationHandler: { (textField) in
                //                textField.autocapitalizationType = .allCharacters
                //                textField.text = self.displayedAthletes[indexPath.row].school
                //
                //            })
                alert.addTextField(configurationHandler: { (textField) in
                    textField.keyboardType = UIKeyboardType.numberPad
                    textField.autocapitalizationType = .allCharacters
                    textField.text = "\(self.displayedAthletes[indexPath.row].grade)"
                    
                })
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                    
                    if !self.canEditAthletes{
                        let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to edit athletes", preferredStyle: .alert)
                        denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(denyAlert, animated: true, completion: nil)
                        return
                    }
                    
                    self.displayedAthletes[indexPath.row].first = alert.textFields![0].text!
                    self.displayedAthletes[indexPath.row].last = alert.textFields![1].text!
                    //self.displayedAthletes[indexPath.row].school = alert.textFields![2].text!
                    if let grade = Int(alert.textFields![2].text!){
                        self.displayedAthletes[indexPath.row].grade = grade}
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    for i in 0 ..< AppData.allAthletes.count{
                        if self.displayedAthletes[indexPath.row].equals(other: AppData.allAthletes[i]){
                            AppData.allAthletes[i].first = alert.textFields![0].text!
                            AppData.allAthletes[i].last = alert.textFields![1].text!
                            // AppData.allAthletes[i].school = alert.textFields![2].text!
                            if let grade = Int(alert.textFields![2].text!){
                                AppData.allAthletes[i].grade = grade}
                            
                            // updateFirebase
                            print(AppData.allAthletes[i].first)
                            AppData.allAthletes[i].updateFirebaseAthleteInfo()
                            
                            
                            // save changes to userDefaults
                            //                        let userDefaults = UserDefaults.standard
                            //                        do {
                            //
                            //                            try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                            //                               } catch {
                            //                                   print(error.localizedDescription)
                            //                               }
                            break
                        }
                    }
                    
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: false)
            }
            
            let archive = UITableViewRowAction(style: .normal, title: "Archive") { (action, indexPath) in
                for i in 0 ..< AppData.allAthletes.count{
                    if self.displayedAthletes[indexPath.row].equals(other: AppData.allAthletes[i]){
                        
                        AppData.allAthletes[i].archived = true
                        AppData.allAthletes[i].updateFirebaseAthleteInfo()
                        self.displayedAthletes.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        break
                    }
                }
            }
            
            let unarchive = UITableViewRowAction(style: .normal, title: "Unarchive") { (action, indexPath) in
                for i in 0 ..< AppData.allAthletes.count{
                    if self.displayedAthletes[indexPath.row].equals(other: AppData.allAthletes[i]){
                        
                        AppData.allAthletes[i].archived = false
                        AppData.allAthletes[i].updateFirebaseAthleteInfo()
                        self.displayedAthletes.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        break
                    }
                }
            }
            
            
            
            edit.backgroundColor = UIColor.blue
            
            return [delete, edit, archive, unarchive]
        }
        else{
            return[]
        }
    }
        
    
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedAthlete = displayedAthletes[indexPath.row]
            performSegue(withIdentifier: "athleteResultsSegue", sender: self)
        }
        
        
        //     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //
        //        if editingStyle == .delete{
        //
        //            var selected = displayedAthletes[indexPath.row]
        //            for i in 0 ..< allAthletes.count{
        //                if selected.equals(other: allAthletes[i]){
        //                    allAthletes.remove(at: i)
        //                    break
        //                }
        //            }
        //            displayedAthletes.remove(at: indexPath.row)
        //                   tableView.deleteRows(at: [indexPath], with: .fade)
        //        }
        //    }
        
        //     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        var selectedAthlete = displayedAthletes[indexPath.row]
        //        selectedAthlete.events.append(Event(name: self.title!, level: "varsity"))
        //        eventAthletes.append(selectedAthlete)
        //        performSegue(withIdentifier: "backToEventSegue", sender: nil)
        //    }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            
            
            if segue.identifier == "toAddAthleteSegue"{
                
                
                
                let nvc = segue.destination as! AddAthleteViewController
                nvc.displayedAthletes = displayedAthletes
                nvc.school = school
                // nvc.allAthletes = allAthletes
                
                
            }
            else if segue.identifier == "toCoachesSegue"{
                let nvc = segue.destination as! CoachesVC
                nvc.school = school
                nvc.canEditAthletes = canEditAthletes
                
            }
            else if segue.identifier == "athleteResultsSegue"{
                let nvc = segue.destination as! AthleteResultsViewController
                nvc.athlete = selectedAthlete
            }
        }
        
        
        @IBAction func unwind( _ seg: UIStoryboardSegue) {
            let pvc = seg.source as! AddAthleteViewController
            // allAthletes = pvc.allAthletes
            displayedAthletes = pvc.displayedAthletes
            
            sortByName()
            tableView.reloadData()
            print("unwinding")
            
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return header
        }
        
        func displayRosterAlert(error: String){
            let rosterAlert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            rosterAlert.addAction(okAction)
            self.present(rosterAlert, animated: true, completion: nil)
        }
        
        
        func readCSVURLNew(csvURL: String, fullSchool: String, initSchool: String) -> String{
            var err = ""
            
            var urlCut = csvURL
            if csvURL != ""{
                if let editRange = csvURL.range(of: "/edit"){
                    let start = editRange.lowerBound
                    urlCut = String(csvURL[csvURL.startIndex..<start])
                }
                else{
                    
                    return "Must have /edit in URL"
                }
                let urlcompleted = urlCut + "/pub?output=csv"
                let url = URL(string: String(urlcompleted))
                print(url ?? "Error reading URL")
                
                guard let requestUrl = url else {
                    //fatalError()
                    print("fatal error")
                    
                    return "Error reading URL"
                }
                // Create URL Request
                var request = URLRequest(url: requestUrl)
                // Specify HTTP Method to use
                request.httpMethod = "GET"
                
                // Send HTTP Request
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    
                    // Check if Error took place
                    if let error = error {
                        print("Error took place \(error)")
                        err = "\(error)"
                        
                        
                        
                        
                        //                        let alert = UIAlertController(title: "Error!", message: "Could not load athletes", preferredStyle: .alert)
                        //                        let ok = UIAlertAction(title: "ok", style: .default)
                        //                        alert.addAction(ok)
                        //                        self.present(alert, animated: true, completion: nil)
                        //self.showAlert(errorMessage: "Error loading Athletes from file")
                        
                    }
                    
                    // Read HTTP Response Status code
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                        if response.statusCode == 400{
                            err = "can't read roster"
                        }
                    }
                    
                    
                    
                    
                    
                    // Convert HTTP Response Data to a simple String
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print("Response data string:\n \(dataString)")
                        let rows = dataString.components(separatedBy: "\r\n")
                        print(rows.count)
                        if rows.count == 1{
                            err = "can't read roster"
                            print(err)
                            
                        }
                        else{
                            for row in rows{
                                
                                var person = [String](row.components(separatedBy: ","))
                                if person.count != 4{
                                    
                                    continue
                                }
                                for i in 0..<person.count{
                                    person[i] = person[i].uppercased()
                                }
                                if person[0] != "FIRST"{
                                    print("\(person[0])  \(person[1])   \(person[2]) \(person[3])")
                                    
                                    let athlete = Athlete(f: person[0], l: person[1], s: initSchool, g: Int(person[2]) ?? 0, sf: fullSchool, gen: person[3])
                                    print(athlete)
                                    var found = false
                                    for a in self.displayedAthletes{
                                        if athlete.equals(other: a){
                                            found = true
                                            break
                                        }
                                    }
                                    if !found{
                                        athlete.saveToFirebase()
                                        AppData.allAthletes.append(athlete)
                                        self.displayedAthletes.append(athlete)
                                        
                                    }
                                    
                                }
                            }
                            DispatchQueue.main.async {
                                self.sortByName()
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                    else{
                        err = "error with url"
                    }
                    
                    
                    
                    
                    
                    
                }
                task.resume()
                
                
            }
            
            
            return err
            
        }
        
        
        @IBAction func uploadAction(_ sender: UIButton) {
            
            
            if(!canEditAthletes)
            {
                let denyAlert = UIAlertController(title: "Error", message: "You are not authorized to upload a roster", preferredStyle: .alert)
                denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(denyAlert, animated: true, completion: nil)
            }
            else{
                
                let alert = UIAlertController(title: "upload Roster", message: "copy and paste url", preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: { (textField) in
                    
                    textField.placeholder = "Roster csv url"
                })
                
                alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
                    var badInput = false
                    var error = ""
                    
                    let csvURL = alert.textFields![0].text!
                    
                    
                    if !badInput{
                        if csvURL != ""{
                            
                            error =  self.readCSVURLNew(csvURL: csvURL, fullSchool: self.school.full, initSchool: self.school.inits)
                            if error != ""{
                                //self.displayRosterAlert(error: e)
                                badInput = true
                            }
                            
                        }
                        else{badInput = true
                            error = "can't leave url blank"
                        }
                        
                        
                        
                    }
                    //}
                    if badInput{
                        self.displayRosterAlert(error: error)
                        //                   let alert2 = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        //                   let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        //                   alert2.addAction(okAction)
                        //                   self.present(alert2, animated: true, completion: nil)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
        
        
        @IBAction func genderSegAction(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex{
            case 0:
                displayAllAthletes()
            case 1:
                filterByWomen()
            case 2:
                filterByMen()
            default:
                filterByArchived()
            }
            
        }
        
        func filterByArchived(){
            displayedAthletes.removeAll()
            for a in AppData.allAthletes{
                print("\(school.full) athlete school \(a.schoolFull)")
                if school.full == a.schoolFull && a.last != "??" && a.archived == true{
                    displayedAthletes.append(a)
                }
            }
            sortByName()
            tableView.reloadData()
        }
        
        func filterByMen(){
            displayedAthletes.removeAll()
            for a in AppData.allAthletes{
                print("\(school.full) athlete school \(a.schoolFull)")
                if school.full == a.schoolFull && a.last != "??" && a.gender == "M" && a.archived == false{
                    displayedAthletes.append(a)
                }
            }
            sortByName()
            tableView.reloadData()
            
        }
        
        func filterByWomen(){
            displayedAthletes.removeAll()
            for a in AppData.allAthletes{
                print("\(school.full) athlete school \(a.schoolFull)")
                if school.full == a.schoolFull && a.last != "??" && a.gender == "F" && a.archived == false{
                    displayedAthletes.append(a)
                }
            }
            sortByName()
            tableView.reloadData()
            
        }
        
        
        @IBAction func advanceGradesAction(_ sender: UIButton) {
            let alert = UIAlertController(title: "Are you sure?", message: "This will add 1 to the grade of each athlete of this school.  Do this only once a year if needed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Advance", style: .default, handler: { alert in
                for a in self.school.athletes{
                    a.grade = a.grade + 1
                    a.updateFirebaseAthleteInfo()
                }
                self.viewWillAppear(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            
            present(alert, animated: true)
            
        }
    
    
    
}

