//
//  TagSelectionTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class TagSelectionTableViewCell: UITableViewCell {

    static let identifier = "TagSelectionTableViewCell"
    var buttonSelected = false
    weak var delegate: TagSelectionTableViewCellDelegate?
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIImageView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBAction func selectionButtonClicked(_ sender: Any) {
        buttonSelected = !buttonSelected
        if buttonSelected {
            showIndicator()
            self.delegate?.handleSelected(sender: sender)
        } else {
            hideIndicator()
            self.delegate?.handleDeselected(sender: sender)
        }
        
    }
    @IBAction func moreButtonClicked(_ sender: Any) {
        self.delegate?.handleMoreButton(sender: sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func layoutCell(tag: String) {
        tagLabel.text = tag
        selectionIndicator.isHidden = true
    }
    
    func showIndicator() {
        selectionIndicator.isHidden = false
    }
    
    func hideIndicator() {
        selectionIndicator.isHidden = true
    }

}

protocol TagSelectionTableViewCellDelegate: AnyObject {
    func handleMoreButton(sender: Any)
    func handleSelected(sender: Any)
    func handleDeselected(sender: Any)
}
