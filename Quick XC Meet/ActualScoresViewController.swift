//
//  ActualScoresViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 9/3/22.
//

import UIKit

struct TeamScore{
    var inits: String
    var score: Int
    var finishers: String
}


class ActualScoresViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
 
    
    @IBOutlet weak var athletesTableView: UITableView!
    @IBOutlet weak var scoresTableView: UITableView!
    var displayedAthletes: [Athlete]!
    var selectedRace: String!
    var meet: Meet!
    var selectedInits: [String]!
    var selectedScores: [Int]!
    var selectedFinishers: [String]!
    var teamScores = [TeamScore]()
    
    var scorers: Int!
    var pushers: Int!
    var selectedGrades: [Int]!
    var genders: String!
    
    
    
    @IBOutlet weak var meetNameOutlet: UILabel!
    @IBOutlet weak var scorersOutlet: UILabel!
    @IBOutlet weak var pushersOutlet: UILabel!
    @IBOutlet weak var gradesOutlet: UILabel!
    @IBOutlet weak var genderOutlet: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetNameOutlet.text = meet.name
        self.title = selectedRace!
        scorersOutlet.text = "\(scorers!)"
        pushersOutlet.text = "\(pushers!)"
        var gradesString = ""
        if selectedGrades.contains(13){
            gradesString = "All"
        }
        else{
        for g in selectedGrades{
            gradesString += "\(g),"
        }
            if gradesString.count != 0{
                gradesString.removeLast()
            }
        }
        gradesOutlet.text = gradesString
        genderOutlet.text = genders
        
        scoresTableView.delegate = self
        scoresTableView.dataSource = self
        
        athletesTableView.delegate = self
        athletesTableView.dataSource = self
        for i in 0..<selectedFinishers.count{
            if selectedFinishers[i].count > 0{
            selectedFinishers[i].removeLast()
            }
        }
        
        for i in 0 ..< selectedInits.count{
            teamScores.append(TeamScore(inits: selectedInits[i], score: selectedScores[i], finishers: selectedFinishers[i]))
        }
        
        teamScores.sort(by: {$0.score < $1.score})
        
        

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == athletesTableView{
            return displayedAthletes.count
        }
        else{
            return selectedInits.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == athletesTableView{
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! ScoresTableViewCell
        
        
        
        cell.rowLabel.text = "\(indexPath.row + 1)"
        var ath = displayedAthletes[indexPath.row]
//        for i in 0 ..< selectedInits.count{
//            if ath.school == selectedInits[i]{
//                finishers[i] += 1
//                if finishers[i] <= numRunnersSeg.selectedSegmentIndex + 1{
//                selectedScores[i] += indexPath.row + 1
//                }
//
//            }
//        }
        
        
        for race in ath.races{
            if race.name == selectedRace && race.meetName == meet.name{
                cell.timeLabel.text = race.markString
                cell.nameLabel.text = "\(ath.last), \(ath.first) (\(ath.grade))"
                cell.initsLabel.text = ath.school
                break
            }
                
        }
       
       return cell
    }
    else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! ActualScoresTeamsTableViewCell
        cell.initsOutlet.text = teamScores[indexPath.row].inits
        
        if teamScores[indexPath.row].score == 100000{
            cell.scoresOutlet.text = "NA"
        }
        else{
            cell.scoresOutlet.text = "\(teamScores[indexPath.row].score)"
        }
        cell.finishersOutlet.text = teamScores[indexPath.row].finishers
        return cell
    }
    }
   

}
