//
//  addAthleteViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/18/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit

class AddAthleteViewController: UIViewController {
   
    var athlete : Athlete!
    //var allAthletes = [Athlete]()
    var displayedAthletes = [Athlete]()
    
    var school : School!
  
 
    @IBOutlet weak var schoolOutlet: UISegmentedControl!
    
    @IBOutlet weak var yearOutlet: UISegmentedControl!
    
    @IBOutlet weak var lastOutlet: UITextField!
    
    @IBOutlet weak var firstOutlet: UITextField!
    
    @IBOutlet weak var genderOutlet: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolOutlet.removeAllSegments()
            schoolOutlet.insertSegment(withTitle: school.inits, at: 0, animated: true)
    
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
        if schoolOutlet.selectedSegmentIndex >= 0 && yearOutlet.selectedSegmentIndex >= 0 && genderOutlet.selectedSegmentIndex >= 0 {
        
        let first = firstOutlet.text
            let last = lastOutlet.text
            let schoolInit = schoolOutlet.titleForSegment(at: schoolOutlet.selectedSegmentIndex)
            let year = yearOutlet.titleForSegment(at: yearOutlet.selectedSegmentIndex)
            let gender = genderOutlet.titleForSegment(at: genderOutlet.selectedSegmentIndex)
         
           
            athlete = Athlete(f: first!, l: last!, s: schoolInit!, g: Int(year!)!, sf: school.full, gen: gender ?? "")
//            for sch in AppData.schoolsNew{
//                if sch.full == school.full{
//                    sch.addAthlete(ath: athlete)
//                    sch.updateFirebase()
//                }
//            }
            for a in AppData.allAthletes{
                if a.equals(other: athlete){
                   resignFirstResponder()
                   addAthlete = sameAthleteError()
                   
                    break
                }
            }
            if addAthlete{
            print("Created Athlete")
            AppData.allAthletes.insert(athlete, at: 0)
            
                // Save
                let userDefaults = UserDefaults.standard
                do {
                    try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                       } catch {
                           print(error.localizedDescription)
                       }
                
            
            displayedAthletes.insert(athlete, at: 0)
                print(athlete.schoolFull)
            performSegue(withIdentifier: "unwindToRoster", sender: self)
           
                athlete.saveToFirebase()
            }
        }
        else{
            let alert2 = UIAlertController(title: "Error!", message: "You must Year/School/Gender", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert2.addAction(action)
            present(alert2, animated: true, completion: nil)
        }
        
    }
    

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

