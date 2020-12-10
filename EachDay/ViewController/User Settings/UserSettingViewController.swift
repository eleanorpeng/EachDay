//
//  UserSettingViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit
import YPImagePicker

class UserSettingViewController: UIViewController, PasscodeViewControllerDelegate {
    
    var hasPasscode = false {
        didSet {
            settings?[3].description = hasPasscode ? "Enable" : "Disable"
            tableView.reloadData()
        }
    }
    
    var isDisablingPasscode = false
    var isTimeTracking = false
    var profileImage: UIImage?
    var isDefaulProfileImage = true
    var settings: [Settings]?
    var isEditingPasscode = false
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
        settings = [Settings(icon: "notification", setting: "Daily Reminder", description: "00:00"),
                    Settings(icon: "tag", setting: "Journal Tags", description: ">"),
                    Settings(icon: "stopwatch", setting: "Time Tracker Categories", description: ">"),
                    Settings(icon: "passcode", setting: "Passcode", description: "Disable"),
                    Settings(icon: "face-recognition", setting: "FaceID", description: "Enable")
                    ]
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TagSelectionViewController {
            destination.fromUserSetting = true
            destination.isTimeTracking = isTimeTracking
            print(isTimeTracking)
        }
        
        if let destination = segue.destination as? PasscodeViewController {
            destination.delegate = self
            destination.isEditingPasscode = isEditingPasscode
            destination.isDisablingPasscode = isDisablingPasscode
            destination.isInitial = false
        }
    }
    
    func handlePasscodeSet(hasSet: Bool) {
        hasPasscode = hasSet
    }
    
    func getPasscodeState(isEditing: Bool, isDisabling: Bool) {
        self.isEditing = isEditing
        self.isDisablingPasscode = isDisabling
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
        print(settings?[index].description)
        settingCell.layoutCell(icon: settings?[index].icon ?? "",
                               setting: settings?[index].setting ?? "",
                               description: settings?[index].description ?? "")
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 {
            isTimeTracking = true
        } else {
            isTimeTracking = false
        }
        switch indexPath.row {
        case 0:
            return
        case 1:
            performSegue(withIdentifier: "ShowTagsSegue", sender: self)
        case 2:
            performSegue(withIdentifier: "ShowTagsSegue", sender: self)
        case 3:
            presentPasscodeAlert()
        case 4:
            print("4")
        default:
            print("Nothing")
        }
        
    }
    
    func presentRoutineAlert() {
        
    }
    
    func presentPasscodeAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: hasPasscode ? "Disable" : "Enable", style: .default, handler: { _ in
            if self.hasPasscode {
                self.isDisablingPasscode = true
            }
            self.performSegue(withIdentifier: "ShowPasscodeSegue", sender: self)
//            if !self.hasPasscode {
//                self.performSegue(withIdentifier: "ShowPasscodeSegue", sender: self)
//            } else {
//                self.presentDisablePasscodeAlert()
//            }
        }))
        
        if hasPasscode {
            alert.addAction(UIAlertAction(title: "Edit Passcode", style: .default, handler: { _ in
                self.isEditingPasscode = true
                self.performSegue(withIdentifier: "ShowPasscodeSegue", sender: self)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
//    func presentEditPasscodeAlert() {
//        let alert = UIAlertAction(title: "Edit Passcode", style: .default, handler: { _ in
//            self.performSegue(withIdentifier: "ShowPasscodeSegue", sender: self)
//        })
//    }
    
    func presentDisablePasscodeAlert() {
        let alert = UIAlertController(title: "Passcode Disabled", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.hasPasscode = false
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
