//
//  Meet.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/24/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import Foundation
import Firebase

public class Meet: Codable {
    
    static var canManage = false
    static var canCoach = false
    var name : String
    var privateMeet: Bool?
    var privateAccessCode : String?
    var date : Date
    var schools: [String:String]
    //var gender : String
    //var levels: [String]
    var races: [String]
    var racesGenders: [String]
    //var races2 = [String:[Athlete]]()
    //var events: [String]
    //var indPoints: [Int]
    //var relPoints: [Int]
    var beenScored: [Bool]
    var uid : String?
   // var coachCode = ""
    var managerCode = ""
    var userId = ""
    
    // build objects from firebase
    init(key: String, dict: [String:Any]  ){
        uid = key
        print(uid)
        if let n = dict["name"] as? String{
            name = n
        }
        else{
            name = "Blank"
        }
        
        if let p = dict["privateMeet"] as? Bool{
            privateMeet = p
        }
        else{
            privateMeet = false
        }
        
        if let pac = dict["privateAccessCode"] as? String{
            privateAccessCode = pac
        }
        
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yy"
        if let d = formatter1.date(from: dict["date"] as? String ?? "12/12/12"){
        date = d
        }
        else{ date = Date()}
        
//        if let g = dict["gender"] as? String{
//            gender = g
//        }
//        else{gender = "M"}
        
        
        if let s = dict["schools"] as? [String:String]{
        schools = s
        }
        else{schools = [:]}
        
        
        
        
//        levels = [String]()
//        if let levelsArray = dict["levels"] as? NSArray{
//        for i in 0..<levelsArray.count{
//            levels.append(levelsArray[i] as! String)
//        }
//        }
        
        races = [String]()
        if let racesArray = dict["races"] as? NSArray{
            for i in 0..<racesArray.count{
                races.append(racesArray[i] as! String)
            }
        }
        
        racesGenders = [String]()
        if let racesGendersArray = dict["racesGenders"] as? NSArray{
            for i in 0..<racesGendersArray.count{
                racesGenders.append(racesGendersArray[i] as! String)
            }
        }
        
       
        
        
        
        
//        events = [String]()
//        if let eventsArray = dict["events"] as? NSArray{
//        for i in 0..<eventsArray.count{
//            events.append(eventsArray[i] as! String)
//        }
//        }
        
//        indPoints = [Int]()
//        if let indPointsArray = dict["indPoints"] as? NSArray{
//        for i in 0..<indPointsArray.count{
//            indPoints.append(indPointsArray[i] as! Int)
//        }
//        }
        
//        relPoints = [Int]()
//        if let relPointsArray = dict["relPoints"] as? NSArray{
//        for i in 0..<relPointsArray.count{
//            relPoints.append(relPointsArray[i] as! Int)
//        }
//        }
        
        beenScored = [Bool]()
        if let beenScoredArray = dict["beenScored"] as? NSArray{
        for i in 0..<beenScoredArray.count{
            beenScored.append(beenScoredArray[i] as! Bool)
        }
        }
//        if let c = dict["coachCode"] as? String{
//            coachCode = c
//        }
        if let m = dict["managerCode"] as? String{
            managerCode = m
        }
        if let u = dict["userId"] as? String
        {
            userId = u
        }
        
        
        

    }
    
    // Creating a new Meet
    init(name n : String, date d:Date, schools s: [String:String],  races r : [String],  racesGenders rg: [String], beenScored se: [Bool],  manager: String, privateMeet pm : Bool, privateAccessCode pac: String ){
        name = n
        privateMeet = pm
        privateAccessCode = pac
        
        date = d
        schools = s
        races = r
        racesGenders = rg
       // gender = g
        //levels = l
        //events = e
       // indPoints = ip
       // relPoints = rp
        beenScored = se
       // coachCode = coach
        managerCode = manager
        userId = AppData.userID
//        if n != "Blank"{
//        saveMeetToFirebase()
//        }
    }
    
    func saveMeetToFirebase(){
        let ref = Database.database().reference()
        
        
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let dateString = formatter1.string(from: date)
//        var raceNames = [String]()
//        for (key,_) in races2{
//            raceNames.append(key)
//        }
       
        let dict = ["name": self.name, "date": dateString, "schools": self.schools, "races": races, "racesGenders": racesGenders,  "beenScored": self.beenScored, "managerCode": managerCode, "userId": userId, "privateMeet": privateMeet ?? false, "privateAccessCode": privateAccessCode ?? ""] as [String : Any]
       
        
        let thisUserRef = ref.child("meets").childByAutoId()
        uid = thisUserRef.key
        
        thisUserRef.setValue(dict)
//        for rn in raceNames{
//            races2[rn]!.append(Athlete(f: "Hi", l: "there", s: "ms", g: 0, sf: "mySchool"))
//            thisUserRef.child("races2").child(rn).setValue(races2[rn])
//            print("trying to add race athletes")
//        }
    }
    
    func deleteFromFirebase(){
      
        if let ui = uid{
        Database.database().reference().child("meets").child(ui).removeValue()
        print("Meet has been removed from Firebase")
        }
        else{
            print("Error Deleting Meet! Meet not in Firebase")
        }
    }
    
    func updateFirebase(m: Meet){
        var ref = Database.database().reference().child("meets").child(uid!)
        
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        let dateString = formatter1.string(from: m.date)
        
        
        
        let dict = ["name": m.name, "date": dateString, "schools": m.schools,  "races": m.races, "racesGenders": m.racesGenders, "beenScored": m.beenScored,  "managerCode": m.managerCode, "userId": m.userId, "privateMeet": m.privateMeet ?? false, "privateAccessCode": m.privateAccessCode ?? ""] as [String : Any]
        
        ref.updateChildValues(dict)
       // ref = ref.child("events")
        
        
        
        
        
        
    }
    
    
    func updatebeenScoredFirebase(){
       let ref = Database.database().reference().child("meets").child(uid!)
        
            ref.updateChildValues(["beenScored": beenScored])
        
    }
    
//    func updateEventsFirebase(){
//        let ref = Database.database().reference().child("meets").child(uid!)
//        
//            ref.updateChildValues(["events": events])
//        
//    }
    
    
    
    
}

