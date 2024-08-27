//
//  RaceEditViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/26/22.
//

import UIKit
import AudioToolbox
import Firebase

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

class Time{
    //static var timer = Timer()
    static var startDate: Date?
    static var running = false
    static var stopTime = 0.0
}

class RaceEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
    
    var timer = Timer()
    var time = 0.0
    //var running = false
    var min: Int = 0
    var sec: Int = 0
    var mil: Int = 0
    var setMinutes = 0
    //var startDate: Date?
    //var place = 1
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
   
    var goingForwards = false
    var meet: Meet!
    var selectedRace: String!
    var selectedRow: Int!
    var official = false
    var selectedRaceGender: String!
    var resultsSelectedRow = -1
    var tableViewSelectedRow = -1
    var raceAthletes = [Athlete]()
    
    
    var schools = [String]()
    var schoolInits = [String]()
    var schoolColors = [UIColor]()
  
    
    var resultsSchools = [String]()
    var resultsTimes = [String]()
    var resultsAthletes = [Athlete]()
    //var unknownAthlete : Athlete!
    
 
    
    
  
    
    @IBOutlet weak var timeLabelOutlet: UILabel!
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultsTableView: UITableView!

    @IBOutlet weak var resultsCollectionView: UICollectionView!
    @IBOutlet weak var raceAthletesCollectionView: UICollectionView!
    
    

    

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var setButton: UIButton!
    
    
    @IBOutlet weak var officialOutlet: UIButton!
    @IBOutlet weak var uploadOutlet: UIButton!
    @IBOutlet weak var scoresOutlet: UIButton!
    @IBOutlet weak var teamsOutlet: UIButton!
    @IBOutlet weak var colorsOutlet: UIButton!
    
    @IBOutlet weak var uploadColorsStackView: UIStackView!
    
    @IBOutlet weak var headTimerOutlet: UIButton!
    
    @IBOutlet weak var headTimerConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultsTableViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var athleteTableViewConstraint: NSLayoutConstraint!
    
    func setAthleteTableViewConstraint(){
        var height = Double((meet.schools.count + 1)/3 + 2) * 0.12
        if height > 0.75{
            height = 0.75
        }
        let newConstraint = athleteTableViewConstraint.constraintWithMultiplier(1.0 - height)
        view.removeConstraint(athleteTableViewConstraint)
        view.addConstraint(newConstraint)
        //view.layoutIfNeeded()
        athleteTableViewConstraint = newConstraint
    }
    
    func setResultsTableViewConstraint(){
        var height = Double((meet.schools.count + 1)/3 + 2) * 0.12
        if height > 0.75{
            height = 0.75
        }
        let newConstraint = resultsTableViewConstraint.constraintWithMultiplier(1.0 - height)
        view.removeConstraint(resultsTableViewConstraint)
        view.addConstraint(newConstraint)
        //view.layoutIfNeeded()
        resultsTableViewConstraint = newConstraint
    }
    
    func setHeadTimerConstraint(){
        var height = Double((meet.schools.count + 1)/3 + 2) * 0.12
        if height > 0.75{
            height = 0.75
        }
        let newConstraint = headTimerConstraint.constraintWithMultiplier(height)
        view.removeConstraint(headTimerConstraint)
        view.addConstraint(newConstraint)
        //view.layoutIfNeeded()
        headTimerConstraint = newConstraint
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setResultsTableViewConstraint()
        setHeadTimerConstraint()
        setAthleteTableViewConstraint()
        
        self.title = "\(selectedRace ?? "")"
        
        
       
        
        if !Meet.canManage{
            uploadColorsStackView.isHidden = true
            headTimerOutlet.isHidden = true
        }
        
        if Time.running{
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            
        }
        
        officialOutlet.layer.cornerRadius = 10
        uploadOutlet.layer.cornerRadius = 10
        scoresOutlet.layer.cornerRadius = 10
        teamsOutlet.layer.cornerRadius = 10
        colorsOutlet.layer.cornerRadius = 10
        startButton.layer.cornerRadius = 10
        resetButton.layer.cornerRadius = 10
        setButton.layer.cornerRadius = 10
        headTimerOutlet.layer.cornerRadius = 10
        
        
       
        tableView.delegate = self
        tableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsCollectionView.delegate = self
       resultsCollectionView.dataSource = self
       
        raceAthletesCollectionView.delegate = self
        raceAthletesCollectionView.dataSource = self
        
        //collectionView.register(UINib.init(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "theCell")
        
        
        
        // Creating arrays for the schools full names and school inititials
       
       
        
        for (school,inits) in meet.schools{
            schoolInits.append(inits)
            schoolColors.append(UIColor.lightGray)
           
        }
        schoolInits = schoolInits.sorted(by: { a, b in
            return a<b
        })
       
        for si in schoolInits{
            var found = false
            for (school, inits) in meet.schools{
                if si == inits{
                    schools.append(school)
                    found = true
                }
            }
            if found == false{
                
            }
        }
        
        schools.append("NO SCHOOL")
        schoolInits.append("???")
        schoolColors.append(UIColor.lightGray)
        
        print(schoolInits)
        print(schools)
        
        
       

        
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreen), name: Notification.Name("notifyScreenChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeet), name: Notification.Name("notifyMeetChanged"), object: nil)
        
        official = meet.beenScored[selectedRow]
       
        
        timeLabelOutlet.text = "00:00.0"
        
        if !Meet.canManage{
            resultsCollectionView.isHidden = true
        }
        if !Meet.canCoach{
            raceAthletesCollectionView.isHidden = true
        }
        
//        tableView.reloadData()
//        resultsTableView.reloadData()
        
        let longPress2 = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
                resultsTableView.addGestureRecognizer(longPress2)

      
    }
    
    @objc func updateScreen(){
        print("RaceEditVC updateScreen being called")
        viewWillAppear(true)
        //scrollToBottom()
    }
    
    @objc func updateMeet(){
        print("calling update Meet")
        for m in AppData.meets{
            if m.uid == meet.uid{
                meet = m
                viewDidAppear(true)
                break
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !goingForwards{
            //timer.invalidate()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        goingForwards = false
        
        
        if meet.beenScored[selectedRow]{
            officialOutlet.setTitle("Official", for: .normal)
            officialOutlet.backgroundColor = UIColor.green
          
            official = true
        }
        else{
            officialOutlet.setTitle("Unofficial", for: .normal)
            officialOutlet.backgroundColor = UIColor.red
            official = false
        }
        
        
        resultsAthletes.removeAll()
        raceAthletes.removeAll()
       
       
        for a in AppData.allAthletes{
          
                  for e in a.races{
                    
                      if e.name == selectedRace && e.meetName == meet.name && e.markString != ""{
                          resultsAthletes.append(a)
                          //print("added athlete to resultsAthletes")
                      }
                      else if e.name == selectedRace && e.meetName == meet.name{
                          raceAthletes.append(a)
                        }
                  }
 
              }
        
       
        
        
       
      
        sortRacebySchoolAndName()
        tableView.reloadData()
//        print("resultsAthletes before sorted")
//        for a in resultsAthletes{
//            print("\(a.last) \(a.schoolFull)")
//        }
        updateResultsTableView() // sorts results by place
        resultsCollectionView.reloadData()
        
     
            // keeping selected row when resultstable view changes
            if self.resultsSelectedRow >= 0 && self.resultsSelectedRow < self.resultsAthletes.count{
                self.resultsTableView.selectRow(at: IndexPath(row: self.resultsSelectedRow, section: 0), animated: true, scrollPosition: .none)
                
                // Showing only names from selected row school
                raceAthletes.removeAll()
                for a in AppData.allAthletes{
                    for e in a.races{
                        if e.name == selectedRace && e.meetName == meet.name && a.school == resultsAthletes[resultsSelectedRow].school  && a.first != "?" && e.markString == ""{
                            raceAthletes.append(a)
                        }
                    }
         
                }
                sortRacebySchoolAndName()
                self.tableView.reloadData()
                
                    }
            
        
    
        //resultsSelectedRow = -1
        tableViewSelectedRow = -1
       
    }
    
    @IBAction func resetTimer(_ sender: Any) {
        if resetButton.backgroundColor == UIColor.yellow{
            // no alert for resetting anymore
            self.setMinutes = 0
            self.timer.invalidate()
            self.time = 0.0
            self.updateUI()
            Time.running = false
            Time.stopTime = 0.0
            self.resetButton.setTitle("Stop", for: .normal)
            self.resetButton.backgroundColor = UIColor.red
            
            // don't need this alert anymore
//            let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to reset the timer back to 0:00.0?", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: { action in
//                self.setMinutes = 0
//                self.timer.invalidate()
//                self.time = 0.0
//                self.updateUI()
//                Time.running = false
//                Time.stopTime = 0.0
//                self.resetButton.setTitle("Stop", for: .normal)
//                self.resetButton.backgroundColor = UIColor.red
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
//            present(alert, animated: true, completion: nil)
            
        }
        else{
            let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to stop the timer?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Stop", style: .default, handler: { action in
                //self.setMinutes = 0
                self.timer.invalidate()
                //Time.stopTime = self.time
               // self.time = 0.0
                //self.updateUI()
                Time.running = false
                self.resetButton.setTitle("Reset", for: .normal)
                self.resetButton.backgroundColor = UIColor.yellow
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

        @IBAction func startTimer(_ sender: Any) {
            
            if Time.running{
                return
            }
            else{
                
                    Time.startDate = Date()
                
               
                    
                    
                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                    RunLoop.current.add(timer, forMode: .common)
                
                    Time.running = true
                    resetButton.backgroundColor = UIColor.red
                    resetButton.setTitle("Stop", for: .normal)
                
                updateUI()
                
            }
            //                running = true
            
//            if running {
//                return
//            } else {
//                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
//                RunLoop.current.add(timer, forMode: .common)
//                running = true
//            }

        }


    
    @IBAction func setTimeAction(_ sender: UIButton) {
        let sure = UIAlertController(title: "Warning", message: "Are you sure you want to set the timer to a specific amount of minutes? ", preferredStyle: .alert)
        sure.addAction(UIAlertAction(title: "Set Time", style: .default, handler: { action in
            self.timer.invalidate()
            Time.running = false
            let alert = UIAlertController(title: "Set Timer", message: "Enter Minutes", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .numberPad
                textField.placeholder = "minutes as an integer"
                
            })
            
            alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { action in
                if let minutes = Int(alert.textFields![0].text!){
                    self.min = minutes
                    self.sec = 0
                    self.mil = 0
                    self.setMinutes = minutes
                    self.time = Double(minutes) * 60.0
                    self.updateUI()
                }
                else{
                    let intAlert = UIAlertController(title: "Errror", message: "Must enter minutes as an integer.  If you want to set to 5 minutes then just enter the number 5", preferredStyle: .alert)
                    intAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(intAlert, animated: true, completion: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        sure.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(sure, animated: true, completion: nil)
        
       
        
        
    }
    
    
    @objc func updateTime() {
        time = Date().timeIntervalSince(Time.startDate ?? Date()) + Double(setMinutes) * 60.0
        //print(time)
        //time += 1
        updateUI()
    }

    func updateUI() {

        mil = Int(round((time - Double(Int(time))) * 100))
        sec = Int(time) % 60
        min = Int(time) / 60
     
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

        timeLabelOutlet.text = "\(min):\(secString).\(mil/10)"
        //minutesTextField.text = String(min)
        //secondsTextField.text = String(sec)
        //tenthsTextField.text = String(mil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
        return raceAthletes.count
        }
        else{
            return resultsAthletes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! RaceAthletesTableViewCell
            cell.configure(athlete: raceAthletes[indexPath.row])
        return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! ResultsTableViewCell
            let a = resultsAthletes[indexPath.row]
            if a.school == "???"{
                var found = false
            for r in a.races{
                if r.name == selectedRace && r.meetName == meet.name{
                    
                    cell.configure(place: r.place ?? 0, inits: a.school, time: r.markString, name: "\(a.last), \(a.first)")
                        found = true
                    
                    
                }
                
               
            }
                if !found{
                    cell.configure(place: 0, inits: "XXX", time: "0:00.0", name: "Deleted race?")
                }
            }
            else{
                for r in a.races{
                if r.name == selectedRace && r.meetName == meet.name{
                    cell.configure(place: r.place ?? 0, inits: a.school, time: r.markString, name: "\(a.last), \(a.first) (\(a.grade))")
                }
                }
            }
            //cell.configure(place: indexPath.row + 1, inits: resultsSchools[indexPath.row], time: resultsTimes[indexPath.row], name: "")
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // if you select raceTableView first nothing happens
        if tableView == self.tableView && resultsSelectedRow == -1{
          tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        else{
            // if you select RegularTableView after selecting a row in resultsTableView, then make the swap
            
            if tableView == self.tableView  && resultsSelectedRow != -1 {
                if Meet.canManage || !official{
                    if (raceAthletes[indexPath.row].school == resultsAthletes[resultsSelectedRow].school || resultsAthletes[resultsSelectedRow].school == "???") && (Meet.canManage){
                //The following was in the above && statement to allow coaches of a team to put their kids into spots that had their team finishing.  I decided to only allow Meet Managers to make that change.
                //|| AppData.mySchool == raceAthletes[indexPath.row].schoolFull){
                
                for raceAthRace in raceAthletes[indexPath.row].races{
                if raceAthRace.meetName == meet.name && raceAthRace.name == selectedRace{
                    //print("resultsAthletes.count \(resultsAthletes.count)")
                    for r in resultsAthletes[resultsSelectedRow].races{
                        if r.meetName == meet.name && r.name == selectedRace{
                            raceAthRace.markString = r.markString
                            raceAthRace.place = r.place
                            r.markString = ""
                            r.place = 999
                            
                            
                          
                            
                            // removing the race?
//                            resultsAthletes[resultsSelectedRow].races.removeAll { (e) -> Bool in
//                                print(e.uid ?? "No UID?")
//                                if e.name == selectedRace && e.meetName == self.meet.name{
//                                    if let euid = e.uid{
//                                        print("going to call deleteEventFromFirebase")
//
//                                    resultsAthletes[resultsSelectedRow].deleteRaceFromFirebase(euid: euid)
//
//
//                                    }
//                                    return true
//                                }
//                                return false
//                            }
                            
                            // updating raceathlete before updating raceAthlete
                            raceAthletes[indexPath.row].updateFirebase()
                            
                            let selected = resultsAthletes[resultsSelectedRow]
                            
                            // delete athlete from firebase
                            if selected.last == "??"{
                                AppData.allAthletes.removeAll { (athlete) -> Bool in
                                    athlete.uid == selected.uid
                                }
                                selected.deleteFromFirebase()
                                
                            }
                            else{
                                selected.updateFirebaseRaceMarkPlace(raceUid: r.uid ?? "" )
                                raceAthletes.append(selected)
                            }
                         
                            
                            
                            print("\(resultsSelectedRow), \(indexPath.row)")
                            
                          //  resultsAthletes[resultsSelectedRow] = raceAthletes[indexPath.row]
                           
                           // resultsAthletes[resultsSelectedRow].updateFirebase()
                            
                            raceAthletes.remove(at: indexPath.row)
                            
                            if let ipfsr = resultsTableView.indexPathForSelectedRow{
                            resultsTableView.deselectRow(at: ipfsr, animated: true)
                            }
                           
                            //updateResultsTableView()
                            self.tableView.deselectRow(at: indexPath, animated: true)
                            self.viewDidAppear(true)
                            
                           
                            
                            
                        }
                        
                    }
                }
            }
           makeUnofficial()
           resultsSelectedRow = -1
        }
            else{
                    print("Not a valid school")
                tableView.deselectRow(at: indexPath, animated: true)
               
            }
            }
                else{
                    if official{
                        let alert = UIAlertController(title: "Error!", message: "Results are official and you can't edit results.  Contact the meet manager if needed", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                }
        }
        else{
// if you select results tableView first
        if tableView == self.resultsTableView{
            print("selected row on resultsTableView row \(indexPath.row)")
// if you select resultsTableView first and it is the same row that is already selected
            if resultsSelectedRow == indexPath.row{
                print("s")
                resultsTableView.deselectRow(at: indexPath, animated: true)
                resultsSelectedRow = -1
                self.viewDidAppear(true)
               
            }
// selected results table view first and filter raceAthletes
            else{
            resultsSelectedRow = indexPath.row
                // only showing race athletes of the school you selected
                raceAthletes.removeAll()
                for a in AppData.allAthletes{
                    for e in a.races{
                        if e.name == selectedRace && e.meetName == meet.name && a.school == resultsAthletes[resultsSelectedRow].school  && a.first != "?" && e.markString == ""{
                            raceAthletes.append(a)
                        }
                    }
         
                }
                sortRacebySchoolAndName()
                self.tableView.reloadData()
            }
        }
            
        }
        print(resultsSelectedRow)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Meet.canManage{ return true}
        if tableView == self.tableView && raceAthletes[indexPath.row].schoolFull == AppData.mySchool{
            return true
        }
        return false
    }
    
    func deleteAthleteFromResults(indexPath: IndexPath){
        for i in 0 ..< self.resultsAthletes[indexPath.row].races.count{
            if self.resultsAthletes[indexPath.row].races[i].name == self.selectedRace && self.resultsAthletes[indexPath.row].races[i].meetName == self.meet.name{
                if !(self.resultsAthletes[indexPath.row].last == "??"){
                    let alert = UIAlertController(title: "Warning", message: "Can only delete if no name attached.  Change name to ??? before deleting", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                    break;
                }
                
                // checking if consecutive people have the same place then don't subtract 1 place from everyone below this person
                var subtract = true;
                
                if let currentPlace = self.resultsAthletes[indexPath.row].races[i].place{
                    // check before
                    if indexPath.row > 0{
                        let beforeAth = self.resultsAthletes[indexPath.row - 1]
                        for race in beforeAth.races{
                            if race.name == self.selectedRace && race.meetName == self.meet.name{
                                if let beforePlace = race.place{
                                    if beforePlace == currentPlace{
                                        subtract = false
                                        break
                                    }
                                }
                            }
                        }
                           
                        
                    }
                    // check after
                    if indexPath.row < self.resultsAthletes.count - 1{
                        let afterAth = self.resultsAthletes[indexPath.row + 1]
                        for race in afterAth.races{
                            if race.name == self.selectedRace && race.meetName == self.meet.name{
                                if let afterPlace = race.place{
                                    if afterPlace == currentPlace{
                                        subtract = false
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                
                if subtract{
                    // subtracting 1 from the place of everyone below this person
                    for j in indexPath.row + 1..<self.resultsAthletes.count{
                        for k in 0 ..< self.resultsAthletes[j].races.count{
                            if self.resultsAthletes[j].races[k].name == self.selectedRace && self.resultsAthletes[j].races[k].meetName == self.meet.name{
                                self.resultsAthletes[j].races[k].place = (self.resultsAthletes[j].races[k].place ?? 999) - 1
                                self.resultsAthletes[j].updateFirebaseRacePlace(raceUid: self.resultsAthletes[j].races[k].uid ?? "" )
                                break;
                            }
                        }
                    }
                }
                
                //remove selected row from firebase
                self.resultsAthletes[indexPath.row].deleteRaceFromFirebase(euid: self.resultsAthletes[indexPath.row].races[i].uid!)
                // remove selected row from here
                self.resultsAthletes[indexPath.row].races.remove(at: i)
                self.makeUnofficial()
                self.updateScreen()
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //var blankText = false
        if tableView == self.tableView{
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            for i in 0 ..< self.raceAthletes[indexPath.row].races.count{
                if self.raceAthletes[indexPath.row].races[i].name == self.selectedRace && self.raceAthletes[indexPath.row].races[i].meetName == self.meet.name{
                    self.raceAthletes[indexPath.row].deleteRaceFromFirebase(euid: self.raceAthletes[indexPath.row].races[i].uid!)
                    
                    self.raceAthletes[indexPath.row].races.remove(at: i)
                    
                    self.updateScreen()
                    break
                }
            }
        }
            return [delete]
        }
        else{
            let deleteFromResults = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                print("delete from results happening")
                self.deleteAthleteFromResults(indexPath: indexPath)
                
            }
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
                for i in 0 ..< self.resultsAthletes[indexPath.row].races.count{
                    if self.resultsAthletes[indexPath.row].races[i].name == self.selectedRace && self.resultsAthletes[indexPath.row].races[i].meetName == self.meet.name{
                        let alert = UIAlertController(title: "Edit Time", message:"(must fill out each field)" , preferredStyle: .alert)
                        alert.addTextField(configurationHandler: { (textField) in
                            //let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
                            //textField.addConstraint(widthConstraint)
                            textField.keyboardType = .numberPad
                            textField.placeholder = "minutes"
                           
                            
                        })
                        alert.addTextField(configurationHandler: { (textField) in
//                            let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
//                            textField.addConstraint(widthConstraint)
                            textField.keyboardType = .numberPad
                            textField.placeholder = "seconds"
                            
                        })
                        alert.addTextField(configurationHandler: { (textField) in
//                            let widthConstraint = NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
//                            textField.addConstraint(widthConstraint)
                            textField.keyboardType = .numberPad
                            textField.placeholder = "tenth"
                            
                            
                        })
                        
                        if indexPath.row == self.resultsAthletes.count - 1{
                            alert.addTextField { textField in
                                textField.keyboardType = .numberPad
                                textField.text = "\(indexPath.row + 1)"
                            }
                        }
                    
                        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { action in
                            if let minutes = Int(alert.textFields![0].text!), let seconds = Int(alert.textFields![1].text!), let tenths = Int(alert.textFields![2].text!){
                                var secString = ""
                                if seconds < 10{ secString = "0\(seconds)"} else{secString = "\(seconds)"}
                                self.resultsAthletes[indexPath.row].races[i].markString = "\(minutes):\(secString).\(tenths)"
                                if indexPath.row == self.resultsAthletes.count - 1{
                                    if let place = Int(alert.textFields![3].text!){
                                        self.resultsAthletes[indexPath.row].races[i].place = place
                                    }
                                    else{
                                        let nonIntAlert = UIAlertController(title: "Error", message: "Place must be an integer", preferredStyle: .alert)
                                        nonIntAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                                        self.present(nonIntAlert, animated: true)
                                        print("Place is not an Integer!")
                                    }
                                }
                                
                                self.resultsAthletes[indexPath.row].updateFirebaseRaceMarkPlace(raceUid: self.resultsAthletes[indexPath.row].races[i].uid ?? "" )
                                self.makeUnofficial()
                                self.updateScreen()
                            }
                            else{
                                let nonIntAlert = UIAlertController(title: "Error", message: "Everything must be an integer", preferredStyle: .alert)
                                nonIntAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                                self.present(nonIntAlert, animated: true)
                                print("Something is not an Integer!")
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        
                        break
                    }
                }
            }
            if indexPath.row == resultsAthletes.count - 1{
                return[edit, deleteFromResults]
            }
            else{
                return [edit, deleteFromResults]
            }
        }
        
      
        
    }

    
    func scrollToBottom(){
        
        if(resultsAthletes.count != 0)
            
        {
            let indexPath = IndexPath(item: resultsAthletes.count - 1, section: 0)
            resultsTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
        }
        }
    
    

    
    
    @IBAction func addAthleteAction(_ sender: UIBarButtonItem) {
        if Meet.canCoach{
        performSegue(withIdentifier: "addRaceAthletesSegue", sender:  nil)
        }
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRaceAthletesSegue"{
            goingForwards = true
        let nvc = segue.destination as! AddRaceAthletesViewController
       // nvc.allAthletes = allAthletes
        nvc.raceAthletes = raceAthletes
        nvc.resultsAthletes = resultsAthletes
        nvc.selectedRace = selectedRace
        nvc.selectedRaceGender = selectedRaceGender
        nvc.meet = meet
            nvc.schoolInits = schoolInits
            nvc.schools = schools

        }
        if segue.identifier == "uploadSegue"{
            goingForwards = true
            let nvc = segue.destination as! UploadViewController
            nvc.schools = self.schools
           
            nvc.resultsAthletes = self.resultsAthletes
            nvc.selectedRace = selectedRace
            nvc.meet = meet
        }
        if segue.identifier == "scoresSegue"{
            goingForwards = true
            let nvc = segue.destination as! ScoresViewController
            nvc.meet = meet
            nvc.resultsAthletes = resultsAthletes
            nvc.selectedRace = selectedRace
            nvc.schoolInits = schoolInits
            
        }
        if segue.identifier == "teamsSegue"{
            goingForwards = true
            let nvc = segue.destination as! TeamsViewController
            nvc.meet = meet
            nvc.resultsAthletes = resultsAthletes + raceAthletes
            nvc.selectedRace = selectedRace
            nvc.schoolInits = schoolInits
            //nvc.startDate = startDate
            nvc.setMinutes = setMinutes
            
        }
        if segue.identifier == "colorsSegue"{
            goingForwards = true
            if #available(iOS 14.0, *) {
                let nvc = segue.destination as! ColorsViewController
                nvc.schoolInits = schoolInits
                nvc.schoolColors = schoolColors
            } else {
                // Fallback on earlier versions
            }
           
        }
        
      
    }
    
    @IBAction func unwindFromColors( _ seg: UIStoryboardSegue) {
        print("unwind from Colors")
        if let pvc = seg.source as? ColorsViewController{
            schoolColors = pvc.schoolColors
            //self.resultsCollectionView.reloadData()
            
        }
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
//       meet.beenScored[selectedRow] = false
//        meet.updatebeenScoredFirebase()
//      processOutlet.backgroundColor = UIColor.lightGray
//       processOutlet.setTitle("Process Event", for: .normal)
       
       
       
      // if let pvc = seg.source as? AddRaceAthletesViewController{
         //allAthletes = pvc.allAthletes
         //screenTitle = pvc.screenTitle
       //raceAthletes = pvc.raceAthletes
           viewDidAppear(true)
         print("unwinding from AddAthleteToEvent")
        print("checking events after unwinding to eventeditvc")
//        for ath in eventAthletes{
//            for eve in ath.events{
//                print("\(ath.last) \(eve.name)")
//            }
//        }
       
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
       {
           let height  = Int(Double(view.frame.height)*0.065)
           let width = Int(view.frame.width - 40)/7
                     return CGSize(width: width, height: height)
       }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of cells for collection view \(schoolInits.count)")
        return schoolInits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "theCell", for: indexPath) as! MyCollectionViewCell
        if collectionView == resultsCollectionView{
        cell.contentView.backgroundColor = schoolColors[indexPath.row]
        }
        cell.configure(text: schoolInits[indexPath.row])

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Meet.canManage || !official{
        if collectionView == resultsCollectionView && Meet.canManage{
            makeUnofficial()
        print("selected item in collection view")
          
           // AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            feedbackGenerator.impactOccurred()
           
           
        var stringSec = ""
        if sec < 10{
            stringSec = "0\(sec)"
        }
        else{
            stringSec = "\(sec)"
        }
        let timeString = "\(min):\(stringSec).\(mil/10)"
        //resultsTimes.append(timeString)
        //resultsSchools.append(schoolInits[indexPath.row])
        
        
            var unknownAthlete = Athlete(f: "?", l: "??", s: schoolInits[indexPath.row], g: 9, sf: schools[indexPath.row], gen: "?")
        unknownAthlete.saveToFirebase()
            unknownAthlete.addRace(e: Race(name: selectedRace, meetName: meet.name, markString: timeString, place: resultsAthletes.count + 1, rg: "?", date: meet.date))
        resultsAthletes.append(unknownAthlete)
  
        updateResultsTableView()
        scrollToBottom()
        
    }
        if collectionView == raceAthletesCollectionView && resultsSelectedRow != -1 && (Meet.canManage || ( AppData.mySchool == schools[indexPath.row] && resultsAthletes[resultsSelectedRow].schoolFull == AppData.mySchool)) {
            makeUnofficial()
            var unknownAthlete = Athlete(f: "?", l: "??", s: schoolInits[indexPath.row], g: 9, sf: schools[indexPath.row], gen: "?")
            
            unknownAthlete.saveToFirebase()
            
            if let theRace = resultsAthletes[resultsSelectedRow].getRace(eventName: selectedRace, meetName: meet.name){
                unknownAthlete.addRace(e: Race(name: selectedRace, meetName: meet.name, markString: theRace.markString, place: theRace.place ?? 0, rg: "?", date: meet.date))
            }
            else{
                unknownAthlete.addRace(e: Race(name: selectedRace, meetName: meet.name, markString: "0:00.00", place: 0, rg: "?", date: meet.date))
            }
            AppData.allAthletes.append(unknownAthlete)
            
            //remove ?? athlete from AppData and firebase
            if resultsAthletes[resultsSelectedRow].last == "??"{
                var selected = resultsAthletes[resultsSelectedRow]
                
                    AppData.allAthletes.removeAll { (athlete) -> Bool in
                        athlete.uid == selected.uid
                    }
                resultsAthletes[resultsSelectedRow].deleteFromFirebase()
                print("removed athlete ?? from firebase")
                //resultsAthletes[resultsSelectedRow] = unknownAthlete
            }
            
            // change known athletes race to blank markString and place
            else{
                print("switching out a known athlete")
                for i in 0 ..< resultsAthletes[resultsSelectedRow].races.count{
                    if resultsAthletes[resultsSelectedRow].races[i].meetName == meet.name && resultsAthletes[resultsSelectedRow].races[i].name == selectedRace{
                        resultsAthletes[resultsSelectedRow].races[i].markString = ""
                        resultsAthletes[resultsSelectedRow].races[i].place = 999
                        var ath = resultsAthletes[resultsSelectedRow]
                        ath.updateFirebaseRaceMarkPlace(raceUid: resultsAthletes[resultsSelectedRow].races[i].uid ?? "" )
                   // raceAthletes.append(ath)
                        //print("added athlete to raceAthletes")
                    //resultsAthletes[resultsSelectedRow] = unknownAthlete
                    }
                }
                
               
            }
            //let lastselectedRow = resultsSelectedRow
            viewDidAppear(true)
            //resultsSelectedRow = lastselectedRow
        //updateResultsTableView()
        //scrollToBottom()
        }
        }
        else if official{
            let alert = UIAlertController(title: "Error!", message: "Results are official and you can't edit results.  Contact the meet manager if needed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func updateResultsTableView(){
        resultsAthletes.sort { lhs, rhs in
            if let a = lhs.getRace(eventName: selectedRace, meetName:   meet.name), let b = rhs.getRace(eventName: selectedRace, meetName:  meet.name){
               // print("found race")
                return a.place! < b.place!
            }
            else{
                print("can't find race")
                return false
            }
        }
        
        
//        resultsAthletes  = resultsAthletes.sorted { (lhs, rhs) -> Bool in
//            let a = lhs.getRace(eventName: selectedRace, meetName: meet.name
//                )?.place
//            let b = rhs.getRace(eventName: self.title!, meetName: meet.name)?.place
//                     switch (a ,b) {
//                       case let(a?, b?): return a < b // Both lhs and rhs are not nil
//                       case (nil, _): return false    // Lhs is nil
//                       case (_?, nil): return true    // Lhs is not nil, rhs is nil
//                       }
//                   }
        
        resultsTableView.reloadData()
    }
    
    func replaceWithUnknown(){
//        if raceAthletes[indexPath.row].last == "??"{
//            var copy = Athlete(f: "?", l: "??", s: raceAthletes[indexPath.row].school, g: 9, sf: raceAthletes[indexPath.row].schoolFull)
//            copy.saveToFirebase()
//            copy.addRace(e: Race(name: selectedRace, meetName: meet.name))
//            raceAthletes.append(copy)
//        }
    }
    
    
    @IBAction func uploadAction(_ sender: UIButton) {
        if Meet.canManage{
            performSegue(withIdentifier: "uploadSegue", sender: nil)
        }
    }
    
    func sortRaceBySchool(){
        raceAthletes =  raceAthletes.sorted { (struct1, struct2) -> Bool in
                        if (struct1.school.lowercased() != struct2.school.lowercased()) { // if it's not the same section sort by section
                            return struct1.school < struct2.school
                        } else { // if it the same section sort by order.
                            return struct1.last.lowercased() < struct2.last.lowercased()
                        }
                    }
    }
    
  
    
    func sortRacebySchoolAndName(){
        raceAthletes = raceAthletes.sorted { (lhs, rhs) in
            if lhs.school == rhs.school { // <1>
                return lhs.last < rhs.last
            }

            return lhs.school < rhs.school // <2>
        }
    }
    
    
    @IBAction func officialAction(_ sender: UIButton) {
        
        if Meet.canManage{
            if meet.beenScored[selectedRow]{
                official = false
                makeUnofficial()
            }
            else{
                official = true
                officialOutlet.backgroundColor = UIColor.green
           officialOutlet.setTitle("Official", for: .normal)
        meet.beenScored[selectedRow] = true
        meet.updatebeenScoredFirebase()
            }
        }
    }
    
    func makeUnofficial(){
        meet.beenScored[selectedRow] = false
        meet.updatebeenScoredFirebase()
        officialOutlet.backgroundColor = UIColor.red
        officialOutlet.setTitle("Unofficial", for: .normal)
    }
    
    
    @IBAction func scoresAction(_ sender: UIButton) {
        performSegue(withIdentifier: "scoresSegue", sender:     nil)
    }
    
    
    @IBAction func teamsAction(_ sender: UIButton) {
        
        performSegue(withIdentifier: "teamsSegue", sender: nil)
    }
    
    
    @IBAction func colorsAction(_ sender: Any) {
        performSegue(withIdentifier: "colorsSegue", sender:   nil)
    }
    
    
    @IBAction func headTimerAction(_ sender: UIButton) {
   
        let newConstraint = headTimerConstraint.constraintWithMultiplier(0.001)
        view.removeConstraint(headTimerConstraint)
        view.addConstraint(newConstraint)
        //view.layoutIfNeeded()
        headTimerConstraint = newConstraint
    
    }
    
    
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {

                if sender.state == UIGestureRecognizer.State.began {
                    let touchPoint = sender.location(in: resultsTableView)
                    if let indexPath = resultsTableView.indexPathForRow(at: touchPoint) {
                        // your code here, get the row for the indexPath or do whatever you want
                        print("Long press Pressed:) row \(indexPath.row)")
                        let alert = UIAlertController(title: "Insert or Delete?", message: "Do you want to insert a blank runner at place \(indexPath.row + 1) or delete this runner?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Insert", style: .default, handler: { action in
                            
                            //add 1 to all places >= to this place
                            for i in indexPath.row..<self.resultsAthletes.count{
                                for race in self.resultsAthletes[i].races{
                                    if race.meetName == self.meet.name && race.name == self.selectedRace{
                                        if race.place != nil{
                                            race.place! += 1
                                            self.resultsAthletes[i].updateFirebaseRacePlace(raceUid: race.uid ?? "")
                                        }
                                    }
                                }
                            }
                            
                            // create blank athlete
                            var unknownAthlete = Athlete(f: "?", l: "??", s: "???", g: 9, sf: "NO SCHOOL", gen: "?")
                            unknownAthlete.saveToFirebase()
                            unknownAthlete.addRace(e: Race(name: self.selectedRace, meetName: self.meet.name, markString: "0:00.0", place: indexPath.row + 1, rg: "?", date: self.meet.date))
                            
                            
                          
                  
                            self.resultsAthletes.insert(unknownAthlete, at: indexPath.row)
                           // self.viewWillAppear(true)
                            
                            self.updateResultsTableView()
                            //self.scrollToBottom()
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                            self.deleteAthleteFromResults(indexPath: indexPath)
                            
//                            if !(self.resultsAthletes[indexPath.row].last == "??"){
//                                let alert = UIAlertController(title: "Warning", message: "Can only delete if no name attached.  Change name to ??? before deleting", preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: "Ok", style: .default))
//                                self.present(alert, animated: true)
//                                return
//                            }
//
//
//
//                            //subtract 1 to all places >= to this place
//                            for i in indexPath.row..<self.resultsAthletes.count{
//                                for race in self.resultsAthletes[i].races{
//                                    if race.meetName == self.meet.name && race.name == self.selectedRace{
//                                        if race.place != nil{
//                                            race.place! -= 1
//                                            self.resultsAthletes[i].updateFirebase()
//                                        }
//                                    }
//                                }
//                            }
//
//                            // checking if consecutive people have the same place then don't subtract 1 place from everyone below this person
//                            var subtract = true;
//                            if let currentPlace = self.resultsAthletes[indexPath.row].races[i].place{
//                                if indexPath.row > 0{
//                                    if let beforePlace = self.resultsAthletes[indexPath.row - 1].races[i].place{
//                                        subtract = false
//                                    }
//                                }
//                                if indexPath.row < self.resultsAthletes.count - 1{
//                                    if let afterPlace = self.resultsAthletes[indexPath.row + 1].races[i].place{
//                                        subtract = false
//                                    }
//                                }
//                            }
//
//
//                            // delete athlete
//                            for i in 0 ..< self.resultsAthletes[indexPath.row].races.count{
//                                if self.resultsAthletes[indexPath.row].races[i].name == self.selectedRace && self.resultsAthletes[indexPath.row].races[i].meetName == self.meet.name{
//                                    if self.resultsAthletes[indexPath.row].last == "??"{
//                                    self.resultsAthletes[indexPath.row].deleteRaceFromFirebase(euid:self.resultsAthletes[indexPath.row].races[i].uid!)
//                                        self.raceAthletes.append(self.resultsAthletes[indexPath.row])
//                                        //self.resultsAthletes[indexPath.row].races.remove(at: i)
//                                    }
//                                    else{
//
//
//                                    }
//
//
//
//                                    self.updateResultsTableView()
//                                    self.tableView.reloadData()
//                                    //self.updateScreen()
//                                    break
//                                }
//                            }
                          
                            
                            
                          
                  
                            //self.resultsAthletes.insert(unknownAthlete, at: indexPath.row)
                           // self.viewWillAppear(true)
                            
                           
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                        
                        present(alert, animated: true, completion: nil)
                    }
                }


            }
    
    
}
