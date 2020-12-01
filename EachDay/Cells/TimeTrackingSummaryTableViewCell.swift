//
//  TimeTrackingSummaryTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/1.
//

import UIKit

class TimeTrackingSummaryTableViewCell: UITableViewCell {

    static let identifier = "TimeTrackingSummaryTableViewCell"
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func layoutCell(activity: String, time: String) {
        activityLabel.text = activity
        activityTimeLabel.text = time
    }
}
