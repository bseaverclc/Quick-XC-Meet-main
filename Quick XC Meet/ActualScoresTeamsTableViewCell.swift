//
//  ActualScoresTeamsTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 9/4/22.
//

import UIKit

class ActualScoresTeamsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var initsOutlet: UILabel!
    
    @IBOutlet weak var scoresOutlet: UILabel!
    
    @IBOutlet weak var finishersOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(){
        
    }

}
