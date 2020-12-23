//
//  WriteTimeCapsuleViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit
import YPImagePicker
import Firebase
import UserNotifications

class WriteTimeCapsuleViewController: UIViewController {

    @IBAction func uploadButtonClicked(_ sender: Any) {
        imagePickerDonePicking()
        present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    var config = YPImagePickerConfiguration()
    let loadingView = LoadingView()
    let imagePicker = YPImagePicker()
    var selectedDate: Date?
    var letterImage: UIImage?
    var letterImageURL: String?
    let center = UNUserNotificationCenter.current()
    var letterTitle: String? {
        didSet {
            checkAllInfo()
        }
    }
    var letterContent: String? {
        didSet {
            checkAllInfo()
        }
    }
    let helper = Helper()
    var timeCapsuleData: Journal?
    @IBAction func dismissButtonClicked(_ sender: Any) {
        view.endEditing(true)
    }
    @IBOutlet var toolBarView: UIView!
    @IBOutlet weak var senderButton: UIButton!
    @IBAction func sendButtonClicked(_ sender: Any) {
        loadingView.startLoading(on: self)
        createPushNotification()
        uploadData()
//        navigationController?.popToRootViewController(animated: true)
    }
    @IBOutlet weak var timeCapsuleLetterImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    var completeAllInfo = false {
        didSet {
            if true {
                senderButton.setImage(UIImage(named: "send"), for: .normal)
                senderButton.isEnabled = true
            } else {
                senderButton.setImage(UIImage(named: "send-gray"), for: .normal)
                senderButton.isEnabled = false
            }
        }
    }
    
    func initialSetUp() {
        let buttonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 40, height: 40)
        let button = helper.createButton(background: buttonBackground, image: UIImage(named: "back")!, padding: 10)
        NSLayoutConstraint.activate([
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonBackground.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        titleTextField.delegate = self
        contentTextView.delegate = self
        contentTextView.text = "What would you like to send?"
        contentTextView.textColor = .lightGray
        senderButton.setImage(UIImage(named: "send-gray"), for: .normal)
        senderButton.isEnabled = false
        contentTextView.inputAccessoryView = toolBarView
        titleTextField.inputAccessoryView = toolBarView
        if let date = selectedDate?.getFormattedDate(), let time = selectedDate?.getFormattedTime() {
            dateLabel.text = "\(date) \(time)"
        }
    }
    
    func createPushNotification() {
        let content = UNMutableNotificationContent()
        content.title = "You Received a Time Capsule!"
        content.body = "Read what you sent to yourself."
        let date = selectedDate ?? Date()
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "TimeCapsuleNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { error in
            if let error = error {
                print(error)
            }
        })
    }
    func imagePickerDonePicking() {
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                let resized = photo.image.resizedImageWith(targetSize: CGSize(width: self.view.frame.width, height: 300))
                self.letterImage = resized
                self.timeCapsuleLetterImageView.image = resized
                self.uploadImageButton.setImage(nil, for: .normal)
                self.uploadImageButton.setTitle("", for: .normal)
            }
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func checkAllInfo() {
        if letterTitle != nil && letterContent != nil {
            completeAllInfo = true
        }
    }
    func uploadData() {
        guard letterImage != nil else {
            letterImageURL = ""
            addData()
            return
        }
        JournalManager.shared.uploadImage(image: letterImage!, completion: { result in
            switch result {
            case .success(let url):
                self.letterImageURL = url
                self.addData()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func addData() {
        timeCapsuleData = Journal(title: letterTitle ?? "",
                                  date: Timestamp(date: selectedDate ?? Date()),
                                  content: letterContent ?? "",
                                  tags: ["Time Capsule"],
                                  image: self.letterImageURL ?? "",
                                  hasTracker: false,
                                  isTimeCapsule: true,
                                  id: "")
        JournalManager.shared.publishJournalData(journal: &timeCapsuleData!, completion: { result in
            switch result {
            case .success(let message):
                print(message)
                self.loadingView.dismissLoading()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
                })
            case .failure(let error):
                print(error)
            }
        })
    }
}

extension WriteTimeCapsuleViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        letterContent = textView.text
        if contentTextView.text.isEmpty {
            contentTextView.text = "What would you like to send?"
            contentTextView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.textColor == UIColor.lightGray {
            contentTextView.text = nil
            contentTextView.textColor = UIColor.black
        }
    }
}

extension WriteTimeCapsuleViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        letterTitle = textField.text
    }
}


