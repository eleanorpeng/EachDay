//
//  JournalDetailTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class JournalDetailTableViewCell: UITableViewCell {

    static let identifier = "JournalDetailTableViewCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var journalTitleLabel: UILabel!
    @IBOutlet weak var journalContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layoutCell(date: String, day: String, title: String, content: String) {
        dateLabel.text = date
        dayLabel.text = day
        journalTitleLabel.text = title
        journalContentLabel.text = content
    }

}
