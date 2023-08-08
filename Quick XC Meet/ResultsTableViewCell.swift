//
//  ResultsTableViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/27/22.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var placeOutlet: UILabel!
    @IBOutlet weak var SchoolOutlet: UILabel!

    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var timeLabelOutlet: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(place: Int, inits: String, time: String, name: String){
        //print("inside results configure \(place)")
        nameOutlet.backgroundColor = UIColor.white
        SchoolOutlet.backgroundColor = UIColor.white
        
        if name.contains("?"){
            nameOutlet.backgroundColor = UIColor.yellow
            SchoolOutlet.backgroundColor = UIColor.yellow
        }
        if inits == "???"{
            nameOutlet.backgroundColor = UIColor.red
            SchoolOutlet.backgroundColor = UIColor.red
            
        }
        placeOutlet.text = "\(place)"
        SchoolOutlet.text = inits
        timeLabelOutlet.text = time
        nameOutlet.text = name
    
        
        
    }
    
    
    
    
    

}
