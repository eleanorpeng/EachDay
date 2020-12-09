//
//  SettingsTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    static let identifier = "SettingsTableViewCell"
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func layoutCell(icon: String, setting: String, description: String) {
        iconImageView.image = UIImage(named: icon)
        settingLabel.text = setting
        settingDescriptionLabel.text = description
        settingDescriptionLabel.textColor = .lightGray
    }

}
