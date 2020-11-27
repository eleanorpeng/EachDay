//
//  WriteJournalViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit

class WriteJournalViewController: UIViewController {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBAction func tagButtonClicked(_ sender: Any) {
        pickerView.isHidden = false
        toolBar.isHidden = false
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
    let helper = Helper()
    let pickerData = ["Traveling", "Daily"]
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    
        initialSetUp()
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func initialSetUp() {
        let buttonBackground = helper.createBackButtonBackground(view: view)
        let button = helper.createButton(background: buttonBackground)
        NSLayoutConstraint.activate([
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonBackground.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        contentTextView.delegate = self
        contentTextView.text = "Record detail of your day"
        contentTextView.textColor = .lightGray
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

}

extension WriteJournalViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
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
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//    }
}
