//
//  GradesCollectionViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 9/3/22.
//

import UIKit

class GradesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var gradeLabel: UILabel!
    
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
    
    func configure(grade: String){
        gradeLabel.text = grade
    }
}
