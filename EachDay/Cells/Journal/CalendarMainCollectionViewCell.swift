//
//  CalendarMainCollectionViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class CalendarMainCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CalendarMainCollectionViewCell"
    weak var delegate: CalendarMainCollectionViewCellDelegate?
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var monthNumLabel: UILabel!
    @IBOutlet weak var monthTextLabel: UILabel!
    @IBAction func changeColorButtonClicked(_ sender: Any) {
        self.delegate?.handleChangeColorButton(sender: sender)
    }
    
    func layoutCell(monthNum: String, monthText: String, color: UIColor) {
        monthNumLabel.text = monthNum
        monthTextLabel.text = monthText
        contentView.backgroundColor = color
    }
    
}

protocol CalendarMainCollectionViewCellDelegate: AnyObject {
    func handleChangeColorButton(sender: Any)
}
