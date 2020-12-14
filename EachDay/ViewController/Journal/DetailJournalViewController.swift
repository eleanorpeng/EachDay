//
//  DetailJournalViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

class DetailJournalViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var user: User?
    var journalData: [Journal]?
    var selectedMonth = 0
    var selectedFilterTag: String?
    let searchController = UISearchController(searchResultsController: nil)
    var isFiltering: Bool = false
//        return searchController.isActive && !isSearchBarEmpty
        
    
    var filteredJournals: [Journal] = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
//    let db = Firestore.firestore()
    var selectedJournalIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.reloadData()
        createBarButtonItem()
        fetchData(userDocID: "Eleanor")
//        createSearchBar()
        fetchUser(userDocID: "Eleanor")
  
    }
    
    func createBarButtonItem() {
        let filterButton = UIButton(type: .custom)
        filterButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        filterButton.setImage(UIImage(named: "funnel"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterJournal), for: .touchUpInside)
        
        let filterBarButton = UIBarButtonItem(customView: filterButton)
        let currWidth = filterBarButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = filterBarButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelFiltering))
        self.navigationItem.rightBarButtonItem = isFiltering ? cancelBarButton : filterBarButton

    }
    
    @objc func cancelFiltering() {
        isFiltering = false
        tableView.reloadData()
        createBarButtonItem()
    }
    @objc func filterJournal() {
        performSegue(withIdentifier: "ShowFilterJournalTagsSegue", sender: self)
    }
    
    func fetchData(userDocID: String) {
        JournalManager.shared.fetchFilteredJournalData(userDocID: userDocID, selectedMonth: selectedMonth, currentDate: Date().timeIntervalSince1970, completion: { result in
            switch result {
            case .success(let journal):
                self.journalData = journal.filter({
                    !$0.isTimeCapsule
                })
                if self.isFiltering {
                    guard let journalData = self.journalData else { return }
                    self.filteredJournals = journalData.filter({
                        $0.tags.contains(self.selectedFilterTag ?? "")
                    })
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func fetchUser(userDocID: String) {
        UserManager.shared.fetchUser(userID: userDocID, completion: { result in
            switch result {
            case .success(let user):
                self.user = user[0]
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func createSearchBar() {
//        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search journals with tags"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        guard let journalData = journalData else { return }
        filteredJournals = journalData.filter({
            $0.tags.contains(searchText)
        })
        tableView.reloadData()
    }
    
//    func fetchJournalData(userDocID: String) {
//        db.collection("User").document(userDocID).collection("Journal").addSnapshotListener({ querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("Error fetching documents")
//                return
//            }
//            let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
//                return try? queryDocumentSnapshot.data(as: Journal.self)
//            })
//            self.journalData = allJournalData.filter({
//                let month = Date(timeIntervalSince1970: $0.date).month()
//                return month == self.selectedMonth
//            })
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        })
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailJournalContentViewController {
            destination.journalData = isFiltering ? self.filteredJournals[selectedJournalIndex] : self.journalData?[selectedJournalIndex]
        }
        if let destination = segue.destination as? FilterJournalViewController {
            destination.tags = user?.journalTags
            destination.delegate = self
        }
    }
}

extension DetailJournalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredJournals.count
        }
        return journalData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JournalDetailTableViewCell.identifier, for: indexPath)
        guard let journalCell = cell as? JournalDetailTableViewCell else { return cell }
        guard let data = journalData?[indexPath.row] else { return cell }
        var journalViewModel: JournalViewModel
        if isFiltering {
            journalViewModel = JournalViewModel(journal: filteredJournals[indexPath.row])
        } else {
            journalViewModel = JournalViewModel(journal: data)
        }
        
        journalCell.layoutCell(date: String(journalViewModel.date),
                               day: journalViewModel.day,
                               title: journalViewModel.title,
                               content: journalViewModel.content,
                               tags: journalViewModel.tags)
        print("Index: \(indexPath.row), tags: \(journalViewModel.tags)")
//        print(journalViewModel.tags)
        if journalViewModel.tags.contains("Time Capsule") {
            journalCell.displayTimeCapsuleIndicator()
        }
        journalCell.collectionView.reloadData()
        return journalCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedJournalIndex = indexPath.row
        performSegue(withIdentifier: "ShowDetailJournalContentSegue", sender: self)
    }
    
}
//
//extension DetailJournalViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        let searchBar = searchController.searchBar
//        filterContentForSearchText(searchBar.text!)
//    }
//}

extension DetailJournalViewController: FilterJournalViewControllerDelegate {
    func getFilteredTag(tag: String) {
        selectedFilterTag = tag
        isFiltering = true
        guard let journalData = journalData else { return }
        filteredJournals = journalData.filter({
            $0.tags.contains(tag)
        })
        tableView.reloadData()
        createBarButtonItem()
    }
    
}
