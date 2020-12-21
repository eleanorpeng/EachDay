//
//  TagSelectionViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit

class TagSelectionViewController: UIViewController {
    var selected = false {
        didSet {
            tableView.reloadData()
        }
    }
    var index = 0
    var selectedTags: [String] = []
    var user: [User]?
    var tags: [String]?
    var fromUserSetting = false
    var isTimeTracking = false
    var isSorting = false
    var fromDetail = false
    var selectedTagsFromDetail: [String] = []
    weak var delegate: TagSelectionViewControllerDelegate?
    @IBAction func sortButtonClicked(_ sender: Any) {
        isSorting = !isSorting
        configureSortButton()
//
//        tableView.dragDelegate = self
//        tableView.dragInteractionEnabled = true
    }
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Add new tag", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "New tag name"
        })
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] _ in
            let textField = alert?.textFields![0]
            let newTag = textField?.text
            self.tags?.append(newTag ?? "")
            self.updateTags()
//            JournalManager.shared.updateJournalTags(userID: self.user?[0].id ?? "", tags: self.tags ?? [])
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var sortButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        fetchData()
        if fromDetail {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func configureSortButton() {
        if isSorting {
            sortButton.setImage(UIImage(named: "sort-gray"), for: .normal)
            tableView.isEditing = true
        } else {
            sortButton.setImage(UIImage(named: "sort"), for: .normal)
            tableView.isEditing = false
        }
    }
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
    }
    
    func fetchData() {
        JournalManager.shared.fetchUser(completion: { result in
            switch result {
            case .success(let user):
                if self.isTimeTracking {
                    self.tags = user[0].trackTimeCategories
                } else {
                    self.tags = user[0].journalTags
                }
                self.user = user
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func updateTags() {
        if isTimeTracking {
            TimeTrackingManager.shared.updateTrackTimeCategories(categories: tags ?? [])
        } else {
            JournalManager.shared.updateJournalTags(tags: tags ?? [])
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? WriteJournalViewController {
//            self.delegate = destination
//        }
//    }
    
}

extension TagSelectionViewController: UITableViewDataSource, UITableViewDelegate, TagSelectionTableViewCellDelegate, UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItems = UIDragItem(itemProvider: NSItemProvider())
        dragItems.localObject = tags?[indexPath.row]
        return [dragItems]
    }
    
    func handleSelected(sender: Any) {
        guard let button = sender as? UIButton else { return }
        let tag = tags?[button.tag]
        selectedTags.append(tag ?? "")
        self.delegate?.getSelectedTags(tags: selectedTags)
    
    }
    
    func handleDeselected(sender: Any) {
        guard let button = sender as? UIButton else { return }
        let tag = tags?[button.tag]
        selectedTags = selectedTags.filter({
            $0 != tag
        })
        self.delegate?.getSelectedTags(tags: selectedTags)
    }
    
    func handleMoreButton(sender: Any) {
        guard let button = sender as? UIButton else { return }
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            self.createEditAlert(button: button)
        }))
        alertSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let tag = self.tags?[button.tag]
            self.tags?.remove(at: button.tag)
            self.selectedTags = self.selectedTags.filter({
                $0 != tag
            })
            print(self.selectedTags)
            self.delegate?.getSelectedTags(tags: self.selectedTags)
            self.updateTags()
//            JournalManager.shared.updateJournalTags(userID: self.user?[0].id ?? "", tags: self.tags ?? [])
            self.tableView.reloadData()
        }))
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    func createEditAlert(button: UIButton) {
        let editAlert = UIAlertController(title: "Edit Tag", message: nil, preferredStyle: .alert)
        editAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = self.tags?[button.tag]
        })
        editAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak editAlert] _ in
            let textField = editAlert?.textFields![0]
            let tag = textField?.text
            var index = 0
            for num in 0..<self.selectedTags.count {
                if self.selectedTags[num] == tag {
                    index = num
                }
            }
            self.tags?[button.tag] = tag ?? ""
            self.selectedTags[index] = tag ?? ""
            self.delegate?.getSelectedTags(tags: self.selectedTags)
            self.updateTags()
//            JournalManager.shared.updateJournalTags(userID: self.user?[0].id ?? "", tags: self.tags ?? [])
            self.tableView.reloadData()
        }))
        self.present(editAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagSelectionTableViewCell.identifier, for: indexPath)
        guard let tagCell = cell as? TagSelectionTableViewCell else { return cell }
        if fromUserSetting {
            tagCell.layoutUserSettingCell(tag: tags?[indexPath.row] ?? "")
        } else {
            tagCell.layoutCell(tag: tags?[indexPath.row] ?? "")
        }
        tagCell.delegate = self
        tagCell.selectionButton.tag = indexPath.row
        tagCell.moreButton.tag = indexPath.row
        tagCell.selectionIndicator.isHidden = !selectedTags.contains(tagCell.tagLabel?.text ?? "")
//        if fromDetail {
//            tagCell.selectionIndicator.isHidden = !selectedTagsFromDetail.contains(tagCell.tagLabel?.text ?? "")
//        }
        return tagCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selected = true
        index = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedTag = self.tags?[sourceIndexPath.row] ?? ""
        tags?.remove(at: sourceIndexPath.row)
        tags?.insert(movedTag, at: destinationIndexPath.row)
        updateTags()
    }
}

protocol TagSelectionViewControllerDelegate: AnyObject {
    func getSelectedTags(tags: [String])
}
