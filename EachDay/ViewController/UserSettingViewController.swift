//
//  UserSettingViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/8.
//

import UIKit

class UserSettingViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    func initialSetUp() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension UserSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
            return setUpSettingCell()
        }
    }
    
    func setUpProfileCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier)
        guard let profileCell = cell as? ProfileTableViewCell else { return cell! }
        profileCell.layoutCell(profileImage: UIImage(named: "user")!, name: "Eleanor Peng")
        return profileCell
    }
    
    func setUpSettingCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier)
        guard let settingCell = cell as? SettingsTableViewCell else { return cell! }
        settingCell.layoutCell(icon: "stopwatch", setting: "Reminder", description: "00:00")
        return settingCell
    }
    
}
