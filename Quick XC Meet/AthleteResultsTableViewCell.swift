//
//  AthleteResultsTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 9/4/22.
//

import UIKit

class AthleteResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var raceNameOutlet: UILabel!
    
    @IBOutlet weak var meetNameOutlet: UILabel!
    @IBOutlet weak var dateOutlet: UILabel!
    @IBOutlet weak var timeOutlet: UILabel!
    @IBOutlet weak var placeOutlet: UILabel!
  
    @IBOutlet weak var OverallTimeOutlet: UILabel!
    @IBOutlet weak var mile1Outlet: UILabel!
    @IBOutlet weak var mile2Outlet: UILabel!
    @IBOutlet weak var mile2SplitOutlet: UILabel!
    @IBOutlet weak var mile3SplitOutlet: UILabel!
    
    @IBOutlet weak var mile3PlusMinusOutlet: UILabel!
    @IBOutlet weak var mile2PlusMinusOutlet: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
