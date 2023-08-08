//
//  Athlete.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/17/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
enum levels{
    
}

public class Athlete : Codable{
    var first: String
    var last: String
    var school: String
    var schoolFull: String
    var grade: Int
    var races: [Race]
    var gender: String
    var uid: String?
  
    
    init(f: String, l: String, s: String, g: Int, sf: String, gen: String) {
        first = f
        last = l
        school = s
        grade = g
        schoolFull = sf
        gender = gen
        races = [Race]()
       // saveToFirebase()
    }
    
    init(key: String, dict: [String:Any] ) {
        first = dict["first"] as! String
        last = dict["last"] as! String
        school = dict["school"] as! String
        grade = dict["grade"] as! Int
        schoolFull = dict["schoolFull"] as! String
        gender = dict["gender"] as! String
        races = [Race]()
        if let dictRaces = dict["races"] as? [String: Any]{
        for (key, value) in dictRaces{
            if let r = value as? [String: Any]{
                races.append(Race(key: key, dict: r))
            }
        }
        }
        uid = key
        //saveToFirebase()
    }
    
    init(id: String,f: String, l: String, s: String, g: Int, sf: String, gen: String ) {
        first = f
        last = l
        school = s
        grade = g
        schoolFull = sf
        gender = gen
        races = [Race]()
        uid = id
        //saveToFirebase()
    }
    
   
    // called when getting from firebase
    func addRace(key: String, dict: [String:Any] ){
        var add = true
        for r in races{
            if key == r.uid{
                add = false
            }
        }
        if add{
        races.append(Race(key: key, dict: dict))
        }
    }
    
    func addRace(e: Race){
        races.append(e)
        let ref = Database.database().reference().child(uid!)
        e.uid = ref.childByAutoId().key
        print("added event with key \(e.uid!)")
        updateFirebase()
    }
    
    func addRace(name: String, meetName: String, date: Date){
        let e = Race(name: name, meetName: meetName, date: date)
        races.append(e)
        let ref = Database.database().reference().child(uid!)
        e.uid = ref.childByAutoId().key
        print("added race with key \(e.uid!)")
        //updateFirebase()
    }
    
    func getRace(eventName: String, meetName: String) -> Race?{
        for e in races{
            if e.name == eventName && e.meetName == meetName{
                return e
            }
        }
        return nil
    }
    
   
    
    func equals(other: Athlete) -> Bool{
        if (self.first == other.first && self.last == other.last && self.schoolFull == other.schoolFull && self.grade == other.grade && self.gender == other.gender){
            return true
        }
        else{return false}
    }
    
    
    
    func saveToFirebase() {
        let ref = Database.database().reference()
       
        let dict = ["first": self.first, "last":self.last, "school": self.school, "schoolFull":self.schoolFull, "grade":self.grade, "gender": self.gender] as [String : Any]
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        
        let thisUserRef = ref.child("schoolsNew").child(schoolUid).child("athletes").childByAutoId()
        uid = thisUserRef.key
        thisUserRef.setValue(dict)
        
        for e in races{
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            var dateString : String?
            if let d = e.date{
            dateString = formatter1.string(from: d)
            }
            let raceDict = ["meetName": e.meetName,"name": e.name,  "mark": e.mark, "markString": e.markString, "place":e.place ?? nil, "raceGender": e.raceGender, "mile1": e.mile1 ?? nil, "mile2": e.mile2 ?? nil, "date": dateString ?? nil] as [String : Any]
            let raceID = thisUserRef.child("races").childByAutoId()
            e.uid = raceID.key
            raceID.setValue(raceDict)
            
        }
        
        
     print("saving athlete to firebase")
     }
    
    func updateFirebase(){
        var ref = Database.database().reference()
        let dict = ["first": self.first, "last":self.last, "school": self.school, "schoolFull":self.schoolFull, "grade":self.grade, "gender": self.gender] as [String : Any]
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).updateChildValues(dict)
        
        ref =  ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).child("races")
        for e in races{
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            var dateString: String?
            if let d = e.date{
            dateString = formatter1.string(from: d)
            }
            
           // let raceDict = ["meetName": e.meetName,"name": e.name,"mark": e.mark, "markString": e.markString, "place": e.place ?? nil, "raceGender": e.raceGender, "mile1": e.mile1 ?? nil, "mile2": e.mile2 ?? nil, "date": dateString ?? nil] as [String : Any]
            // Don't update mile1 and mile2 here
            let raceDict = ["meetName": e.meetName,"name": e.name,"mark": e.mark, "markString": e.markString, "place": e.place ?? nil, "raceGender": e.raceGender, "date": dateString ?? nil] as [String : Any]
            
            ref.child(e.uid!).updateChildValues(raceDict)
                  
        }
      
        
        
        print("updating athlete in firebase")
}
    
    
    func updateFirebaseAthleteInfo(){
        var ref = Database.database().reference()
        let dict = ["first": self.first, "last":self.last, "school": self.school, "schoolFull":self.schoolFull, "grade":self.grade, "gender": self.gender] as [String : Any]
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).updateChildValues(dict)
    }
    
    func updateFirebaseRacePlace(raceUid: String){
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        
        for r in races{
            if r.uid == raceUid{
                let dict = ["place": r.place]
                if let ruid = r.uid{
                    var ref = Database.database().reference()
                    ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).child("races").child(raceUid).updateChildValues(dict)
                    break
                }
            }
        }
    }
    
    func updateFirebaseRaceMarkPlace(raceUid: String){
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        
        for r in races{
            if r.uid == raceUid{
                let dict = ["place": r.place, "mark": r.mark,  "markString": r.markString] as [String: Any]
                if let ruid = r.uid{
                    var ref = Database.database().reference()
                    ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).child("races").child(raceUid).updateChildValues(dict)
                    break
                }
            }
        }
        
        
    }
    
    func updateFirebaseMile1(raceUid: String){
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        var ref = Database.database().reference()
        ref = ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).child("races")
        for r in races{
            if r.uid == raceUid{
                let dict = ["mile1": r.mile1 ?? nil]
                if let ruid = r.uid{
                    ref.child(ruid).updateChildValues(dict)
                    print("updated mile1 on firebase")
                    break;
                }
            }
        }
        
    }
    
    func updateFirebaseMile2(raceUid: String){
        var schoolUid = ""
        for sch in AppData.schoolsNew{
            if sch.full == schoolFull{
                schoolUid = sch.uid!
                break
            }
        }
        var ref = Database.database().reference()
        ref = ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).child("races")
        for r in races{
            if r.uid == raceUid{
                let dict = ["mile2": r.mile2 ?? nil]
                if let ruid = r.uid{
                ref.child(ruid).updateChildValues(dict)
                print("updated mile2 on firebase")
                }
            }
        }
        
    }
    
    func updateFirebase(schoolUid: String){
        var ref = Database.database().reference()
        let dict = ["first": self.first, "last":self.last, "school": self.school, "schoolFull":self.schoolFull, "grade":self.grade, "gender": self.gender] as [String : Any]
       
        ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).updateChildValues(dict)
        
        ref =  ref.child("schoolsNew").child(schoolUid).child("athletes").child(uid!).child("races")
        for e in races{
            let formatter1 = DateFormatter()
            formatter1.dateStyle = .short
            let dateString = formatter1.string(from: e.date ?? Date())
            let raceDict = ["meetName": e.meetName,"name": e.name,"mark": e.mark, "markString": e.markString, "place":e.place ?? nil, "raceGender": e.raceGender, "date": dateString] as [String : Any]
            ref.child(e.uid!).updateChildValues(raceDict)
                  
        }
      
        
        
        print("updating athlete in firebase")
}
    

    
    
   
    func deleteFromFirebase(){
        if let ui = uid{
            var schoolUid = ""
            for sch in AppData.schoolsNew{
                if sch.full == schoolFull{
                    schoolUid = sch.uid!
                    break
                }
            }
            Database.database().reference().child("schoolsNew").child(schoolUid).child("athletes").child(ui).removeValue()
        print("Athlete has been removed from Firebase")
        }
        else{
            print("Error Deleting Athlete! Athlete not in Firebase")
        }
    }
    
    func deleteRaceFromFirebase(euid: String){
        if let uia = uid{
            var schoolUid = ""
            for sch in AppData.schoolsNew{
                if sch.full == schoolFull{
                    schoolUid = sch.uid!
                    break
                }
            }
            Database.database().reference().child("schoolsNew").child(schoolUid).child("athletes").child(uia).child("races").child(euid).removeValue()
            //print(ref)
        print("Race \(last) \(euid) has been removed from Firebase")
        }
        else{
            print("Error Deleting Event! Event not in Firebase")
        }
    }
    
   
    
    
}



public class Race:Codable{
    var name: String
    //var level: String
    var mark: Float
    var markString: String
    var place: Int?
    //var points = 0.0
    //var heat = 0
    var meetName = ""
    var date : Date?
    var raceGender : String
    var uid : String?
    var mile1 : String?
    var mile2 : String?
    //var relayMembers : [String]?
    
    //build Race from Firebase
    init(key: String, dict: [String:Any] ) {
        uid = key
        name = dict["name"] as! String
//        level = dict["level"] as! String
        if let m = dict["mark"]{
            if let mk = m as? Float{
                mark = mk
            }
            else{
                mark = 0.0
            }
        }
        else {mark = 0.0;}
        
        markString = dict["markString"] as! String
        if let p = dict["place"] as? Int{
        place = p
        }
        else{place = nil}
       
        if let m1 = dict["mile1"]{
            mile1 = m1 as! String
        }
        if let m2 = dict["mile2"]{
            mile2 = m2 as! String
        }
       
        meetName = dict["meetName"] as! String
        raceGender = dict["raceGender"] as! String
        
        if let _ = dict["date"]{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yy"
        if let d = formatter1.date(from: dict["date"] as? String ?? "12/12/12"){
        date = d
        }
        }
       
        
        
        
    }
    
    init(name: String, meetName: String, date: Date) {
        self.name = name
        //self.level = level
        self.mark = 0.0
        markString = ""
        self.meetName = meetName
        self.place = nil
        raceGender = "?"
        self.date = date
        
    }
    
    init(name: String, meetName: String, markString: String, place: Int, rg: String, date: Date){
        self.name = name
        self.mark = 0.0
        self.markString = markString
        self.meetName = meetName
        self.place = place
        raceGender = rg
        self.date = date
    }
    
    
    func addDate(date: Date){
        self.date = date
    }
    
    
    
    
}

