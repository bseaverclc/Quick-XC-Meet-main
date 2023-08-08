//
//  SchoolScoreCollectionViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/13/22.
//

import UIKit

class SchoolScoreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var schoolLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView(frame: bounds)
          self.backgroundView = view
                
          let coloredView = UIView(frame: bounds)
          coloredView.backgroundColor = UIColor.systemBlue
          self.selectedBackgroundView = coloredView
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 10
    }
    
    func configure(school: String){
        schoolLabel.text = school
        
    }
}
