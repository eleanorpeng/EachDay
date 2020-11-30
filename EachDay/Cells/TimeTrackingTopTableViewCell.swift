//
//  TimeTrackingTopTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/30.
//

import UIKit

class TimeTrackingTopTableViewCell: UITableViewCell {
    static let identifier = "TimeTrackingTopTableViewCell"
    weak var delegate: TimeTrackingTopTableViewCellDelegate?
    @IBOutlet weak var activityLabel: PaddingableUILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityElapsedTimeLabel: UILabel!
    @IBOutlet weak var activityDurationLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBAction func pauseButtonClicked(_ sender: Any) {
        self.delegate?.pauseTiming()
    }
    @IBAction func stopButtonClicked(_ sender: Any) {
        self.delegate?.stopTiming()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func layoutCell(activity: String, description: String, elapsedTime: String, duration: String, color: UIColor) {
        activityLabel.text = activity
        descriptionLabel.text = description
        activityElapsedTimeLabel.text = elapsedTime
        activityDurationLabel.text = duration
        activityLabel.backgroundColor = color
        activityElapsedTimeLabel.textColor = UIColor(r: 247, g: 174, b: 0)
    }
    
    func configurePauseButtonImage(image: UIImage) {
        pauseButton.setImage(image, for: .normal)
    }

}

protocol TimeTrackingTopTableViewCellDelegate: AnyObject {
    func stopTiming()
    func pauseTiming()
}
