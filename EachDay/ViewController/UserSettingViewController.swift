//
//  UserSettingViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit
import YPImagePicker

class UserSettingViewController: UIViewController {

    var profileImage: UIImage?
    var isDefaulProfileImage = true
    let settings = [Settings(icon: "notification", setting: "Daily Reminder", description: "00:00"),
                    Settings(icon: "tag", setting: "Journal Tags", description: ">"),
                    Settings(icon: "stopwatch", setting: "Time Tracker Categories", description: ">"),
                    Settings(icon: "passcode", setting: "Passcode", description: "Enable"),
                    Settings(icon: "face-recognition", setting: "FaceID", description: "Enable")
                    ]
    @IBOutlet weak var tableView: UITableView!
    let imagePicker = YPImagePicker()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    func initialSetUp() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
    }
    
    func imagePickerDonePicking() {
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                self.profileImage = photo.image
                self.isDefaulProfileImage = false
            }
            imagePicker.dismiss(animated: true, completion: {
                self.tableView.reloadData()
            })
        }
        
    }
}

extension UserSettingViewController: UITableViewDelegate, UITableViewDataSource, ProfileTableViewCellDelegate {
    func handleEditImage() {
        imagePickerDonePicking()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func editProfile() {
        performSegue(withIdentifier: "", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return 70
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return setUpProfileCell()
        } else {
            return setUpSettingCell(index: indexPath.row)
        }
    }
    
    func setUpProfileCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier)
        guard let profileCell = cell as? ProfileTableViewCell else { return cell! }
        profileCell.delegate = self
        profileCell.layoutCell(profileImage: (isDefaulProfileImage ? UIImage(named: "user")! : profileImage)!, name: "Eleanor Peng")
        return profileCell
    }
    
    func setUpSettingCell(index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier)
        guard let settingCell = cell as? SettingsTableViewCell else { return cell! }
        settingCell.layoutCell(icon: settings[index].icon,
                               setting: settings[index].setting,
                               description: settings[index].description)
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowTagSegue", sender: self)
    }
    
    func presentRoutineAlert() {
        
    }
    
}
