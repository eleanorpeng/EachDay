//
//  JournalTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import UIKit

class JournalTableViewCell: UITableViewCell {

    static let identifier = "JournalTableViewCell"
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func layoutCell(month: String, date: String, title: String, content: String) {
        monthLabel.text = month
        dateLabel.text = date
        titleLabel.text = title
        contentLabel.text = content
    }
}
