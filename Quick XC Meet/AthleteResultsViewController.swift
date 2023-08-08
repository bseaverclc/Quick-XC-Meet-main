//
//  AthleteResultsViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 9/4/22.
//

import UIKit

class AthleteResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
 
    var races = [Race]()
    var athlete : Athlete!
    let dateFormatter = DateFormatter()

   

   
    
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.dataSource = self
        tableViewOutlet.delegate = self
        
        // Set Date Format
        dateFormatter.dateFormat = "MM/dd/YY"
        
        self.title = "\(athlete.last), \(athlete.first)"
        
        for race in athlete.races{
            races.append(race)
            if let d = race.date{
                
            }
            else{
                for meet in AppData.meets{
                    if meet.name == race.meetName{
                        // Convert Date to String
                        race.date = meet.date
                        break
                    }
                }
            }
        }
        
        races.sort { $0.date ?? Date() > $1.date ?? Date()}

        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        races.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! AthleteResultsTableViewCell
        cell.mile2PlusMinusOutlet.backgroundColor = UIColor.clear
        cell.mile3PlusMinusOutlet.backgroundColor = UIColor.clear
        
        var race = races[indexPath.row]
        cell.meetNameOutlet.text = race.meetName
        cell.timeOutlet.text = race.markString
        //put overall time on the left also?
       // cell.OverallTimeOutlet.text = race.markString

        cell.raceNameOutlet.text = race.name
        if let p = race.place{
            cell.placeOutlet.text = "Place: \(p)"
        }
        else{
            cell.placeOutlet.text = ""
        }
        //cell.placeOutlet.text = "Place: \(race.place ?? 0)"
//
        cell.mile3SplitOutlet.text = ""
        cell.mile2SplitOutlet.text = ""
        cell.mile2PlusMinusOutlet.text = ""
        cell.mile3PlusMinusOutlet.text = ""
        
        if let m1 = race.mile1{
            cell.mile1Outlet.text = "\(m1)"
        }
        else{
            cell.mile1Outlet.text = ""
        }
        var split = ""
        var mile2Text = ""
        if let m2 = race.mile2{
            mile2Text = m2
            if let m1 = race.mile1{
                split = findSplit(t1: m1, t2: m2)
               var m2PlusMinus = findSplitPlusMinus(t1: m1, t2: split)
                if m2PlusMinus.starts(with: "-"){
                    cell.mile2PlusMinusOutlet.backgroundColor = UIColor.green
                }
                cell.mile2SplitOutlet.text = "(\(split))"
                cell.mile2PlusMinusOutlet.text = "\(m2PlusMinus)"
            }
           
        }
        cell.mile2Outlet.text = mile2Text
        
       
            
            var trunc = race.markString
            var startDot = trunc.lastIndex(of: ".")
            if let sd = startDot{
                trunc = String(trunc[trunc.startIndex..<sd])
            }
                
            
        
//        var trunc = race.markString
//        if !trunc.isEmpty{
//        trunc.removeLast()
//        }
//        if !trunc.isEmpty{
//        trunc.removeLast()
//        }
        
        if let m2 = race.mile2{
            if !trunc.isEmpty{
                var split2 = findSplit(t1: m2, t2: trunc)
                
                if split != ""{
                    var m3PlusMinus = findSplitPlusMinus(t1: split , t2: split2)
                    if m3PlusMinus.starts(with: "-"){
                        cell.mile3PlusMinusOutlet.backgroundColor = UIColor.green
                    }
                    cell.mile3SplitOutlet.text = "(\(split2))"
                    cell.mile3PlusMinusOutlet.text = "\(m3PlusMinus)"
                }
                else{
                    cell.mile3SplitOutlet.text = "(\(split2))"
                }
            }
        }
        
        if let d = race.date{
            var dateString =  dateFormatter.string(from: d)
            cell.dateOutlet.text = dateString
        }
        else{
        
        for meet in AppData.meets{
            if meet.name == race.meetName{
                // Convert Date to String
                var dateString =  dateFormatter.string(from: meet.date)
                cell.dateOutlet.text = dateString
                break
            }
        }
        }
        
        return cell
        
    }
    
    func findSplit(t1: String, t2: String)->String{
        let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"

        if let date1 = formatter.date(from: t1), let date2 = formatter.date(from: t2){
            
            
            
            
            let elapsedTime = Int(date2.timeIntervalSince(date1))
            print(elapsedTime)
            
            let minutes = elapsedTime/60
            let seconds = elapsedTime%60
            var split = ""
            if seconds<10{
                split = "\(minutes):0\(seconds)"
            }
            else{
                split = "\(minutes):\(seconds)"
            }
            return split
        }
        else{
            return ""
        }
        
    }
    
    func findSplitPlusMinus(t1: String, t2: String)->String{
        let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"

        if let date1 = formatter.date(from: t1), let date2 = formatter.date(from: t2){
            
            
            let elapsedTime = Int(date2.timeIntervalSince(date1))
            print(elapsedTime)
            
            var minutes = elapsedTime/60
            var seconds = elapsedTime%60
            var split = "+"
            if minutes < 0 || seconds < 0{
                split = "-"
            }
            minutes = abs(minutes)
            seconds = abs(seconds)
            
            if seconds<10{
                split += "\(minutes):0\(seconds)"
            }
            else{
                split += "\(minutes):\(seconds)"
            }
            return split
        }
        else{
            return ""
        }
        
    }
    


}
