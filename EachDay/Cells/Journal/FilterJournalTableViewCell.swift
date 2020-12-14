//
//  FilterJournalTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/12.
//

import UIKit

class FilterJournalTableViewCell: UITableViewCell {

    static let identifier = "FilterJournalTableViewCell"
    @IBOutlet weak var tagLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func layoutCell(tag: String) {
        tagLabel.text = tag
    }

}
