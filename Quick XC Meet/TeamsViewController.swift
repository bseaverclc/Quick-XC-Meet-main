//
//  TeamsViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/13/22.
//

import UIKit

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    

    var resultsAthletes : [Athlete]!
    var meet : Meet!
    var selectedRace : String!
    var schoolInits : [String]!
    //var startDate : Date?
    var timer = Timer()
    var time = 0.0
    var setMinutes : Int!
    
    @IBOutlet weak var timeLabelOutlet: UILabel!
    @IBOutlet weak var schoolsSeg: UISegmentedControl!
    var displayedAhtletes = [Athlete]()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(meet.name) \(selectedRace ?? "")"
        tableView.delegate = self
        tableView.dataSource = self
        schoolsSeg.removeAllSegments()
       
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAthletes), name: Notification.Name("notifyAthleteChanged"), object: nil)
        
        var i = 0
        for school in schoolInits{
            schoolsSeg.insertSegment(withTitle: school, at: i, animated: true)
            i+=1
        }
        
        for segmentItem : UIView in schoolsSeg.subviews
            {
                for item : Any in segmentItem.subviews {
                    if let i = item as? UILabel {
                        //i.numberOfLines = 0
                        i.minimumScaleFactor = 0.25
                        i.adjustsFontSizeToFitWidth = true
                        // change other parameters: color, font, height ...
                    }
                }
            }
        
        if schoolsSeg.numberOfSegments != 0{
            schoolsSeg.selectedSegmentIndex = 0
            schoolsSegAction(schoolsSeg)
        }
        
        if let sd = Time.startDate{
            print("setting up timer")
            if Time.running{
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: .common)
            }
                
                
            }
        }
       
    

@objc func updateTime(){
    time =  Date().timeIntervalSince(Time.startDate ?? Date()) + Double(setMinutes) * 60.0
    updateUI()
}
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedAhtletes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! TeamsTableViewCell
        cell.mile1ButtonOutlet.addTarget(self, action: #selector(mile1Action(_:)), for: .touchUpInside)
        cell.mile1ButtonOutlet.tag = indexPath.row
        
        cell.mile2ButtonOutlet.addTarget(self, action: #selector(mile2Action(_:)), for: .touchUpInside)
        cell.mile2ButtonOutlet.tag = indexPath.row
        
        
        let ath = displayedAhtletes[indexPath.row]
        for race in ath.races{
            if race.name == selectedRace && race.meetName == meet.name{
                cell.configure(ath: ath, race: race)
                
//                cell.placeOutlet.text = "\(race.place ?? 999)"
//                cell.nameOutlet.text = "\(ath.last), \(ath.first) (\(ath.grade))"
//                cell.timeOutlet.text = race.markString
//                cell.initsOutlet.text = ath.school
//                if race.mile1 != nil{
//                    cell.mile1ButtonOutlet.isEnabled = false
//                }
//                cell.mile1ButtonOutlet.setTitle(race.mile1 ?? "Mile 1", for: .normal)
//              
//              
//                cell.mile2ButtonOutlet.setTitle(race.mile2 ?? "Mile 2", for: .normal)
               
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Meet.canManage{ return true}
        if displayedAhtletes[indexPath.row].schoolFull == AppData.mySchool{
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var ath = displayedAhtletes[indexPath.row]
            let mile1 = UITableViewRowAction(style: .normal, title: "Mile 1") { (action, indexPath) in
                
                for i in 0 ..< ath.races.count{
                    if ath.races[i].name == self.selectedRace && ath.races[i].meetName == self.meet.name{
                        let alert = UIAlertController(title: "Edit Time", message:"" , preferredStyle: .alert)
                        alert.addTextField(configurationHandler: { (textField) in
                            let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
                            textField.addConstraint(widthConstraint)
                            textField.keyboardType = .numberPad
                            textField.placeholder = "min"
                            
                        })
                        alert.addTextField(configurationHandler: { (textField) in
                            let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
                            textField.addConstraint(widthConstraint)
                            textField.keyboardType = .numberPad
                            textField.placeholder = "sec"
                            
                        })
                       
                        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
                            if let minutes = Int(alert.textFields![0].text!), let seconds = Int(alert.textFields![1].text!){
                                var secString = ""
                                if seconds < 10{ secString = "0\(seconds)"} else{secString = "\(seconds)"}
                                ath.races[i].mile1 = "\(minutes):\(secString)"
                                ath.updateFirebaseMile1(raceUid: ath.races[i].uid ?? "")
                                tableView.reloadData()
                            }
                            else{
                                print("Something is not an Integer!")
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                            ath.races[i].mile1 = nil
                            ath.updateFirebaseMile1(raceUid: ath.races[i].uid ?? "")
                            tableView.reloadData()
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        
                        break
                    }
                }
            }
        
        let mile2 = UITableViewRowAction(style: .normal, title: "Mile 2") { (action, indexPath) in
            
            for i in 0 ..< ath.races.count{
                if ath.races[i].name == self.selectedRace && ath.races[i].meetName == self.meet.name{
                    let alert = UIAlertController(title: "Edit Time", message:"" , preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (textField) in
                        let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
                        textField.addConstraint(widthConstraint)
                        textField.keyboardType = .numberPad
                        textField.placeholder = "min"
                        
                    })
                    alert.addTextField(configurationHandler: { (textField) in
                        let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
                        textField.addConstraint(widthConstraint)
                        textField.keyboardType = .numberPad
                        textField.placeholder = "sec"
                        
                    })
                   
                    alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
                        if let minutes = Int(alert.textFields![0].text!), let seconds = Int(alert.textFields![1].text!){
                            var secString = ""
                            if seconds < 10{ secString = "0\(seconds)"} else{secString = "\(seconds)"}
                            ath.races[i].mile2 = "\(minutes):\(secString)"
                            ath.updateFirebaseMile2(raceUid: ath.races[i].uid ?? "")
                            tableView.reloadData()
                        }
                        else{
                            print("Something is not an Integer!")
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        ath.races[i].mile2 = nil
                        ath.updateFirebaseMile2(raceUid: ath.races[i].uid ?? "")
                        tableView.reloadData()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
                    break
                }
            }
        }
        
     
           return [mile2, mile1]
        
      
        
    }
    

    @IBAction func schoolsSegAction(_ sender: UISegmentedControl) {
        var chosenInit = schoolsSeg.titleForSegment(at: schoolsSeg.selectedSegmentIndex)
        
        displayedAhtletes.removeAll()
        
        for ath in resultsAthletes{
            if ath.school == chosenInit  && ath.last != "??"{
                displayedAhtletes.append(ath)
            }
        }
        sortAthletesNameAndPlace()
        tableView.reloadData()
    }
    
    
    @IBAction func mile1Action(_ sender: UIButton) {
       
        var ath = displayedAhtletes[sender.tag]
        print(ath.last)
        for race in ath.races{
            if race.name == selectedRace && race.meetName == meet.name{
                race.mile1 = timeLabelOutlet.text
                ath.updateFirebaseMile1(raceUid: race.uid ?? "")
                break
            }
        }
        
        tableView.reloadData()
       
        
    }
    
    
    @IBAction func mile2Action(_ sender: UIButton) {
        var ath = displayedAhtletes[sender.tag]
        print(ath.last)
        for race in ath.races{
            if race.name == selectedRace && race.meetName == meet.name{
                race.mile2 = timeLabelOutlet.text
                ath.updateFirebaseMile2(raceUid: race.uid ?? "")
                break
            }
        }
        tableView.reloadData()
    }
    

    
    func updateUI() {

//        var mil = Int(round((time - Double(Int(time))) * 100))
       var sec = Int(time) % 60
        var min = Int(time) / 60
     
//        mil = time % 100
//        sec = (time/100)%60
//        min = time / (100*60)

        
        var secString = ""
        if sec < 10{
            secString = "0\(sec)"
        }
        else{
            secString = "\(sec)"
        }

        timeLabelOutlet.text = "\(min):\(secString)"
        //minutesTextField.text = String(min)
        //secondsTextField.text = String(sec)
        //tenthsTextField.text = String(mil)
    }
    
   @objc func updateAthletes(){
       print("calling updateAthletes in teams VC")
        resultsAthletes.removeAll()
        for a in AppData.allAthletes{
          
                  for e in a.races{
                    
                      if e.name == selectedRace && e.meetName == meet.name && e.markString != ""{
                          resultsAthletes.append(a)
                          //print("added athlete to resultsAthletes")
                      }
                      else if e.name == selectedRace && e.meetName == meet.name{
                          resultsAthletes.append(a)
                        }
                  }
 
              }
        
        var chosenInit = schoolsSeg.titleForSegment(at: schoolsSeg.selectedSegmentIndex)
        
        displayedAhtletes.removeAll()
        
        for ath in resultsAthletes{
            if ath.school == chosenInit  && ath.last != "??"{
                displayedAhtletes.append(ath)
            }
        }
        
       sortAthletesNameAndPlace()
        tableView.reloadData()
    }
    
    func sortAthletesNameAndPlace(){
        displayedAhtletes = displayedAhtletes.sorted { (lhs, rhs) in
            var lhsPlace = 999
            var rhsPlace = 999
            for race in lhs.races{
                if race.name == selectedRace && race.meetName == meet.name{
                    lhsPlace = race.place ?? 999
                }
            }
            for race in rhs.races{
                if race.name == selectedRace && race.meetName == meet.name{
                    rhsPlace = race.place ?? 999
                }
            }
            if lhsPlace == rhsPlace { // <1>
                return lhs.last < rhs.last
            }

            return lhsPlace < rhsPlace // <2>
        }
    }
    

}
