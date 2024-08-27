//
//  AddRaceAthletesViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/26/22.
//

import UIKit
import Firebase

class AddRaceAthletesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
   
    var raceAthletes : [Athlete]!
    var resultsAthletes : [Athlete]!
    var selectedRace : String!
    var meet : Meet!
    var displayedAthletes = [Athlete]()
    var schoolInits : [String]!
    var schools : [String]!
    var selectedRaceGender : String!
    
    
    @IBOutlet weak var schoolSegOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
     //  displayAthletes()
        
        // take out the ??? school
       var j = 0
        for sch in schoolInits{
            if sch == "???"{
                schoolInits.remove(at: j)
               schools.remove(at: j)
            }
            else{
                j+=1
            }
      
        }
        schoolSegOutlet.removeAllSegments()
        
             var i = 0
        
             for school in schoolInits{
                 schoolSegOutlet.insertSegment(withTitle: school, at: i, animated: true)
                 i+=1
             }
        
        // getting my school initials
        print("my school \(AppData.mySchool)")
        var mySchoolinits = ""
        for (school,inits) in meet.schools{
            if school == AppData.mySchool{
                mySchoolinits = inits
                print("set my school inits")
            }
        }
        
        for s in 0..<schoolSegOutlet.numberOfSegments{
            if schoolSegOutlet.titleForSegment(at: s) == mySchoolinits{
                schoolSegOutlet.selectedSegmentIndex = s
               schoolSegOutlet.sendActions(for: .valueChanged)
                print("set segment")
            }
        }

        
    }
    
//    func displayAthletes(){
//        for a in AppData.allAthletes{
//            if meet.schools.keys.contains(a.schoolFull) && a.last != "??" && a.gender == selectedRaceGender{
//                displayedAthletes.append(a)
//                print("added an athlete")
//            }
//        }
//        sortbyName()
//        tableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedAthletes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "\(displayedAthletes[indexPath.row].last), \(displayedAthletes[indexPath.row].first) (\(displayedAthletes[indexPath.row].grade)) "
        cell.detailTextLabel?.text = "\(displayedAthletes[indexPath.row].school) (\(displayedAthletes[indexPath.row].gender))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       print("Did select row at")
        let alert = UIAlertController(title: "Error!", message: "Athlete already in event", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .cancel) { (action) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(action)
       let selectedAthlete = displayedAthletes[indexPath.row]
       if !Meet.canManage && selectedAthlete.schoolFull != AppData.mySchool{
           let alert = UIAlertController(title: "Error!", message: "You are not a coach of this school", preferredStyle: .alert)
           let action = UIAlertAction(title: "ok", style: .cancel) { (action) in
               self.tableView.deselectRow(at: indexPath, animated: true)
           }
           alert.addAction(action)
          present(alert, animated: true, completion: nil)
       }
       else if raceAthletes.contains(where: { $0.equals(other: selectedAthlete)}){
         
          present(alert, animated: true, completion: nil)
           
       } else if resultsAthletes.contains(where: { $0.equals(other: selectedAthlete)})  {
           present(alert, animated: true, completion: nil)
       }
   }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Meet.canManage{return true}
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
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            let alert = UIAlertController(title: "Are you sure?", message: "Deleting this athlete will also delete any results stored for this athlete", preferredStyle:    .alert)
//            let ok = UIAlertAction(title: "Delete", style: .destructive) { (a) in
//                let selected = self.displayedAthletes[indexPath.row]
//                AppData.allAthletes.removeAll { (athlete) -> Bool in
//                    athlete.equals(other: selected)
//
//                }
//                selected.deleteFromFirebase()
//                     self.displayedAthletes.remove(at: indexPath.row)
//                            tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//            alert.addAction(cancel)
//            alert.addAction(ok)
//            self.present(alert, animated: true, completion: nil)
//        }
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
               
                
                
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
                  
                    self.displayedAthletes[indexPath.row].first = alert.textFields![0].text!
                    self.displayedAthletes[indexPath.row].last = alert.textFields![1].text!
                   // self.displayedAthletes[indexPath.row].school = alert.textFields![2].text!
                    if let grade = Int(alert.textFields![2].text!){
                        self.displayedAthletes[indexPath.row].grade = grade}
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    for i in 0 ..< AppData.allAthletes.count{
                       if self.displayedAthletes[indexPath.row].equals(other: AppData.allAthletes[i]){
                        AppData.allAthletes[i].first = alert.textFields![0].text!
                         AppData.allAthletes[i].last = alert.textFields![1].text!
                         //AppData.allAthletes[i].school = alert.textFields![2].text!
                          if let grade = Int(alert.textFields![2].text!){
                                AppData.allAthletes[i].grade = grade}
                        
                        // updateFirebase
                        print(AppData.allAthletes[i].first)
                        AppData.allAthletes[i].updateFirebase()
                        // save changes to userDefaults
                        let userDefaults = UserDefaults.standard
                        do {

                            try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                               } catch {
                                   print(error.localizedDescription)
                               }
                                              break
                                          }
                    }
                  
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: false)
            }

        

        edit.backgroundColor = UIColor.blue

        return [edit]
    }
    
    
    @IBAction func schoolSegAction(_ sender: UISegmentedControl) {
        selectAthletes()
        
        var chosenInit = schoolSegOutlet.titleForSegment(at: schoolSegOutlet.selectedSegmentIndex)
        
        var chosenSchool = ""
        for (school, inits) in meet.schools{
            if chosenInit == inits{
                chosenSchool = school
            }
        }
        
        displayedAthletes.removeAll()
        if selectedRaceGender == "C"{
            for a in AppData.allAthletes{
                if a.schoolFull == chosenSchool && a.last != "??" && a.archived == false {
                    displayedAthletes.append(a)
                }
            }
        }
        else{
            for a in AppData.allAthletes{
                if a.schoolFull == chosenSchool && a.last != "??" && a.gender == selectedRaceGender && a.archived == false{
                    displayedAthletes.append(a)
                }
            }
        }
        sortbyName()
        tableView.reloadData()
    }
    
    @IBAction func addSelectedAction(_ sender: UIButton) {
        selectAthletes()
        performSegue(withIdentifier: "unwindToRaceEditSegue", sender: nil)
        
    }
    
    
    func selectAthletes(){
        if let selectedPaths = tableView.indexPathsForSelectedRows{
                 print(selectedPaths)
                 for path in selectedPaths{
                    let selectedAthlete = displayedAthletes[path.row]
                    
                    
                     selectedAthlete.addRace(e: Race(name: selectedRace, meetName: meet.name, date: meet.date))
                     raceAthletes.append(selectedAthlete)
                 }
          
             }
    }
    

    func sortbyName(){
        displayedAthletes = displayedAthletes.sorted { (lhs, rhs) in
//            if lhs.school == rhs.school { // <1>
//                return lhs.last < rhs.last
//            }
            
            return lhs.last < rhs.last // <2>
        }
    }
    
    @IBAction func addAthletetoRosterAction(_ sender: UIBarButtonItem) {
        if Meet.canCoach{
            performSegue(withIdentifier: "addAthleteSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAthleteSegue"{
        let nvc = segue.destination as! AddAthleteToRosterFromRaceViewController
        nvc.selectedRace = selectedRace
        nvc.meet = meet
            nvc.schools = schools
            nvc.schoolInits = schoolInits
        }
        
    }
    
    @IBAction func addAllAction(_ sender: UIButton) {
        for ath in displayedAthletes
        {
            if ath.schoolFull != AppData.mySchool && !Meet.canManage{
                let alert = UIAlertController(title: "Error!", message: "You are not a coach of this school", preferredStyle: .alert)
//                let action = UIAlertAction(title: "ok", style: .cancel) { (action) in
//
//                }
//                alert.addAction(action)
               present(alert, animated: true, completion: nil)
                break
            }
            else if raceAthletes.contains(where: { $0.equals(other: ath)}) ||  resultsAthletes.contains(where: { $0.equals(other: ath)}){
               
            }
            
            else{
                ath.addRace(e: Race(name: selectedRace, meetName: meet.name, date: meet.date))
                 raceAthletes.append(ath)
                performSegue(withIdentifier: "unwindToRaceEditSegue", sender: nil)
            }
        }
        
    }
    

}
