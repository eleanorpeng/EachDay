//
//  AddNewTagTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/29.
//

import UIKit

class AddNewTagTableViewCell: UITableViewCell {
    weak var delegate: AddNewTagTableViewCellDelegate?
    static let identifier = "AddNewTagTableViewCell"
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var addNewTagButton: NSLayoutConstraint!
    @IBAction func addNewTagButtonClicked(_ sender: Any) {
        self.delegate?.addNewTag()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

protocol AddNewTagTableViewCellDelegate: AnyObject {
    func addNewTag()
}
