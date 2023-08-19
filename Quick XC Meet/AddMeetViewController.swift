//
//  AddMeetViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/24/22.
//

import UIKit

class AddMeetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
   
    

    @IBOutlet weak var meetNameTextField: UITextField!
  
    @IBOutlet weak var privateOutlet: UISegmentedControl!
    
    @IBOutlet weak var privateAcessOutlet: UITextField!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    @IBOutlet weak var schoolsTableView: UITableView!
    @IBOutlet weak var racesTableView: UITableView!
    
    @IBOutlet weak var codeTextField: UITextField!
    var schools = [School]()
    var races = [String]()
    var racesGenders = [String]()
   // var races2 = [String: [Athlete]]()
    var changeMeet = false
    var meet : Meet!
   // var meets: [Meet]!
    var selectedMeet : Meet?
    var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolsTableView.delegate = self
        schoolsTableView.dataSource = self
        racesTableView.delegate = self
        racesTableView.dataSource = self
        
        meetNameTextField.delegate = self
        codeTextField.delegate = self
        
        
       //.titleLabel?.adjustsFontSizeToFitWidth = true

       // addSchoolButton.titleLabel?.minimumScaleFactor = 0.5
        
        // sort the scoring textfields
      
        privateOutlet.selectedSegmentIndex = 0
        privateAcessOutlet.isHidden = true
        
        
        meetNameTextField.isEnabled = true
        if let meet = selectedMeet{
            changeMeet = true
            // set the name and you can't change it!
            meetNameTextField.text = meet.name
            meetNameTextField.isEnabled = false
            meetNameTextField.textColor = UIColor.lightGray
            
            // set the public/private
            
            if let pm = meet.privateMeet{
                if pm{
                    privateOutlet.selectedSegmentIndex = 1
                    privateAcessOutlet.isHidden = false
                    privateAcessOutlet.text = meet.privateAccessCode ?? ""
                }
            }
            
            // set the date
            datePickerOutlet.date = meet.date
            
            // still need to set the schools
            
            
            
//            races2 = meet.races2
//            for (key,_) in races2{
//                races.append(key)
//            }
            
            races = meet.races
            racesGenders = meet.racesGenders
            
//            // set the levels
//            for race in meet.races{
//                for button in levelButtonsOutlet{
//                    if button.titleLabel?.text == level{
//                        button.isSelected = true
//                    }
//                }
//            }
            
            // set the events no happening yet
            
            // set the scores
         
            
            
            codeTextField.text = meet.managerCode
            
        }
        else{
            meetNameTextField.becomeFirstResponder()
        }
        
        if let sm = selectedMeet{
            for school in AppData.schoolsNew{
                if sm.schools[school.full] != nil{
                    schools.append(school)
                }
            }
        }
        
        
       
        
//         eventAthletes = eventAthletes.sorted(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
        
        
        //tableView.flashScrollIndicators()
        //ScoreTableView.layer.borderWidth = 2
        
        // make an array of the school keys and values
//        schoolKeys = Array(AppData.schools.keys)
//        initials = Array(AppData.schools.values)
        
        // You may want to sort it
       // schoolKeys.sort(by: {$0 < $1})
        // Do any additional setup after loading the view.
       
    }
    
    @IBAction func addSchoolsAction(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func addRaceAction(_ sender: UIButton) {
        var alert = UIAlertController(title: "Add a Race", message: "Enter the name of the race", preferredStyle: .alert
        )
        
        var raceGender = ""
        var genderAlert = UIAlertController(title: "Race Gender", message: "", preferredStyle: .alert)
        genderAlert.addAction(UIAlertAction(title: "Male", style: .default, handler: { ActionHandler in
            raceGender = "M"
            self.present(alert, animated: true, completion: nil)
        }))
        genderAlert.addAction(UIAlertAction(title: "Female", style: .default, handler: { ActionHandler in
            raceGender = "F"
            self.present(alert, animated: true, completion: nil)
        }))
        genderAlert.addAction(UIAlertAction(title: "Coed", style: .default, handler: { ActionHandler in
            raceGender = "C"
            self.present(alert, animated: true, completion: nil)
        }))
        genderAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { ActionHandler in
            
        }))
        
        present(genderAlert, animated: true, completion: nil)
        
        
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.autocapitalizationType = .allCharacters
            textField.placeholder = "enter name of race"
            
        })
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            var add = true
            for race in self.races {
                if race == alert.textFields![0].text!{
                    add = false
                }
            }
            if add{
            self.races.append(alert.textFields![0].text!)
            self.racesGenders.append(raceGender)
            self.racesTableView.reloadData()
            }
            else{
                let badRaceAlert = UIAlertController(title: "Error", message: "Race name already exists", preferredStyle: .alert)
                badRaceAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(badRaceAlert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == racesTableView{
            return true
        }
        else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
          let alert = UIAlertController(title: "Are you sure?", message: "Deleting this race will delete any results for this race", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
          alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
              self.races.remove(at: indexPath.row)
              self.racesGenders.remove(at: indexPath.row)
              self.racesTableView.deleteRows(at: [indexPath], with: .automatic)
          }))

          self.present(alert, animated: true, completion: nil)
      }
    }
    
  
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == schoolsTableView{
            return schools.count
        }
        else{
            return races.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == schoolsTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
            cell.textLabel?.text = schools[indexPath.row].full
            cell.detailTextLabel?.text = schools[indexPath.row].inits
            return cell
            }
            
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
            cell.textLabel!.text = races[indexPath.row]
            cell.detailTextLabel?.text = racesGenders[indexPath.row]
            return cell
            
        }
        
    }
    
    func showAlert(errorMessage:String){
        let alert = UIAlertController(title: "Error!", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func submitAction(_ sender: UIButton) {
       // print("hit submit button")
        // Error Checking
        var gen = ""
        if meetNameTextField.text == ""{
            showAlert(errorMessage: "You need to have a meet name")
            return
        }
        
       
        if !changeMeet{
        for meet in AppData.meets{
            if meet.name == meetNameTextField.text{
                showAlert(errorMessage: "Meet name already in use")
                return
            }
        }
        }
        
        var pm = false
        if privateOutlet.selectedSegmentIndex == 1{
            pm = true
            if privateAcessOutlet.text == ""{
                showAlert(errorMessage: "Private Meets need to have an access code")
                return
            }
        }
        
        
        //selectedSchools.removeAll()
        //getSchools()
        if schools.count == 0{
            showAlert(errorMessage: "You have to have at least 1 school")
            return
        }
       
       //print(selectedSchools)
       
        
        
      
        if races.count == 0{
            showAlert(errorMessage: "You have to have at least 1 race")
            return
        }
        var beenScored = [Bool]()
        for _ in races{
            beenScored.append(false)
        }
        
        
        
       
        if codeTextField.text != ""{
            code = codeTextField.text!
        }
        else{
        showAlert(errorMessage: "You must enter a meet manager code")
         return
        }
        
        // Take out the old meet
//        if let oldMeet = selectedMeet{
//            for i in 0 ... AppData.meets.count - 1{
//                if oldMeet.name == AppData.meets[i].name{
//                    AppData.meets[i].deleteFromFirebase()
//                    AppData.meets.remove(at: i)
//                    print("removed meet")
//                    break;
//                }
//            }
//        }
        
        // create String dict of schools
        var schoolsDict = [String:String]()
        for school in schools{
            schoolsDict[school.full] = school.inits
        }
        
        
        // Create a new meet and add to meets array
        meet = Meet(name: meetNameTextField.text!, date: datePickerOutlet.date, schools: schoolsDict,  races: self.races,  racesGenders: self.racesGenders,beenScored: beenScored, manager: code, privateMeet: pm, privateAccessCode: privateAcessOutlet.text ?? "")
        //AppData.meets.append(meet)
      
        if changeMeet{
            if let sm = selectedMeet{
            sm.updateFirebase(m: meet)
                    
            
            let alert = UIAlertController(title: "Meet has been changed!", message: "Be sure to reprocess all events that you have already processed", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.performSegue(withIdentifier: "unwindToMeetsSegue", sender: self)
            
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            }
        }
        else{
            meet.saveMeetToFirebase()
            let alert = UIAlertController(title: "Success!", message: "Meet Created", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.performSegue(withIdentifier: "unwindToMeetsSegue", sender: self)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
        
        //print("\(meet)")
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddSchoolsSegue"{
        let nvc = segue.destination as! AddSchoolsViewController
           
            nvc.selectedSchools = schools
        }
    }
    
    @IBAction func unwindFromAddSchools( _ seg: UIStoryboardSegue) {
        let pvc = seg.source as! AddSchoolsViewController
        schools = pvc.selectedSchools
        schoolsTableView.reloadData()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        meetNameTextField.resignFirstResponder()
        codeTextField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func tapScreenAction(_ sender: UITapGestureRecognizer) {
        meetNameTextField.resignFirstResponder()
        codeTextField.resignFirstResponder()
    }
    
    
    @IBAction func privateMeetAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            privateAcessOutlet.isHidden = true
            privateAcessOutlet.text = ""
        }
        else{
            privateAcessOutlet.isHidden = false
            
        }
    }
    
}
