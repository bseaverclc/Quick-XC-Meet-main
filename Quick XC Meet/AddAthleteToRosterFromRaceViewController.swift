//
//  AddAthleteToRosterFromRaceViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/6/22.
//

import UIKit

class AddAthleteToRosterFromRaceViewController: UIViewController {
    
    var athlete : Athlete!
    var schoolInits : [String]!
    var schools : [String]!
    var meet: Meet!
    var selectedRace: String!
    
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var yearSegController: UISegmentedControl!
 
    @IBOutlet weak var schoolSegController: UISegmentedControl!
    
    @IBOutlet weak var genderSegController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //schoolInits = [String](meet.schools.values)
        //schools = [String](meet.schools.keys)
      print(schoolInits)
        print(schools)
        schoolSegController.removeAllSegments()
             var i = 0
             for school in schoolInits{
                 schoolSegController.insertSegment(withTitle: school, at: i, animated: true)
                 i+=1
             }

       
    }
    
    func sameAthleteError()-> Bool{
        let alert =  UIAlertController(title: "Error", message: "Athlete already exists in database", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alertaction) in
            print("Hit OK")
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        return false
    }
    

    @IBAction func addAction(_ sender: UIButton) {
        var addAthlete = true
        if schoolSegController.selectedSegmentIndex >= 0 && yearSegController.selectedSegmentIndex >= 0 && genderSegController.selectedSegmentIndex >= 0 {
        
        let first = firstTextField.text
            let last = lastTextField.text
            let schoolInit = schoolSegController.titleForSegment(at: schoolSegController.selectedSegmentIndex)
            let year = yearSegController.titleForSegment(at: yearSegController.selectedSegmentIndex)
            // changed the button from W to F in version 2.4 of app
            let gender = genderSegController.titleForSegment(at: genderSegController.selectedSegmentIndex)
         
           
            athlete = Athlete(f: first!, l: last!, s: schoolInit!, g: Int(year!)!, sf: schools[schoolSegController.selectedSegmentIndex], gen: gender ?? "")
            
            for a in AppData.allAthletes{
                if a.equals(other: athlete){
                   resignFirstResponder()
                   addAthlete = sameAthleteError()
                   
                    break
                }
            }
            if addAthlete{
            print("Created Athlete")
                AppData.allAthletes.append(athlete)
                athlete.saveToFirebase()
                athlete.addRace(e: Race(name: selectedRace, meetName: meet.name, date: meet.date))
            
            
                // Save
                let userDefaults = UserDefaults.standard
                do {
                    try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                       } catch {
                           print(error.localizedDescription)
                       }
     
            performSegue(withIdentifier: "unwindToRaceEdit", sender: self)
           
                
            }
        }
        else{
            let alert2 = UIAlertController(title: "Error!", message: "You must have Year/School/Gender", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert2.addAction(action)
            present(alert2, animated: true, completion: nil)
        }
        
    }
    

}
