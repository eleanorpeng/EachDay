//
//  TimeTrackingMainTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit

class TimeTrackingMainTableViewCell: UITableViewCell {
    static let identifier = "TimeTrackingMainTableViewCell"
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityDurationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func layoutCell(activity: String, activityDuration: String, time: String, description: String) {
        activityLabel.text = activity
        activityDurationLabel.text = activityDuration
        timeLabel.text = time
        descriptionLabel.text = description
    }
    
    func changeActivityDurationColor(color: UIColor) {
        activityDurationLabel.textColor = color
    }

}
