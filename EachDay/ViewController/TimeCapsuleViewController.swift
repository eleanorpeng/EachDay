//
//  TimeCapsuleViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit

class TimeCapsuleViewController: UIViewController {

    let helper = Helper()
    var selectedDate: Date?
    @IBOutlet weak var datePicker: UIDatePicker!
  
    @IBAction func datePickerChanged(_ sender: Any) {
        selectedDate = datePicker.date
    }
    
    @IBAction func forwardButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteTimeCapsuleSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        createBackButton()
    }

    func createBackButton() {
        let backButtonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 50, height: 50)
        let button = helper.createButton(background: backButtonBackground, image: UIImage(named: "back")!, padding: 10)
        NSLayoutConstraint.activate([
            backButtonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButtonBackground.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}
