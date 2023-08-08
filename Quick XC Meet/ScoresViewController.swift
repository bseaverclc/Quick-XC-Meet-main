//
//  ScoresViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/9/22.
//

import UIKit

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
  
    
    
    var resultsAthletes : [Athlete]!
    var displayedAthletes  = [Athlete]()
    var meet : Meet!
    var selectedRace: String!
    var schoolsLabels = [UILabel]()
    var scoresLabels = [UILabel]()
    
   
    
    
    
    @IBOutlet weak var numRunnersSeg: UISegmentedControl!
    @IBOutlet weak var numPushersSeg: UISegmentedControl!
    @IBOutlet weak var gradesScoreSeg: UISegmentedControl!
    @IBOutlet weak var genderSeg: UISegmentedControl!
    @IBOutlet weak var ghostRunnerSeg: UISegmentedControl!
    
    
   
    @IBOutlet weak var schoolsStackView: UIStackView!
    @IBOutlet weak var pointsStackView: UIStackView!
    
    @IBOutlet weak var collectionOutlet: UICollectionView!
    
    @IBOutlet weak var gradesCollectionOutlet: UICollectionView!
    
    var schoolInits : [String]!
    var selectedInits = [String]()
    var selectedScores = [Int]()
    var finishers = [Int]()
    var selectedFinishers = [String]()
    
    var allGrades = [Int]()
    var selectedGrades = [Int]()
    var didSelectAllGrades = false
    
   // @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Score Settings"
       // tableView.delegate = self
        //tableView.dataSource = self
        collectionOutlet.delegate = self
        collectionOutlet.dataSource = self
        collectionOutlet.allowsMultipleSelection = true
        
        gradesCollectionOutlet.delegate = self
        gradesCollectionOutlet.dataSource = self
        gradesCollectionOutlet.allowsMultipleSelection = true
        
        for i in 5...13{
            allGrades.append(i)
        }
        
//        for (key,value) in meet.schools{
//            selectSchoolStackView.addArrangedSubview(UIButton()
//        }
       
    }
    
    @IBAction func scoreAction(_ sender: UIButton) {
       
        
        
        displayedAthletes.removeAll()
        selectedInits.removeAll()
        selectedScores.removeAll()
        finishers.removeAll()
        selectedFinishers.removeAll()
    
        for path in collectionOutlet.indexPathsForSelectedItems!{
            selectedInits.append(schoolInits[path.row])
            selectedScores.append(0)
            finishers.append(0)
            selectedFinishers.append("")
        }
        
        selectedGrades.removeAll()
        didSelectAllGrades = false
        for path in gradesCollectionOutlet.indexPathsForSelectedItems!{
            selectedGrades.append(path.row + 5)
            if path.row == 8{
                didSelectAllGrades = true
            }
        }
        
        if selectedGrades.count == 0{
            let alert = UIAlertController(title: "Error!", message: "You must selected grades to score", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        for ath in resultsAthletes{
            if selectedInits.contains(ath.school){
                for race in ath.races{
                    // if any grade and any gender
                    if didSelectAllGrades && genderSeg.selectedSegmentIndex == 2{
                        if race.name == selectedRace && race.meetName == meet.name{
                                displayedAthletes.append(ath)
                        }
                    }
                    // if any grade, but a selected gender
                    else if didSelectAllGrades{
                        if race.name == selectedRace && race.meetName == meet.name && genderSeg.titleForSegment(at: genderSeg.selectedSegmentIndex) == ath.gender{
                                displayedAthletes.append(ath)
                        }

                    }
                    // if specific grade and any gender
                    else if genderSeg.selectedSegmentIndex == 2{
                        if race.name == selectedRace && race.meetName == meet.name && selectedGrades.contains(ath.grade) {
                                displayedAthletes.append(ath)
                        }
                    }
                    // if specific grade and specific gender
                    else{
                        if race.name == selectedRace && race.meetName == meet.name && selectedGrades.contains(ath.grade) && genderSeg.titleForSegment(at: genderSeg.selectedSegmentIndex) == ath.gender{
                                displayedAthletes.append(ath)
                        }
                        
                    }
                }
            }
        }
        
        // add up the number of finishers from each school
        var b = 0
        while b < displayedAthletes.count{
            for i in 0..<selectedInits.count{
                if selectedInits[i] == displayedAthletes[b].school{
                    finishers[i] += 1
                    break
                }
            }
            b += 1
        }
        
        // if no ghost runners selected
        // Remove all athletes from schools with not enough Runners and give the school a score of 100000
        if ghostRunnerSeg.selectedSegmentIndex != 0{
        for i in 0..<selectedInits.count{
            if finishers[i] < numRunnersSeg.selectedSegmentIndex + 1{
                selectedScores[i] == 1000
                displayedAthletes.removeAll(where: {$0.school == selectedInits[i]})
            }
        }
        }
        
        // reset each finishers back to zero
        for i in 0..<finishers.count{
            finishers[i] = 0
        }
        
        
        var a = 0
        while a < displayedAthletes.count{
            for i in 0..<selectedInits.count{
                if selectedInits[i] == displayedAthletes[a].school{
                    finishers[i] += 1
                
                    // remove all the non pushers
                    if finishers[i] > numRunnersSeg.selectedSegmentIndex + 1 + numPushersSeg.selectedSegmentIndex && displayedAthletes[a].school != "???"{
                        displayedAthletes.remove(at: a)
                        a -= 1
                        break
                        
                    }
                    else if finishers[i] <= numRunnersSeg.selectedSegmentIndex + 1{
                        selectedScores[i] += a+1
                        
                    }
                    if finishers[i] <= numRunnersSeg.selectedSegmentIndex + 1{
                    selectedFinishers[i] += "\(a+1),"
                    }
                    else{
                        selectedFinishers[i] += "(\(a+1)),"
                    }
                    
                }
            }
            a += 1
        }
        
      
      
       // scoresSetUp()
        // Add ghost runners if selected
        if ghostRunnerSeg.selectedSegmentIndex == 0{
        for i in 0 ..< selectedInits.count{
          
            
                while finishers[i] < numRunnersSeg.selectedSegmentIndex + 1{
                    selectedScores[i] += displayedAthletes.count + 1
                    selectedFinishers[i] += "\(displayedAthletes.count + 1),"
                    print("added ghost runner")
                    finishers[i] += 1
                }
            }
                //scoresLabels[i].text = "\(selectedScores[i])"
            
        }
        
        // change all team non scores to 100000
        for i in 0..<selectedScores.count{
            if selectedScores[i] == 0{
                selectedScores[i] = 100000
            }
        }
        
        //tableView.reloadData()
        print(selectedInits)
        print(selectedScores)
        
       performSegue(withIdentifier: "actualScoresSegue", sender: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionOutlet{
            return schoolInits.count
            
        }
        else{
            return allGrades.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionOutlet{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collCell", for: indexPath) as! SchoolScoreCollectionViewCell
            cell.configure(school: schoolInits[indexPath.row])
            
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gradesCell", for: indexPath) as! GradesCollectionViewCell
            if indexPath.row < 8{
                cell.configure(grade: "\(allGrades[indexPath.row])")
            }
                               else{
                    cell.configure(grade: "All")
                                   collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                }
           return cell
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedAthletes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func scoresSetUp(){
 //       scoresLabels.removeAll()
 //       schoolsLabels.removeAll()
//        for i in 0 ..< finishers.count{
//            finishers[i] = 0
//        }
//        for view in schoolsStackView.arrangedSubviews{
//            view.removeFromSuperview()
//
//        }
//        for view in pointsStackView.arrangedSubviews{
//            view.removeFromSuperview()
//        }
//        for inits in selectedInits{
//
//            let schoolLabel = UILabel()
//            schoolLabel.text = inits
//            schoolLabel.font = UIFont.preferredFont(forTextStyle: .title3)
//            schoolLabel.numberOfLines = 1
//            schoolLabel.textAlignment = .center
//            schoolLabel.adjustsFontSizeToFitWidth = true
//            schoolLabel.minimumScaleFactor = 0.5
//            schoolsLabels.append(schoolLabel)
//            let scoreLabel = UILabel()
//            scoreLabel.text = "0"
//            scoreLabel.font = UIFont.preferredFont(forTextStyle: .title3)
//            scoreLabel.numberOfLines = 1
//            scoreLabel.textAlignment = .center
//            scoreLabel.adjustsFontSizeToFitWidth = true
//            scoreLabel.minimumScaleFactor = 0.5
//            scoresLabels.append(scoreLabel)
//        }
//        for schLab in schoolsLabels{
//           schoolsStackView.addArrangedSubview(schLab)
//        }
//
//        for scoLab in scoresLabels{
//            pointsStackView.addArrangedSubview(scoLab)
//        }
        if ghostRunnerSeg.selectedSegmentIndex != 0{
        for i in 0 ..< selectedInits.count{
          
            
                while finishers[i] < numRunnersSeg.selectedSegmentIndex + 1{
                    selectedScores[i] += displayedAthletes.count + 1
                    selectedFinishers[i] += "\(displayedAthletes.count + 1),"
                    print("added ghost runner")
                    finishers[i] += 1
                }
            }
                //scoresLabels[i].text = "\(selectedScores[i])"
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nvc = segue.destination as! ActualScoresViewController
        nvc.displayedAthletes = displayedAthletes
        nvc.selectedRace = selectedRace
        nvc.meet = meet
        nvc.selectedInits = selectedInits
        nvc.selectedScores = selectedScores
        nvc.selectedFinishers = selectedFinishers
        
        nvc.selectedGrades = selectedGrades
        nvc.scorers = numRunnersSeg.selectedSegmentIndex + 1
        nvc.pushers = numPushersSeg.selectedSegmentIndex
        nvc.genders = genderSeg.titleForSegment(at: genderSeg.selectedSegmentIndex)
        
    }

}
