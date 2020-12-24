//
//  RoutineReminderViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/24.
//

import UIKit
import Lottie

class RoutineReminderViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var tableView: UITableView!
    var switchStatus = UserDefaults.standard.bool(forKey: EPUserDefaults.hasDailyReminder.rawValue) {
        didSet {
            tableView.reloadData()
        }
    }
//    var datePicker: UIDatePicker!
    let center = UNUserNotificationCenter.current()
    var selectedDate: Date?
    var selectedDateText = "00:00" {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet weak var datePickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(_ sender: Any) {
        selectedDate = datePicker.date
        selectedDateText = selectedDate?.getFormattedTime() ?? "00:00"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        self.navigationItem.title = "Daily Reminder"
        addToolBar()
    }
    
    func showDatePicker() {
        self.datePickerConstraint.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func dismissDatePicker() {
        self.datePickerConstraint.constant = -250
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func addToolBar() {
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        doneButton.tintColor = .black
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: #selector(dismissDatePicker))
        cancelButton.tintColor = .black
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolBar.setItems([cancelButton,
                                  UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton],
                                 animated: true)
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolBar.widthAnchor.constraint(equalTo: datePicker.widthAnchor),
            toolBar.bottomAnchor.constraint(equalTo: datePicker.topAnchor)
        ])
    }
    
    func createDailyReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Time to write your journal."
        let time = selectedDate
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
    
    @objc func datePickerDone() {
        selectedDate = datePicker.date
        selectedDateText = selectedDate?.getFormattedTime() ?? "00:00"
        createDailyReminderNotification()
        dismissDatePicker()
        tableView.reloadData()
    }
}

extension RoutineReminderViewController: UITableViewDelegate, UITableViewDataSource, RoutineReminderTableViewCellDelegate {
    func getSwitchStatus(status: Bool) {
        switchStatus = status
        if !switchStatus {
            selectedDateText = "00:00"
            selectedDate = nil
            center.removePendingNotificationRequests(withIdentifiers: ["DailyRoutineNotification"])
        }
//        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoutineReminderTableViewCell.identifier, for: indexPath)
        guard let routineCell = cell as? RoutineReminderTableViewCell else { return cell }
        routineCell.delegate = self
        if indexPath.row == 0 {
            routineCell.layoutSwitchCell(switchStatus: switchStatus ?? false)
        } else {
            routineCell.layoutReminderCell(time: selectedDateText)
        }
        return routineCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            if switchStatus {
                showDatePicker()
            }
        }
    }
    
}
