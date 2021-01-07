//
//  TimeCapsuleViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit
import YPImagePicker
import Lottie

class TimeCapsuleViewController: UIViewController {

    let helper = Helper()
    var selectedDate: Date?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(_ sender: Any) {
        selectedDate = datePicker.date
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteTimeCapsuleSegue", sender: self)
    }
    
    @IBAction func forwardButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteTimeCapsuleSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDate = Date()
        datePicker.minimumDate = Date()
        createBackButton()
        changeLineSpacing()
        configureAnimation()
    }
    
    func configureAnimation() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
    }
    
    func changeLineSpacing() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19)]
        let attributedString = NSAttributedString(string: "When do you wish to receive your letter?", attributes: attributes)
        titleLabel.attributedText = attributedString
    }

    func createBackButton() {
        let backButtonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 40, height: 40)
        let button = helper.createButton(background: backButtonBackground, image: UIImage(named: "close")!, padding: 12)
        NSLayoutConstraint.activate([
            backButtonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButtonBackground.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WriteTimeCapsuleViewController {
            destination.selectedDate = self.selectedDate
        }
    }
}
