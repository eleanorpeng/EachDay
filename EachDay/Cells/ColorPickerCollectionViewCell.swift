//
//  ColorPickerCollectionViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/17.
//

import UIKit

class ColorPickerCollectionViewCell: UICollectionViewCell {

    weak var delegate: ColorPickerCollectionViewCellDelegate?
    @IBOutlet weak var colorButton: UIButton!
    
    @IBAction func buttonClicked(_ sender: Any) {
        self.delegate?.handleColorButtonClicked()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func layoutCell(color: UIColor) {
        colorButton.backgroundColor = color
    }
}

protocol ColorPickerCollectionViewCellDelegate: AnyObject {
    func handleColorButtonClicked()
}
