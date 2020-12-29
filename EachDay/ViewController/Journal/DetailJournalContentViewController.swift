//
//  DetailJournalContentViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/4.
//

import UIKit
import PKHUD
import Kingfisher
import YPImagePicker

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
    let imagePicker = YPImagePicker()
    var journalImage: UIImage?
    var journalImageURL: String?
    var modifiedImageURL: String?
    
    @IBOutlet weak var imageViewButton: UIButton!
    @IBAction func imageViewButtonClicked(_ sender: Any) {
        imagePickerDonePicking()
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func trashButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: isTimeCapsule ?
                                        "Are you sure you want to delete this time capsule?" :
                                        "Are you sure you want to delete this journal?"
                                      , message: "This action can't be undo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak alert] _ in
            JournalManager.shared.deleteJournal(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
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
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
       
    }
    
    func createTimeCapsuleDismissAlert() {
        let alert = UIAlertController(title: "Do you wish to save or delete this time capsule letter?",
                                      message: nil
                                      , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.createSaveAlert()
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.createDeleteTimeCapsuleAlert()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func createDeleteTimeCapsuleAlert() {
        let alert = UIAlertController(title: isTimeCapsule ?
                                        "Are you sure you want to delete this time capsule?" :
                                        "Are you sure you want to delete this journal?"
                                      , message: "This action can't be undo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak alert] _ in
            JournalManager.shared.deleteJournal(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tags = journalVM?.tags else { return }
        if let destination = segue.destination as? TagSelectionViewController {
            destination.navigationController?.setNavigationBarHidden(true, animated: true)
            destination.fromDetail = true
            destination.selectedTags = modifiedTags ?? tags
            destination.delegate = self
        }
    }
    
    @objc func createSaveAlert() {
        let alert = UIAlertController(title: "Time Capsule Saved", message:  "You just saved one precious memory!", preferredStyle: .alert)
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
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { _ in
            JournalManager.shared.deleteJournal(journalID: self.journalVM?.id ?? "")
            self.loadingView.startLoading(on: self)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func configureEditMode() {
        if isEditingContent {
            createCameraButton()
        } else {
            self.navigationItem.rightBarButtonItems = [trashButton, editButton]
        }
        editButton.title = isEditingContent ? "Done" : "Edit"
        contentTextView.isEditable = isEditingContent
        titleTextView.isEditable = isEditingContent
        titleTextField.isUserInteractionEnabled = isEditingContent
        titleTextView.isUserInteractionEnabled = isEditingContent
        contentTextView.inputAccessoryView = toolBarView
        configureImageEditingMode()
        if !isEditingContent && (modifiedTitle != nil || modifiedContent != nil || modifiedTags != nil || modifiedImageURL != nil || journalImage != nil) {
            updateImageData()
        }
    }
    
    func configureImageEditingMode() {
        if isEditingContent {
            imageViewButton.isHidden = false
        } else {
            imageViewButton.isHidden = true
        }
    }
    
    func imagePickerDonePicking() {
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                let resized = photo.image.resizedImageWith(targetSize: CGSize(width: self.view.frame.width, height: 300))
                self.journalImage = resized
                self.journalImageView.image = resized
                self.titleTextViewToImageConstraint.constant = 10
                self.journalImageView.isHidden = false
            }
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateImageData() {
        loadingView.startLoading(on: self)
        guard journalImage != nil else {
            modifiedImageURL = nil
            updateJournal()
            return
        }
        JournalManager.shared.uploadImage(image: journalImage!, completion: { result in
            switch result {
            case .success(let url):
                self.modifiedImageURL = url
                self.updateJournal()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func updateJournal() {
        if let title = journalVM?.title, let content = journalVM?.content, let tags = journalVM?.tags, let id = journalVM?.id, let image = journalVM?.image {
            JournalManager.shared.updateJournal(journalID: journalVM?.id ?? id,
                                                title: modifiedTitle ?? title,
                                                content: modifiedContent ?? content,
                                                tags: modifiedTags ?? tags,
                                                image: modifiedImageURL ?? image, completion: { result in
                                                    switch result {
                                                    case .success(let message):
                                                        self.layoutTags(tags: (self.modifiedTags ?? self.journalVM?.tags) ?? [""])
                                                        self.loadingView.dismissLoading()
                                                        print(message)
                                                    case .failure(let error):
                                                        print(error)
                                                    }
                                                })
        }
    }
    
    func initialSetUp() {
//        HUD.show(.progress)
//        loadingView.startLoading(on: self)
        dateLabel.text = journalVM?.formattedDate
        titleTextField.text = journalVM?.title
        titleTextView.setUpTitle(text: journalVM?.title ?? "", lineSpacing: 3)
        contentTextView.setUpContentText(text: journalVM?.content ?? "", lineSpacing: 3)
        journalImageURL = journalVM?.image
        titleTextField.delegate = self
        contentTextView.delegate = self
        titleTextView.delegate = self
        displayImage()
        layoutTags(tags: journalVM?.tags ?? [""])
        if isTimeCapsule {
            createBarButtonItem()
        }
        createBackButton()
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
    
    func createCameraButton() {
        let cameraButton = UIButton(type: .custom)
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonClicked), for: .touchUpInside)
    
        let cameraBarButton = UIBarButtonItem(customView: cameraButton)
        let currWidth = cameraBarButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = cameraBarButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItems = [editButton, trashButton, cameraBarButton]
    }
    
    @objc func cameraButtonClicked() {
        imagePickerDonePicking()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func createBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBackButtonClicked), for: .touchUpInside)
        
        let backBarButton = UIBarButtonItem(customView: backButton)
        let currWidth = backBarButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = backBarButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func handleBackButtonClicked() {
        if isTimeCapsule {
            createTimeCapsuleDismissAlert()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func displayImage() {
        guard journalVM?.image != "" else {
            titleTextFieldToImageConstraint.constant = -290
            titleTextViewToImageConstraint.constant = -300
            journalImageView.isHidden = true
            imageViewButton.isEnabled = false
            return
        }
        loadingView.startLoading(on: self)
        imageViewButton.isEnabled = true
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
            }
        })
        task.resume()
    }
    
//    func layoutTags() {
//        guard (journalVM?.tags.count)! > 0 else {
//            tagLabel.isHidden = true
//            tagSeparator.isHidden = true
//            return
//        }
//        tagLabel.text = journalVM?.tags[0]
//        tagLabel.clipsToBounds = true
//        tagLabel.backgroundColor = UIColor(hexString: "F7AE00")
//        guard (journalVM?.tags.count)! > 1 else { return }
//        var xAnchor: CGFloat = 16
//        let journalTags = journalVM?.tags
//        var previousTag = tagLabel
//        for num in 0..<journalTags!.count-1 {
//            let journalTagLabel = PaddingableUILabel()
//            journalTagLabel.translatesAutoresizingMaskIntoConstraints = false
//            journalTagLabel.backgroundColor = UIColor(hexString: "F7AE00")
//            journalTagLabel.textColor = .white
//            journalTagLabel.text = journalTags?[num+1]
//            journalTagLabel.font = UIFont.systemFont(ofSize: 15)
//            journalTagLabel.clipsToBounds = true
//            journalTagLabel.cornerRadius = 6
//            journalTagLabel.paddingLeft = 8
//            journalTagLabel.paddingRight = 8
//            journalTagLabel.paddingTop = 8
//            journalTagLabel.paddingBottom = 8
//            setJournalTagConstraints(previousTag: previousTag!, currentTag: journalTagLabel, xAnchor: &xAnchor)
//            previousTag = journalTagLabel
//        }
//    }
    func layoutTags(tags: [String]) {
        if modifiedTags != nil {
            view.subviews.forEach({
                if $0 is PaddingableUILabel {
                    $0.isHidden = true
                    tagLabel.isHidden = false
                }
            })
        }
        guard !tags.isEmpty else {
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
        
        tagLabel.text = tags[0]
        tagLabel.clipsToBounds = true
        tagLabel.backgroundColor = UIColor(hexString: "F7AE00")
        guard tags.count > 1 else { return }
        var xAnchor: CGFloat = 16
        let journalTags = tags
        var previousTag = tagLabel
        for num in 0..<tags.count-1 {
            let journalTagLabel = PaddingableUILabel()
            journalTagLabel.translatesAutoresizingMaskIntoConstraints = false
            journalTagLabel.backgroundColor = UIColor(hexString: "F7AE00")
            journalTagLabel.textColor = .white
            journalTagLabel.text = tags[num+1]
            journalTagLabel.font = UIFont.systemFont(ofSize: 15)
            journalTagLabel.clipsToBounds = true
            journalTagLabel.cornerRadius = 6
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
            currentTag.topAnchor.constraint(equalTo: tagSeparator.bottomAnchor, constant: 8),
            currentTag.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
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
