//
//  MyCollectionViewCell.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/27/22.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var initLabelOutlet: UILabel!
    
    
    func configure(text: String){
       // print("inside configure")
        initLabelOutlet.text = text
        
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 10
    }
}
