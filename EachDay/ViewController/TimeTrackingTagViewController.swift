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
    var mockTags = ["Work", "Eat", "Personal", "Sleep", "Commute"]
    var firstLoad = true
    var filteredMockTags: [String] = []
    var selectedTag: String?
    weak var delegate: TimeTrackingTagViewControllerDelegate?
    var isFiltering = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var searchText = "" {
        didSet {
            self.filteredMockTags = mockTags.filter({
                $0.contains(searchText)
            })
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        searchTagTextField.delegate = self
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
        filteredMockTags = mockTags.filter({
            $0.contains(searchText)
        })
    }
}

extension TimeTrackingTagViewController: UITableViewDelegate, UITableViewDataSource, AddNewTagTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            guard !filteredMockTags.isEmpty else { return 1 }
            return filteredMockTags.count
        } else {
            return mockTags.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFiltering {
            if filteredMockTags.isEmpty && !firstLoad {
                let addNewCell = setUpAddNewTagCell(tableView: tableView)
                return addNewCell
            } else {
                firstLoad = false
                return setUpTimeTrackingTagCell(tableView: tableView, tag: filteredMockTags, index: indexPath.row)
            }
        } else {
            return setUpTimeTrackingTagCell(tableView: tableView, tag: mockTags, index: indexPath.row)
        }
    }
    
    func setUpTimeTrackingTagCell(tableView: UITableView, tag: [String], index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingTagTableViewCell.identifier)
        guard let timeTrackingTagCell = cell as? TimeTrackingTagTableViewCell else { return cell! }
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
        selectedTag = mockTags[indexPath.row]
        self.delegate?.getSelectedTag(tag: selectedTag ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    
    func addNewTag() {
        mockTags.append(searchText)
        isFiltering = false
        searchTagTextField.text = nil
        searchTagTextField.resignFirstResponder()
        print(mockTags)
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
