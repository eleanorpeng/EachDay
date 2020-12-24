//
//  RoutineReminderTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/24.
//

import UIKit

class RoutineReminderTableViewCell: UITableViewCell {
    static let identifier = "RoutineReminderTableViewCell"
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var routineSwitch: UISwitch!
   
    @IBAction func switchValueChanged(_ sender: Any) {
        switchStatus = routineSwitch.isOn
        UserDefaults.standard.setValue(switchStatus, forKey: EPUserDefaults.hasDailyReminder.rawValue)
        self.delegate?.getSwitchStatus(status: switchStatus)
        print("Switch: \(routineSwitch.isOn)")
        
    }
    var switchStatus = false
    weak var delegate: RoutineReminderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func layoutSwitchCell(switchStatus: Bool) {
        timeLabel.isHidden = true
        routineSwitch.isHidden = false
        label.text = "Daily Reminder Enabled"
        routineSwitch.isOn = UserDefaults.standard.bool(forKey: EPUserDefaults.hasDailyReminder.rawValue)
    }
    
    func layoutReminderCell(time: String) {
        timeLabel.isHidden = false
        routineSwitch.isHidden = true
        label.text = "Reminder Time"
        timeLabel.text = time
         
    }

}

protocol RoutineReminderTableViewCellDelegate: AnyObject {
    func getSwitchStatus(status: Bool)
}
