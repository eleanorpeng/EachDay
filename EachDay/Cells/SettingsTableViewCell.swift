//
//  SettingsTableViewCell.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    static let identifier = "SettingsTableViewCell"
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var settingDescriptionLabel: UILabel!
    weak var delegate: SettingsTableViewCellDelegate?
    var datePicker: UIDatePicker!
    var selectedTime: Date?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func layoutCell(icon: String, setting: String, description: String) {
        iconImageView.image = UIImage(named: icon)
        settingLabel.text = setting
        settingDescriptionLabel.text = description
        settingDescriptionLabel.textColor = .lightGray
        settingDescriptionLabel.isHidden = false
    }
    
    func setUpDailyReminderCell(icon: String, setting: String, description: String) {
        iconImageView.image = UIImage(named: icon)
        settingLabel.text = setting
        settingDescriptionLabel.isHidden = true
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 200))
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(dateChanged), for: .touchUpInside)
        reminderTextField.inputView = datePicker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
    }

    @objc func dateChanged() {
        reminderTextField.text = "\(datePicker.date)"
    }
    
    @objc func datePickerDone() {
        self.delegate?.getSelectedTime(time: datePicker.date)
        reminderTextField.resignFirstResponder()
    }
}

protocol SettingsTableViewCellDelegate: AnyObject {
    func getSelectedTime(time: Date)
}
