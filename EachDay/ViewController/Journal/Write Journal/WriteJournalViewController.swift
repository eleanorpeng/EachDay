//
//  WriteJournalViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/26.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import YPImagePicker
import Charts

class WriteJournalViewController: UIViewController {

    @IBOutlet weak var tagSeparator: UIView!
    var journalData: Journal?
    var selectedDate: Date?
    var journalTitle: String? {
        didSet {
            self.checkIfCompleted()
        }
    }
    var journalContent: String? {
        didSet {
            self.checkIfCompleted()
        }
    }
    var journalTags: [String]? {
        didSet {
            self.checkIfCompleted()
            self.layoutTags()
        }
    }
    var journalImage: UIImage?
    var journalImageURL: String?
    var config = YPImagePickerConfiguration()
    var isDefault = true
    var isWritingSummary = false
    let loadingView = LoadingView()
    @IBOutlet var toolBarView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var journalImageView: UIImageView!
    @IBOutlet weak var tagLabel: PaddingableUILabel!
    @IBAction func selectTagButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTagSelectionSegue", sender: self)
        view.endEditing(true)
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        selectedDate = datePicker.date
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func dismissKeyboardButtonClicked(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func uploadImageButtonClicked(_ sender: Any) {
        imagePickerDonePicking()
        present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var uploadImageButton: UIButton!
    let helper = Helper()
    let imagePicker = YPImagePicker()
    var completeAllInfo = false {
        didSet {
            if true {
                self.completeButton.setImage(UIImage(named: "tick"), for: .normal)
                self.completeButton.isEnabled = true
            } else {
                self.completeButton.setImage(UIImage(named: "tick-gray"), for: .normal)
                self.completeButton.isEnabled = false
            }
        }
    }
    
    @IBAction func completeButtonClicked(_ sender: Any) {
        loadingView.startLoading(on: self)
        uploadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        contentTextView.inputAccessoryView = toolBarView
        titleTextField.inputAccessoryView = toolBarView
        if isWritingSummary {
            configureSummaryView()
        }
    }
    
    func configureSummaryView() {
        journalImageView.image = journalImage
        uploadImageButton.isHidden = true
        journalImageView.backgroundColor = .clear
    }
    
    func initialSetUp() {
        let buttonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 40, height: 40)
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
        completeButton.isEnabled = false
        completeButton.setImage(UIImage(named: "tick-gray"), for: .normal)
        tagLabel.isHidden = true
        tagSeparator.isHidden = true
        datePicker.maximumDate = Date()
    }

    func imagePickerDonePicking() {
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                let resized = photo.image.resizedImageWith(targetSize: CGSize(width: self.view.frame.width, height: 300))
                self.journalImage = resized
                self.journalImageView.image = resized
                self.uploadImageButton.setImage(nil, for: .normal)
                self.uploadImageButton.setTitle("", for: .normal)
            }
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    func uploadData() {
        guard journalImage != nil else {
            journalImageURL = ""
            addData()
            return
        }
        JournalManager.shared.uploadImage(image: journalImage!, completion: { result in
            switch result {
            case .success(let url):
                self.journalImageURL = url
                self.addData()
            case .failure(let error):
                print(error)
            }
        })
    }
    func addData() {
        journalData = Journal(title: journalTitle ?? "",
                              date: Timestamp(date: selectedDate ?? Date()),
                              content: journalContent ?? "",
                          tags: journalTags ?? [],
                          image: journalImageURL ?? "",
                          hasTracker: false,
                          isTimeCapsule: false,
                          id: "")
        JournalManager.shared.publishJournalData(journal: &journalData!, completion: { result in
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
    
    func checkIfCompleted() {
        if journalTitle != nil &&
           journalContent != nil &&
           journalTags != nil &&
           selectedDate != nil {
            completeAllInfo = true
        } else {
            completeAllInfo = false
        }
    }
    
    func layoutTags() {
        if !(journalTags?.isEmpty ?? false) {
            view.subviews.forEach({
                if $0 is PaddingableUILabel {
                    $0.isHidden = true
                    tagLabel.isHidden = false
                }
            })
        }
        guard (journalTags?.count ?? 0) > 0 else {
            view.subviews.forEach({
                if $0 is PaddingableUILabel {
                    $0.isHidden = true
                    tagLabel.isHidden = false
                }
            })
            tagLabel.isHidden = true
            tagSeparator.isHidden = true
            return
        }
        tagLabel.isHidden = false
        tagSeparator.isHidden = false
        tagLabel.text = journalTags?[0]
        tagLabel.clipsToBounds = true
        tagLabel.backgroundColor = UIColor(hexString: "F7AE00")
        guard (journalTags?.count ?? 0) > 1 else { return }
        var xAnchor: CGFloat = 16
        guard let journalTags = journalTags else { return }
        var previousTag = tagLabel
        for num in 0..<journalTags.count-1 {
            let journalTagLabel = PaddingableUILabel()
            journalTagLabel.translatesAutoresizingMaskIntoConstraints = false
            journalTagLabel.backgroundColor = UIColor(hexString: "F7AE00")
            journalTagLabel.textColor = .white
            journalTagLabel.text = journalTags[num+1]
            journalTagLabel.clipsToBounds = true
            journalTagLabel.cornerRadius = 8
            journalTagLabel.paddingLeft = 8
            journalTagLabel.paddingRight = 8
            journalTagLabel.paddingTop = 8
            journalTagLabel.paddingBottom = 8
            setJournalTagConstraints(previousTag: previousTag!, currentTag: journalTagLabel, xAnchor: &xAnchor)
            previousTag = journalTagLabel
        }
    }
    func setJournalTagConstraints(previousTag: PaddingableUILabel, currentTag: PaddingableUILabel, xAnchor: inout CGFloat) {
        currentTag.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentTag)
        NSLayoutConstraint.activate([
            currentTag.leadingAnchor.constraint(equalTo: previousTag.trailingAnchor, constant: xAnchor),
            currentTag.topAnchor.constraint(equalTo: tagSeparator.bottomAnchor, constant: 10),
            currentTag.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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
