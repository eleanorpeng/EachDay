//
//  TimeTrackingMainCollectionViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit

class TimeTrackingMainCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimeTrackingMainCollectionViewCell"
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    func layoutCell(imageName: String, label: String) {
        iconImage.image = UIImage(named: imageName)
        iconLabel.text = label
    }
    
}
