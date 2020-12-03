//
//  CalendarMainCollectionViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class CalendarMainCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CalendarMainCollectionViewCell"
    
    @IBOutlet weak var monthNumLabel: UILabel!
    @IBOutlet weak var monthTextLabel: UILabel!
    
    func layoutCell(monthNum: String, monthText: String) {
        monthNumLabel.text = monthNum
        monthTextLabel.text = monthText
    }
    
}
