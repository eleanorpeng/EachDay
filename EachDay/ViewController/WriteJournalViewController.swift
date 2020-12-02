//
//  WriteJournalViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
class WriteJournalViewController: UIViewController {

    //Declare journal info
    var journalData: Journal?
    var selectedDate: Date?
    var journalTitle: String?
    var journalContent: String?
    var journalTheme: String?
    var journalImage: UIImage?
    var isDefault = true
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBAction func tagButtonClicked(_ sender: Any) {
        pickerView.isHidden = false
        toolBar.isHidden = false
        if isDefault {
            journalTheme = pickerData[0]
        }
    }
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func doneButtonClicked(_ sender: Any) {
        pickerView.isHidden = true
        toolBar.isHidden = true
        
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        pickerView.isHidden = true
        toolBar.isHidden = true
    }
    @IBAction func dateChanged(_ sender: Any) {
        selectedDate = datePicker.date
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    let helper = Helper()
    let pickerData = ["Traveling", "Daily"]
    
    @IBAction func completeButtonClicked(_ sender: Any) {
        print("Title: \(journalTitle)")
        print("Content: \(journalContent)")
        print("Theme: \(journalTheme)")
        print("date: \(selectedDate)")
//        addData()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        initialSetUp()
    }
    
    func initialSetUp() {
        let buttonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 45, height: 45)
        let button = helper.createButton(background: buttonBackground, image: UIImage(named: "back")!, padding: 10)
        NSLayoutConstraint.activate([
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonBackground.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)
        ])
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        contentTextView.delegate = self
        contentTextView.text = "Record detail of your day"
        contentTextView.textColor = .lightGray
        selectedDate = datePicker.date
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        titleTextField.delegate = self
        
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    func addData() {
        let journal = Firestore.firestore().collection("Journal")
        let document = journal.document()
        journalData = Journal(title: journalTitle ?? "",
                              date: selectedDate?.timeIntervalSince1970 ?? 0,
                              content: journalContent ?? "",
                          theme: journalTheme ?? "",
                          image: "",
                          hasTracker: false,
                          isTimeCapsule: false,
                          id: document.documentID)
        try? document.setData(from: journalData)
    }
}

extension WriteJournalViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        journalContent = contentTextView.text
        if contentTextView.text.isEmpty {
            contentTextView.text = "Record detail of your day"
            contentTextView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.textColor == UIColor.lightGray {
            contentTextView.text = nil
            contentTextView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
}

extension WriteJournalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        journalTheme = pickerData[row]
        isDefault = false
    }
}

extension WriteJournalViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        journalTitle = textField.text
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
