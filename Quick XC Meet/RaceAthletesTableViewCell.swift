//
//  RaceAthletesTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/8/22.
//

import UIKit

class RaceAthletesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var initsOutlet: UILabel!
    @IBOutlet weak var gradeOutlet: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(athlete: Athlete)
    {
        nameOutlet.text = "\(athlete.last), \(athlete.first)"
        initsOutlet.text = athlete.school
        gradeOutlet.text = "   (\(athlete.grade))"
    }

}
