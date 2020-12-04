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
    @IBOutlet weak var activityElapsedTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func layoutCell(activity: String, elapsedTime: String, duration: String, description: String) {
        activityLabel.text = activity
        activityElapsedTimeLabel.text = elapsedTime
        activityDurationLabel.text = duration
        descriptionLabel.text = description
        activityElapsedTimeLabel.textColor = .black
        activityLabel.backgroundColor = .clear
    }
    
    func changeActivityDurationColor(color: UIColor) {
        activityDurationLabel.textColor = color
    }
    
    func layoutFirstCell(activity: String, elapsedTime: String, duration: String, description: String, color: UIColor) {
        activityLabel.text = activity
        activityElapsedTimeLabel.text = elapsedTime
        activityDurationLabel.text = duration
        descriptionLabel.text = description
        activityLabel.backgroundColor = color
        activityDurationLabel.textColor = UIColor(r: 247, g: 174, b: 0)
    }

}
