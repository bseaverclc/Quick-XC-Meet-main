//
//  MeetTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/29/23.
//

import UIKit

class MeetTableViewCell: UITableViewCell {

    
    @IBOutlet weak var meetNameOutlet: UILabel!
    
    @IBOutlet weak var dateOutlet: UILabel!
    
    @IBOutlet weak var privateOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
