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
    var journalTags: [String]?
    var journalImage: UIImage?
    var isDefault = true
    @IBOutlet var toolBarView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBAction func selectTagButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTagSelectionSegue", sender: self)
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        selectedDate = datePicker.date
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dismissKeyboardButtonClicked(_ sender: Any) {
        view.endEditing(true)
    }
    let helper = Helper()
    let pickerData = ["Traveling", "Daily"]
//    var completeAllInfo = false {
//        didSet {
//            if true {
//                self.completeButton.setImage("tick", for: .normal)
//                self.completeButton.isEnabled = true
//            } else {
//                self.completeButton.setImage("tick-gray", for: .normal)
//                self.completeButton.isEnabled = false
//            }
//        }
//    }
    
    @IBAction func completeButtonClicked(_ sender: Any) {
        addData()
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        contentTextView.inputAccessoryView = toolBarView
        titleTextField.inputAccessoryView = toolBarView
    }
    
    func initialSetUp() {
        let buttonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 45, height: 45)
        let button = helper.createButton(background: buttonBackground, image: UIImage(named: "close")!, padding: 12)
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
        let journal = Firestore.firestore().collection("User").document().collection("Journal")
        let document = journal.document()
        journalData = Journal(title: journalTitle ?? "",
                              date: selectedDate?.timeIntervalSince1970 ?? 0,
                              content: journalContent ?? "",
                          tags: journalTags ?? [""],
                          image: "",
                          hasTracker: false,
                          isTimeCapsule: false,
                          id: document.documentID)
        try? document.setData(from: journalData)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TagSelectionViewController {
            destination.delegate = self
            destination.selectedTags = journalTags ?? []
        }
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
}

extension WriteJournalViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        journalTitle = textField.text
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension WriteJournalViewController: TagSelectionViewControllerDelegate {
    func getSelectedTags(tags: [String]) {
        journalTags = tags
    }
}
