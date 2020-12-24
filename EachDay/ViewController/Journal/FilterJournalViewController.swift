//
//  FilterJournalViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/12.
//

import UIKit

class FilterJournalViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FilterJournalViewControllerDelegate?
    var tags: [String]?
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var filteredTags: [String] = []
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
   
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        createSearchBar()
    }

    func createSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search journals with tags"
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func filterContentForSearchText(_ searchText: String) {
        guard let tags = tags else { return }
        filteredTags = tags.filter({
            $0.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension FilterJournalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredTags.count
        }
        return tags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterJournalTableViewCell.identifier, for: indexPath)
        guard let tagCell = cell as? FilterJournalTableViewCell else { return cell }
        if isFiltering {
            tagCell.layoutCell(tag: filteredTags[indexPath.row])
        } else {
            tagCell.layoutCell(tag: tags?[indexPath.row] ?? "")
        }
        return tagCell
        //when tag is clicked, move the text to the textfield, click search to navigate back to the previous view (should be sorted already)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var selectedText: String
        if isFiltering {
            selectedText = filteredTags[indexPath.row]
        } else {
            selectedText = tags?[indexPath.row] ?? ""
        }
        searchController.searchBar.text = selectedText
    }
}

extension FilterJournalViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.getFilteredTag(tag: searchBar.text!)
        self.navigationController?.popViewController(animated: true)
    }
}

protocol FilterJournalViewControllerDelegate: AnyObject {
//    func getSearchStatus(isSearching: Bool)
    func getFilteredTag(tag: String)
}
