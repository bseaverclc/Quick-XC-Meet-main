//
//  MyUICollectionView.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 7/27/22.
//

import UIKit

class MyUICollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {

    private var labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "theCell", for: indexPath as IndexPath) as! MyCollectionViewCell
        
        cell.configure(text: "Hi")
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 100, height: 100)
    }

}
