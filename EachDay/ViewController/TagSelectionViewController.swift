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
    var mockData = ["Work"]
    var selectedTags: [String] = []
    weak var delegate: TagSelectionViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Add new tag", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "New tag name"
        })
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] _ in
            let textField = alert?.textFields![0]
            let newTag = textField?.text
            self.mockData.append(newTag ?? "")
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? WriteJournalViewController {
//            self.delegate = destination
//        }
//    }
    
}

extension TagSelectionViewController: UITableViewDataSource, UITableViewDelegate, TagSelectionTableViewCellDelegate {
    func handleSelected(sender: Any) {
        guard let button = sender as? UIButton else { return }
        let tag = mockData[button.tag]
        selectedTags.append(tag)
        self.delegate?.getSelectedTags(tags: selectedTags)
    }
    
    func handleDeselected(sender: Any) {
        guard let button = sender as? UIButton else { return }
        let tag = mockData[button.tag]
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

//            self.tableView.beginUpdates()
            print("Before: \(self.mockData)")
            print("Tag: \(button.tag)")
            self.mockData.remove(at: button.tag)
            print("After: \(self.mockData)")
//            self.tableView.deleteRows(at: [IndexPath(row: button.tag, section: 0)], with: .automatic)
            self.tableView.reloadData()
        }))
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    func createEditAlert(button: UIButton) {
        let editAlert = UIAlertController(title: "Edit Tag", message: nil, preferredStyle: .alert)
        editAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = self.mockData[button.tag]
        })
        editAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak editAlert] _ in
            let textField = editAlert?.textFields![0]
            let tag = textField?.text
            self.mockData[button.tag] = tag ?? ""
            self.tableView.reloadData()
        }))
        self.present(editAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagSelectionTableViewCell.identifier, for: indexPath)
        guard let tagCell = cell as? TagSelectionTableViewCell else { return cell }
        tagCell.layoutCell(tag: mockData[indexPath.row])
        tagCell.delegate = self
        tagCell.selectionButton.tag = indexPath.row
        tagCell.moreButton.tag = indexPath.row
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
}

protocol TagSelectionViewControllerDelegate: AnyObject {
    func getSelectedTags(tags: [String])
}
