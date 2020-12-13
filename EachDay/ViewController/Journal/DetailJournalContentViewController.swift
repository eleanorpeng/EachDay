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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var journalImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagSeparator: UIView!
    @IBOutlet weak var tagLabel: PaddingableUILabel!
    @IBOutlet weak var titleTextField: UITextField!
    var isEditingContent = false
    var journalData: Journal?
    var journalVM: JournalViewModel?
    var modifiedTitle: String?
    var modifiedContent: String?
    var modifiedTags: [String]?
    
    @IBAction func trashButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete this journal?", message: "This action can't be undo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak alert] _ in
            JournalManager.shared.deleteJournal(userID: "Eleanor", journalID: self.journalVM?.id ?? "")
            HUD.flash(.progress)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet var toolBarView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editButtonClicked(_ sender: Any) {
        isEditingContent = !isEditingContent
        configureEditMode()
    }
    @IBAction func tagButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTagsFromContentSegue", sender: self)
    }
    
    @IBAction func downButtonClicked(_ sender: Any) {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        journalVM = JournalViewModel(journal: journalData!)
        initialSetUp()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tags = journalVM?.tags else { return }
        if let destination = segue.destination as? TagSelectionViewController {
            destination.fromDetail = true
            destination.selectedTags = modifiedTags ?? tags
            destination.delegate = self
        }
    }
    func configureEditMode() {
        editButton.title = isEditingContent ? "Done" : "Edit"
        contentTextView.isEditable = isEditingContent
        titleTextField.isUserInteractionEnabled = isEditingContent
        contentTextView.inputAccessoryView = toolBarView
        if !isEditingContent && (modifiedTitle != nil || modifiedContent != nil || modifiedTags != nil){
            updateJournal()
        }
    }
    
    func updateJournal() {
        if let title = journalVM?.title, let content = journalVM?.content, let tags = journalVM?.tags, let id = journalVM?.id {
            JournalManager.shared.updateJournal(userID: "Eleanor",
                                                journalID: journalVM?.id ?? id,
                                                title: modifiedTitle ?? title,
                                                content: modifiedContent ?? content,
                                                tags: modifiedTags ?? tags)
        }
    }
    
    func initialSetUp() {
        HUD.show(.progress)
        dateLabel.text = journalVM?.formattedDate
        titleTextField.text = journalVM?.title
        contentTextView.text = journalVM?.content
        
        titleTextField.delegate = self
        contentTextView.delegate = self
        displayImage()
        layoutTags()
        
    }
    
    func displayImage() {
        guard journalVM?.image != "" else {
            titleTextFieldToImageConstraint.constant = -260
            journalImageView.isHidden = true
            HUD.hide()
            return
        }
        guard let urlString = journalVM?.image,
              let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.journalImageView.kf.setImage(with: url, options: [.transition(.fade(1))])
                HUD.hide()
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
        guard (journalVM?.tags.count)! > 1 else { return }
        var xAnchor: CGFloat = 16
        let journalTags = journalVM?.tags
        var previousTag = tagLabel
        for num in 0..<journalTags!.count-1 {
            let journalTagLabel = PaddingableUILabel()
            journalTagLabel.translatesAutoresizingMaskIntoConstraints = false
            journalTagLabel.backgroundColor = UIColor(r: 247, g: 174, b: 0)
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
        NSLayoutConstraint.activate([
            currentTag.leadingAnchor.constraint(equalTo: previousTag.trailingAnchor, constant: xAnchor),
            currentTag.topAnchor.constraint(equalTo: tagSeparator.bottomAnchor, constant: 16),
            currentTag.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        modifiedContent = textView.text
        contentTextView.text = modifiedContent
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        modifiedTitle = textField.text
        titleTextField.text = modifiedTitle
    }
    
}


