//
//  TimeTrackingTagViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/29.
//

import UIKit

class TimeTrackingTagViewController: UIViewController {

    @IBOutlet weak var searchTagTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var filteredCategories: [String]?
    var firstLoad = true
    var filteredMockTags: [String] = []
    var user: [User]?
    var selectedTag: String?
    weak var delegate: TimeTrackingTagViewControllerDelegate?
    var isFiltering = false
    
    var categories: [String]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var searchText = "" {
        didSet {
            self.filteredCategories = categories?.filter({
                $0.lowercased().contains(searchText.lowercased())
            })
            if searchText == "" {
                isFiltering = false
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        searchTagTextField.delegate = self
        fetchCategories()
        filteredCategories = []
    }
    
    func fetchCategories() {
        JournalManager.shared.fetchUser(completion: { result in
            switch result {
            case .success(let user):
                self.user = user
                self.categories = user[0].trackTimeCategories
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        searchTagTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        isFiltering = false
        searchTagTextField.text = nil
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        isFiltering = true
        searchText = textfield.text ?? ""
        filteredCategories = categories?.filter({
            $0.contains(searchText)
        })
        tableView.reloadData()
    }
}

extension TimeTrackingTagViewController: UITableViewDelegate, UITableViewDataSource, AddNewTagTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            guard !filteredCategories!.isEmpty else { return 1 }
            return filteredCategories?.count ?? 0
        } else {
            return categories?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering {
            if filteredCategories!.isEmpty && !firstLoad {
                let addNewCell = setUpAddNewTagCell(tableView: tableView)
                return addNewCell
            } else {
                firstLoad = false
                return setUpTimeTrackingTagCell(tableView: tableView, tag: filteredCategories ?? [], index: indexPath.row)
            }
        } else {
            return setUpTimeTrackingTagCell(tableView: tableView, tag: categories ?? [], index: indexPath.row)
        }
    }
    
    func setUpTimeTrackingTagCell(tableView: UITableView, tag: [String], index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingTagTableViewCell.identifier)
        guard let timeTrackingTagCell = cell as? TimeTrackingTagTableViewCell else { return cell! }
        guard !tag.isEmpty else { return cell! }
        timeTrackingTagCell.layoutCell(tag: tag[index])
        return timeTrackingTagCell
    }
    
    func setUpAddNewTagCell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddNewTagTableViewCell.identifier)
        guard let addNewTagCell = cell as? AddNewTagTableViewCell else { return cell! }
        addNewTagCell.delegate = self
        return addNewTagCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedTag = categories?[indexPath.row]
        self.delegate?.getSelectedTag(tag: selectedTag ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    
    func addNewTag() {
        categories?.append(searchText)
        TimeTrackingManager.shared.updateTrackTimeCategories(categories: categories ?? [])
        isFiltering = false
        searchTagTextField.text = nil
        searchTagTextField.resignFirstResponder()
        tableView.reloadData()
    }
}

extension TimeTrackingTagViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

protocol TimeTrackingTagViewControllerDelegate: AnyObject {
    func getSelectedTag(tag: String)
}
