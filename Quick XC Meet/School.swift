//
//  School.swift
//  TrackMeet
//
//  Created by Brian Seaver on 4/2/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import Foundation
import Firebase

public class School: Codable{
    var full: String
    var inits: String
    var coaches = [String]()
    var uid: String?
    var athletes = [Athlete]()
    
    init(full: String, inits: String) {
        self.full = full
        self.inits = inits
        
    }
    
    init(key: String, dict: [String:Any]  ){
        uid = key
        if let f = dict["full"] as? String, let i = dict["inits"] as? String {
            full = f
            inits = i
            
            if let coachesArray = dict["coaches"] as? NSArray{
            for i in 0..<coachesArray.count{
                coaches.append(coachesArray[i] as! String)
            }
            }
            
            if let athletesDict = dict["athletes"] as? [String: Any]{
                for (key, value) in athletesDict{
                    if let a = value as? [String: Any]{
                        athletes.append(Athlete(key: key, dict: a))
                    }
                }
                
            }
            
        }
        else{
            full = "Blank"
            inits = "B"
        }
        
      
        
    }
    
    func addCoach(email: String){
        coaches.append(email)
        
    }
    
    func addAthlete(ath: Athlete){
        athletes.append(ath)
    }
    
    func deleteFromFirebase(){
        if let ui = uid{
        Database.database().reference().child("schoolsNew").child(ui).removeValue()
        print("schoolnew has been removed from Firebase")
        }
        else{
            print("Error Deleting schoolnew")
        }
    }
    
    func updateFirebase(){
        if let ui = uid{
            var ref = Database.database().reference().child("schoolsNew").child(ui)
            let dict = ["full": self.full, "inits":self.inits, "coaches": coaches] as [String : Any]
            ref.updateChildValues(dict)
            print("update childvalues in updateFirebase function in School class \(self.full)")
            
            ref = ref.child("athletes")
            for a in athletes{
                let athDict = ["first": a.first,"last": a.last,"school": a.school, "schoolFull": a.schoolFull] as [String : Any]
              ref.child(a.uid!).updateChildValues(athDict)
                print("update all altheletes in updateFirebase function in School class")
                
            }
        }
        
    }
    
    func saveToFirebase(){
        let ref = Database.database().reference()
       
        let dict = ["full": self.full, "inits":self.inits, "coaches": coaches] as [String : Any]
       
        
        let thisUserRef = ref.child("schoolsNew").childByAutoId()
        uid = thisUserRef.key
        thisUserRef.setValue(dict)
    
        // Don't need, bercause above dict works
//        for c in coaches{
//            let emails = ["email": c] as [String : Any]
//            let coachID = thisUserRef.child("coaches").childByAutoId()
//            //uid = eventsID.key
//            coachID.setValue(emails)
//
//        }
    }
    
}

