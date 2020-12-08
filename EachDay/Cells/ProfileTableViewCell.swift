//
//  ProfileTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func layoutCell(profileImage: UIImage, name: String) {
        userProfileImageView.image = profileImage
        userNameLabel.text = name
    }
}
