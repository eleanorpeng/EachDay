//
//  UserSettingTagsTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/9.
//

import UIKit

class UserSettingTagsTableViewCell: UITableViewCell {
    weak var delegate: UserSettingTagsTableViewCellDelegate?
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var moreButton: NSLayoutConstraint!
    @IBAction func moreButtonClicked(_ sender: Any) {
        self.delegate?.handleMoreButton(sender: sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layoutCell(tag: String) {
        tagLabel.text = tag
    }

}

protocol UserSettingTagsTableViewCellDelegate: AnyObject {
    func handleMoreButton(sender: Any)
}
