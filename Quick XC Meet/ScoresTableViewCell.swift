//
//  ScoresTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/10/22.
//

import UIKit

class ScoresTableViewCell: UITableViewCell {

    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var initsLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(athlete : Athlete, row: Int){
        
    }

}
