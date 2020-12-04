//
//  WriteTimeCapsuleViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit
import YPImagePicker

class WriteTimeCapsuleViewController: UIViewController {

    @IBAction func uploadButtonClicked(_ sender: Any) {
        imagePickerDonePicking()
        present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var uploadImageButton: UIButton!
    var config = YPImagePickerConfiguration()
    let imagePicker = YPImagePicker()
    var selectedDate: Double?
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
        addData()
        navigationController?.popToRootViewController(animated: true)
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
        let buttonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 45, height: 45)
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
    }
    
    func imagePickerDonePicking() {
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera)
                print(photo.image)
                self.timeCapsuleLetterImageView.image = photo.image
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
    
    func addData() {
        timeCapsuleData = Journal(title: letterTitle ?? "",
                                  date: selectedDate ?? 0,
                                  content: letterContent ?? "",
                                  tags: ["Time Capsule"],
                                  image: "",
                                  hasTracker: false,
                                  isTimeCapsule: true,
                                  id: "")
        JournalManager.shared.publishJournalData(journal: &timeCapsuleData!, userID: "Eleanor", completion: { result in
            switch result {
            case .success(let message):
                print(message)
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
