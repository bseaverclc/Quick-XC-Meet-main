//
//  HomeViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/26/22.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var meet: Meet!
    var selectedRace: String?
    var selectedRow: Int = 0
    var selectedRaceGender : String?
    //var races = [String]()
  
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "\(meet.name)"
        
//        for (key, _) in meet.races2{
//            races.append(key)
//        }
        AppData.allAthletes.removeAll()
        for (key,_) in meet.schools{
            for sch in AppData.schoolsNew{
                if key == sch.full {
                    for a in sch.athletes{
                        AppData.allAthletes.append(a)
                    }
                    break
                }
            }
            
        }
        for s in AppData.schoolsNew{
            if s.full == "NO SCHOOL"{
                for a in s.athletes{
                    AppData.allAthletes.append(a)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeet), name: Notification.Name("notifyMeetChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAllAthletes), name: Notification.Name("notifyAthleteChanged"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meet.races.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.backgroundColor = UIColor.white
        if meet.beenScored[indexPath.row]{
            cell.backgroundColor = UIColor.green
        }
        cell.textLabel?.text = meet.races[indexPath.row]
        cell.detailTextLabel?.text = meet.racesGenders[indexPath.row]
        return cell
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRace =  tableView.cellForRow(at: indexPath)?.textLabel?.text
        selectedRow = indexPath.row
       selectedRaceGender = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
       
        
        performSegue(withIdentifier: "editRaceSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //var sentAthletes = [Athlete]()
        if segue.identifier != "unwindToHomeSegue"{
        let nvc = segue.destination as! RaceEditViewController
            nvc.meet = meet
      
        //nvc.eventAthletes = sentAthletes
       // nvc.allAthletes = athletes
        nvc.selectedRace = selectedRace!
            nvc.selectedRaceGender = selectedRaceGender!
            
            nvc.selectedRow = selectedRow
        
            
        }
    }
  
    @objc func updateMeet(){
        print("calling update Meet")
        for m in AppData.meets{
            if m.uid == meet.uid{
                meet = m
                tableView.reloadData()
                break
            }
        }
        
        
    }
    
    @objc func updateAllAthletes(){
        print("Home VC updateAllAthletes being called")
        AppData.allAthletes.removeAll()
        for (key,_) in meet.schools{
            for sch in AppData.schoolsNew{
                if key == sch.full {
                    for a in sch.athletes{
                        AppData.allAthletes.append(a)
                    }
                    break
                }
            }
            
        }
        for s in AppData.schoolsNew{
            if s.full == "NO SCHOOL"{
                for a in s.athletes{
                    AppData.allAthletes.append(a)
                }
            }
        }
    }

}
