//
//  UserSettingViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit
import YPImagePicker
import Kingfisher
import KeychainAccess

class UserSettingViewController: UIViewController, PasscodeViewControllerDelegate {
    
    var hasPasscode = false {
        didSet {
            settings?[3].description = hasPasscode ? "Enable" : "Disable"
            tableView.reloadData()
        }
    }
    
    weak var delegate: UserSettingViewControllerDelegate?
    
    var isDisablingPasscode = false
    var isTimeTracking = false
    var profileImage: UIImage?
    var profileImageURL: String? {
        didSet {
            if profileImageURL != "" {
                isDefaultProfileImage = false
                self.tableView.reloadData()
            }
        }
    }
    var isDefaultProfileImage = true
    var settings: [Settings]?
    var isEditingPasscode = false
    var user: User?
    var userName: String?
    let keychain = Keychain()
    var reminderTime: Date?
    var routineReminderClicked = false
    var hasSetReminder = false
    let center = UNUserNotificationCenter.current()
    
//    UserDefaults.setValue(self.enableBiometricsAuth, forKey: EPUserDefaults.enableBiometrics.rawValue)
    
    var enableBiometricsAuth = UserDefaults.standard.bool(forKey: EPUserDefaults.enableBiometrics.rawValue) {
        didSet {
            settings?[4].description = enableBiometricsAuth ? "Enable" : "Disable"
            UserDefaults.standard.setValue(enableBiometricsAuth, forKey: EPUserDefaults.enableBiometrics.rawValue)
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    let imagePicker = YPImagePicker()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        fetchUserData()
        hasPasscode = keychain["passcode"] != nil 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hasPasscode = keychain["passcode"] != nil
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func initialSetUp() {
        self.navigationItem.title = "Settings"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        settings = [Settings(icon: "notification", setting: "Daily Reminder", description: ">"),
                    Settings(icon: "tag", setting: "Journal Tags", description: ">"),
                    Settings(icon: "stopwatch", setting: "Time Tracker Categories", description: ">"),
                    Settings(icon: "passcode", setting: "Passcode", description: (keychain["passcode"] != nil) ? "Enable" : "Disable"),
                    Settings(icon: "face-recognition", setting: "FaceID", description: enableBiometricsAuth ? "Enable" : "Disable")
                    ]
    }
    
    func fetchUserData() {
        UserManager.shared.fetchUser(completion: { result in
            switch result {
            case .success(let user):
                self.user = user[0]
                self.userName = self.user?.name
                self.profileImageURL = self.user?.image ?? ""
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func imagePickerDonePicking() {
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                self.profileImage = photo.image
                UserManager.shared.uploadImage(image: photo.image, completion: { result in
                    switch result {
                    case .success(let message):
                        print(message)
                    case .failure(let error):
                        print(error)
                    }
                })
                self.isDefaultProfileImage = false
            }
            imagePicker.dismiss(animated: true, completion: {
//                self.loadingView.startLoadingWithoutBackground(on: self)
                self.tableView.reloadData()
                NotificationCenter.default.post(name: Notifications.receiveProfileImageNotification, object: self.profileImage)
                
            })
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TagSelectionViewController {
            destination.fromUserSetting = true
            destination.isTimeTracking = isTimeTracking
            self.navigationController?.setNavigationBarHidden(true, animated: true)
//            self.navigationController?.navigationBar.isHidden = true
        }
        
        if let destination = segue.destination as? PasscodeViewController {
            destination.delegate = self
            destination.isEditingPasscode = isEditingPasscode
            destination.isDisablingPasscode = isDisablingPasscode
            destination.isInitial = false
            self.delegate = destination
        }
        
        if let destination = segue.destination as? RoutineReminderViewController {
            destination.user = user
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

extension UserSettingViewController: UITableViewDelegate, UITableViewDataSource, ProfileTableViewCellDelegate, SettingsTableViewCellDelegate {
    func getSelectedTime(time: Date) {
        reminderTime = time
        hasSetReminder = true
        createDailyReminderNotification()
        print(reminderTime)
    }
    
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

        if isDefaultProfileImage {
            profileCell.layoutCell(profileImage: nil, name: userName ?? "Eleanor Peng")
        } else {
            profileCell.layoutCell(profileImage: profileImageURL, name: userName ?? "Eleanor Peng")
            
        }
        return profileCell
    }
    
    func setUpSettingCell(index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier)
        guard let settingCell = cell as? SettingsTableViewCell else { return cell! }
        settingCell.layoutCell(icon: settings?[index].icon ?? "",
                               setting: settings?[index].setting ?? "",
                               description: settings?[index].description ?? "")
        settingCell.routineReminderClicked = routineReminderClicked
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
            performSegue(withIdentifier: "ShowRoutineReminderSegue", sender: self)
            return
        case 1:
            performSegue(withIdentifier: "ShowTagsSegue", sender: self)
        case 2:
            performSegue(withIdentifier: "ShowTagsSegue", sender: self)
        case 3:
            presentPasscodeAlert()
        case 4:
            presentEnableBiometricsAuthAlert()
        default:
            print("Nothing")
        }
    }
    
    func createDailyReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Time to write your journal."
        let time = reminderTime
        let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        let identifier = "DailyRoutineNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { error in
            if let error = error {
                print(error)
            }
        })
        
    }
    
    func removeDailyReminderNotification() {
        center.removePendingNotificationRequests(withIdentifiers: ["DailyRoutineNotification"])
    }
    
    func presentPasscodeAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: hasPasscode ? "Disable" : "Enable", style: .default, handler: { _ in
            if self.hasPasscode {
                self.isDisablingPasscode = true
            } else {
                self.isDisablingPasscode = false
            }
            self.performSegue(withIdentifier: "ShowPasscodeSegue", sender: self)
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
    
    func presentEnableBiometricsAuthAlert() {
        guard hasPasscode else {
            let alert = UIAlertController(title: "Could Not Enable FaceID", message: "Please enable passcode before enabling biometric authentication.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: enableBiometricsAuth ? "Disable" : "Enable", style: .default, handler: { _ in
            self.enableBiometricsAuth = !self.enableBiometricsAuth
            self.delegate?.getBiometricsAuthState(enable: self.enableBiometricsAuth)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

protocol UserSettingViewControllerDelegate: AnyObject {
    func getBiometricsAuthState(enable: Bool)
}
