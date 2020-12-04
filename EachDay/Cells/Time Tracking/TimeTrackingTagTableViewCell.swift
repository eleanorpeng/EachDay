//
//  TimeTrackingTagTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/29.
//

import UIKit

class TimeTrackingTagTableViewCell: UITableViewCell {

    static let identifier = "TimeTrackingTagTableViewCell"
    @IBOutlet weak var tagLabel: UILabel!
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
