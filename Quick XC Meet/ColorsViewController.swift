//
//  ColorsViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/14/22.
//

import UIKit

extension ColorsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
        schoolColors[pickedRow] = viewController.selectedColor
        collectionView.reloadData()
    }
}

class ColorsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
  
    var schoolInits : [String]!
    var schoolColors : [UIColor]!
    var pickedRow = 0
    
    
    

    @IBOutlet weak var collectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Colors"
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ColorsVC will disappear")
        performSegue(withIdentifier: "unwindColorsSegue", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        schoolInits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! MyCollectionViewCell
        cell.contentView.backgroundColor = schoolColors[indexPath.row]
        cell.configure(text: schoolInits[indexPath.row])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedRow = indexPath.row
        showColorPicker()
        
    }
    
   
 
    func showColorPicker(){
        let picker = UIColorPickerViewController()
        

        // Setting the Initial Color of the Picker
        picker.selectedColor = UIColor.white

        // Setting Delegate
        picker.delegate = self

        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }


}
