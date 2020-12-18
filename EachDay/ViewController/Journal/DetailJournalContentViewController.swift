//
//  DetailJournalContentViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/4.
//

import UIKit
import PKHUD
import Kingfisher

class DetailJournalContentViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, TagSelectionViewControllerDelegate {
    func getSelectedTags(tags: [String]) {
        modifiedTags = tags
    }
    
    @IBOutlet weak var titleTextFieldToImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextViewToImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var journalImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagSeparator: UIView!
    @IBOutlet weak var tagLabel: PaddingableUILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet var trashButton: UIBarButtonItem!
    var isEditingContent = false
    var journalData: Journal?
    var journalVM: JournalViewModel?
    var modifiedTitle: String?
    var modifiedContent: String?
    var modifiedTags: [String]?
    var isTimeCapsule = false
    let loadingView = LoadingView()
    
    @IBAction func trashButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: isTimeCapsule ?
                                        "Are you sure you want to delete this time capsule?" :
                                        "Are you sure you want to delete this journal?"
                                      , message: "This action can't be undo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak alert] _ in
            JournalManager.shared.deleteJournal(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
//            HUD.flash(.progress)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var toolBarView: UIView!

    @IBOutlet var editButton: UIBarButtonItem!

    @IBAction func editButtonClicked(_ sender: Any) {
        guard !isTimeCapsule else {
            createSaveAlert()
            return
        }
        isEditingContent = !isEditingContent
        configureEditMode()
    }
    
    @IBAction func tagButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTagsFromContentSegue", sender: self)
        view.endEditing(true)
    }
    
    @IBAction func downButtonClicked(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journalVM = JournalViewModel(journal: journalData!)
        initialSetUp()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tags = journalVM?.tags else { return }
        if let destination = segue.destination as? TagSelectionViewController {
            destination.fromDetail = true
            destination.selectedTags = modifiedTags ?? tags
            destination.delegate = self
        }
    }
    
    @objc func createSaveAlert() {
        let alert = UIAlertController(title: "You just saved one precious memory!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            JournalManager.shared.changeTimeCapsuleStatus(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
//            HUD.flash(.progress)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showTimeCapsuleAlert() {
        let alert = UIAlertController(title: "Do you wish to save this time capsule?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            JournalManager.shared.changeTimeCapsuleStatus(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
//            HUD.flash(.progress)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { _ in
            JournalManager.shared.deleteJournal(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
//            HUD.flash(.progress)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func configureEditMode() {
        editButton.title = isEditingContent ? "Done" : "Edit"
        contentTextView.isEditable = isEditingContent
        titleTextView.isEditable = isEditingContent
        titleTextField.isUserInteractionEnabled = isEditingContent
        titleTextView.isUserInteractionEnabled = isEditingContent
        contentTextView.inputAccessoryView = toolBarView
        if !isEditingContent && (modifiedTitle != nil || modifiedContent != nil || modifiedTags != nil) {
            updateJournal()
        }
    }
    
    func updateJournal() {
        if let title = journalVM?.title, let content = journalVM?.content, let tags = journalVM?.tags, let id = journalVM?.id {
            JournalManager.shared.updateJournal(journalID: journalVM?.id ?? id,
                                                title: modifiedTitle ?? title,
                                                content: modifiedContent ?? content,
                                                tags: modifiedTags ?? tags)
        }
    }
    
    func initialSetUp() {
//        HUD.show(.progress)
//        loadingView.startLoading(on: self)
        dateLabel.text = journalVM?.formattedDate
        titleTextField.text = journalVM?.title
        titleTextView.setUpTitle(text: journalVM?.title ?? "", lineSpacing: 3)
        contentTextView.setUpContentText(text: journalVM?.content ?? "", lineSpacing: 3)
        titleTextField.delegate = self
        contentTextView.delegate = self
        titleTextView.delegate = self
        displayImage()
        layoutTags()
        if isTimeCapsule {
            createBarButtonItem()
        }
    }
    
    func createBarButtonItem() {
        let saveButton = UIButton(type: .custom)
        saveButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        saveButton.setImage(UIImage(named: "download"), for: .normal)
        saveButton.addTarget(self, action: #selector(createSaveAlert), for: .touchUpInside)
        
        let saveBarButton = UIBarButtonItem(customView: saveButton)
        let currWidth = saveBarButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = saveBarButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        editButton = nil
        self.navigationItem.rightBarButtonItems = [trashButton, saveBarButton]
    }
    
    func displayImage() {
        guard journalVM?.image != "" else {
            titleTextFieldToImageConstraint.constant = -290
            titleTextViewToImageConstraint.constant = -300
            journalImageView.isHidden = true
//            loadingView.dismissLoading()
//            HUD.hide()
            return
        }
        loadingView.startLoading(on: self)
        guard let urlString = journalVM?.image,
              let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.journalImageView.kf.setImage(with: url, options: [.transition(.fade(1))])
                self.loadingView.dismissLoading()
//                HUD.hide()
            }
        })
        task.resume()
    }
    
    func layoutTags() {
        guard (journalVM?.tags.count)! > 0 else {
            tagLabel.isHidden = true
            tagSeparator.isHidden = true
            return
        }
        tagLabel.text = journalVM?.tags[0]
        tagLabel.clipsToBounds = true
        tagLabel.backgroundColor = UIColor(hexString: "F7AE00")
        guard (journalVM?.tags.count)! > 1 else { return }
        var xAnchor: CGFloat = 16
        let journalTags = journalVM?.tags
        var previousTag = tagLabel
        for num in 0..<journalTags!.count-1 {
            let journalTagLabel = PaddingableUILabel()
            journalTagLabel.translatesAutoresizingMaskIntoConstraints = false
            journalTagLabel.backgroundColor = UIColor(hexString: "F7AE00")
            journalTagLabel.textColor = .white
            journalTagLabel.text = journalTags?[num+1]
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
        view.sendSubviewToBack(currentTag)
        NSLayoutConstraint.activate([
            currentTag.leadingAnchor.constraint(equalTo: previousTag.trailingAnchor, constant: xAnchor),
            currentTag.topAnchor.constraint(equalTo: tagSeparator.bottomAnchor, constant: 10),
            currentTag.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        modifiedContent = contentTextView.text
        modifiedTitle = titleTextView.text

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        modifiedTitle = textField.text
        titleTextField.text = modifiedTitle
    }
    
}
