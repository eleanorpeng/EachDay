//
//  DetailJournalViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase
import Lottie

class DetailJournalViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var user: User?
    var journalData: [Journal]?
    var selectedMonth = 0
    var selectedYear = 2021
    var selectedFilterTag: String?
    let searchController = UISearchController(searchResultsController: nil)
    var isFiltering: Bool = false
    var filteredJournals: [Journal] = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    var selectedJournalIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.reloadData()
        createBarButtonItem()
        fetchData()
        fetchUser()
        setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setUpNavigationBar() {
        var monthTitle = ""
        switch selectedMonth {
        case 1:
            monthTitle = "January"
        case 2:
            monthTitle = "February"
        case 3:
            monthTitle = "March"
        case 4:
            monthTitle = "April"
        case 5:
            monthTitle = "May"
        case 6:
            monthTitle = "June"
        case 7:
            monthTitle = "July"
        case 8:
            monthTitle = "August"
        case 9:
            monthTitle = "September"
        case 10:
            monthTitle = "October"
        case 11:
            monthTitle = "November"
        case 12:
            monthTitle = "December"
        default:
            break
        }
        self.navigationItem.title = monthTitle
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
    
    func fetchData() {
        JournalManager.shared.fetchFilteredJournalData(selectedMonth: selectedMonth,
                                                       selectedYear: selectedYear, completion: { result in
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
    
    func fetchUser() {
        UserManager.shared.fetchUser(completion: { result in
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
        if journalData?.count ?? 0 == 0 {
            let customView = configureEmptyView()
            tableView.backgroundView = customView
        } else {
            tableView.backgroundView = nil
        }
        if isFiltering {
            if filteredJournals.count ?? 0 == 0 {
                tableView.backgroundView = configureEmptyView()
            } else {
                tableView.backgroundView = nil
            }
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
    
    func createAnimationView() -> AnimationView {
        var animationView = AnimationView()
        animationView = .init(name: "empty")
        animationView.animationSpeed = 1
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }
    
    func configureEmptyView() -> UIView {
        let customView = UIView()
        let animationView = createAnimationView()
        let messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.customLabel(text: isFiltering ?
                                    "Hmm... seems like you haven't written anything with this tag."
                                    : "Hmm... seems like you haven't written anything in this month.",
                                 font: UIFont.boldSystemFont(ofSize: 19))
        customView.addSubview(animationView)
        customView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 30),
            messageLabel.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -30),
            animationView.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            animationView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            animationView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            animationView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        return customView
    }
    
}

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
