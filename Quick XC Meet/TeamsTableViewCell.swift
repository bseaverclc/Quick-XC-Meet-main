//
//  TeamsTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/13/22.
//

import UIKit

class TeamsTableViewCell: UITableViewCell {

    @IBOutlet weak var placeOutlet: UILabel!
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
 
    @IBOutlet weak var mile1ButtonOutlet: UIButton!
    @IBOutlet weak var mile2ButtonOutlet: UIButton!
    
    @IBOutlet weak var mile2SplitLabel: UILabel!
    @IBOutlet weak var mile3SplitLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mile1ButtonOutlet.setTitleColor(UIColor.red, for:  .disabled)
        mile2ButtonOutlet.setTitleColor(UIColor.red, for:  .disabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(ath: Athlete, race: Race){
        var split = ""
        mile1ButtonOutlet.isEnabled = true
        mile2ButtonOutlet.isEnabled = true
        
        if AppData.mySchool != ath.schoolFull  && Meet.canManage == false{
            mile1ButtonOutlet.isEnabled = false
            mile2ButtonOutlet.isEnabled = false
        }
        
        placeOutlet.text = "\(race.place ?? 999)"
        nameOutlet.text = "\(ath.last), \(ath.first) (\(ath.grade))"
        timeOutlet.text = race.markString
       
        if race.mile1 != nil{
            mile1ButtonOutlet.isEnabled = false
            
            
        }
        if race.mile2 != nil{
            mile2ButtonOutlet.isEnabled = false
            
        }
        mile1ButtonOutlet.setTitle(race.mile1 ?? "Mile 1", for: .normal)
        mile2ButtonOutlet.setTitle(race.mile2 ?? "Mile 2", for: .normal)
        let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"

        mile2SplitLabel.text = ""
        mile2SplitLabel.backgroundColor = UIColor.clear
        if let m1 = race.mile1, let m2 = race.mile2{
            let date1 = formatter.date(from: m1) ?? Date()
            let date2 = formatter.date(from: m2) ?? Date()
        
        let elapsedTime = Int(date2.timeIntervalSince(date1))
        print(elapsedTime)
            
        
        let minutes = elapsedTime/60
        let seconds = elapsedTime%60
        
            
            
        if seconds<10{
        split = "\(minutes):0\(seconds)"
            
        }
        else{
            split = "\(minutes):\(seconds)"
            
        }
            // Calculate +/- for Mile 2
            var splitDiff = ""
            if  let date3 = formatter.date(from: split){
                let elapsedTime2 = Int(date3.timeIntervalSince(date1))
                var minutes2 = elapsedTime2/60
                var seconds2 = elapsedTime2%60
                var sign = "+"
                if minutes2 < 0 || seconds2 < 0{
                    minutes2 = abs(minutes2)
                    seconds2 = abs(seconds2)
                    sign = "-"
                    mile2SplitLabel.backgroundColor = UIColor.green
                }
                
                if seconds2<10{
                    splitDiff = "\(minutes2):0\(seconds2)"
                    
                }
                else{
                    splitDiff = "\(minutes2):\(seconds2)"
                    
                }
                
                mile2SplitLabel.text = "(\(split))    \(sign)\(splitDiff)"
            }
            else{
                mile2SplitLabel.text = "(\(split))"
            }
           
        }
        
        //Calculate Mile3 split
    
        mile3SplitLabel.text = ""
        mile3SplitLabel.backgroundColor = UIColor.clear
        
        
        if let m2 = race.mile2{
            let date1 = formatter.date(from: m2)!
            var trunc = race.markString
            var startDot = trunc.lastIndex(of: ".")
            if let sd = startDot{
                trunc = String(trunc[trunc.startIndex..<sd])
                
            }
//            if !trunc.isEmpty{
//            trunc.removeLast()
//            }
//            if !trunc.isEmpty{
//            trunc.removeLast()
//            }
            
            
            if let date2 = formatter.date(from: trunc){
        let elapsedTime = Int(date2.timeIntervalSince(date1))
       // print(elapsedTime)
        
        let minutes = elapsedTime/60
        let seconds = elapsedTime%60
        var split2 = ""
        if seconds<10{
        split2 = "\(minutes):0\(seconds)"
        }
        else{
            split2 = "\(minutes):\(seconds)"
        }
                
                //calulate +/- for last mile
                if split != ""{
                    
                    
                    var splitDiff2 = ""
                    let date4 = formatter.date(from: split) ?? Date()
                    let date3 = formatter.date(from: split2) ?? Date()
                    let elapsedTime2 = Int(date3.timeIntervalSince(date4))
                    var minutes2 = elapsedTime2/60
                    var seconds2 = elapsedTime2%60
                    var sign = "+"
                    if minutes2 < 0 || seconds2 < 0{
                        minutes2 = abs(minutes2)
                        seconds2 = abs(seconds2)
                        sign = "-"
                        mile3SplitLabel.backgroundColor = UIColor.green
                    }
                    
                    if seconds2<10{
                        splitDiff2 = "\(minutes2):0\(seconds2)"
                        
                    }
                    else{
                        splitDiff2 = "\(minutes2):\(seconds2)"
                        
                    }
                    
                    
                    
                    mile3SplitLabel.text = "(\(split2))   \(sign)\(splitDiff2)"
                }
                else{
                    mile3SplitLabel.text = "(\(split2))"
                }
        }
        }
        else if let m1 = race.mile1{
            let date1 = formatter.date(from: m1)!
            var trunc = race.markString
            if !trunc.isEmpty{
            trunc.removeLast()
            }
            if !trunc.isEmpty{
            trunc.removeLast()
            }
            if let date2 = formatter.date(from: trunc){
        let elapsedTime = Int(date2.timeIntervalSince(date1))
       // print(elapsedTime)
        
        let minutes = elapsedTime/60
        let seconds = elapsedTime%60
        var split2 = ""
        if seconds<10{
        split2 = "\(minutes):0\(seconds)"
        }
        else{
            split2 = "\(minutes):\(seconds)"
        }
                if split != ""{
                    
                    
                    var splitDiff2 = ""
                    let date4 = formatter.date(from: split) ?? Date()
                    let date3 = formatter.date(from: split2) ?? Date()
                    let elapsedTime2 = Int(date3.timeIntervalSince(date4))
                    var minutes2 = elapsedTime2/60
                    var seconds2 = elapsedTime2%60
                    var sign = "+"
                    if minutes2 < 0 || seconds2 < 0{
                        minutes2 = abs(minutes2)
                        seconds2 = abs(seconds2)
                        sign = "-"
                        mile3SplitLabel.backgroundColor = UIColor.green
                    }
                    
                    if seconds2<10{
                        splitDiff2 = "\(minutes2):0\(seconds2)"
                        
                    }
                    else{
                        splitDiff2 = "\(minutes2):\(seconds2)"
                        
                    }
                    
                    
                    
                    mile3SplitLabel.text = "(\(split2))   \(sign)\(splitDiff2)"
                }
                else{
                    mile3SplitLabel.text = "(\(split2))"
                }
        }
        }
        
    }

}
