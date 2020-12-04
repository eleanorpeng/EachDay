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
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
//        fetchJournalData(userDocID: "Eleanor")
        JournalManager.shared.fetchFilteredJournalData(userDocID: "Eleanor", selectedMonth: selectedMonth, currentDate: Date().timeIntervalSince1970, completion: { result in
            switch result {
            case .success(let journal):
                self.journalData = journal
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func fetchJournalData(userDocID: String) {
        db.collection("User").document(userDocID).collection("Journal").addSnapshotListener({ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents")
                return
            }
            let allJournalData = documents.compactMap({ queryDocumentSnapshot -> Journal? in
                return try? queryDocumentSnapshot.data(as: Journal.self)
            })
            self.journalData = allJournalData.filter({
                let month = Date(timeIntervalSince1970: $0.date).month()
                return month == self.selectedMonth
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

extension DetailJournalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JournalDetailTableViewCell.identifier, for: indexPath)
        guard let journalCell = cell as? JournalDetailTableViewCell else { return cell }
        guard let data = journalData?[indexPath.row] else { return cell }
        let journalViewModel = JournalViewModel(journal: data)
        journalCell.layoutCell(date: String(journalViewModel.date),
                               day: journalViewModel.day,
                               title: journalViewModel.title,
                               content: journalViewModel.content)
        journalCell.layer.cornerRadius = 10
        journalCell.clipsToBounds = true
        journalCell.contentView.layer.cornerRadius = 10.0
        journalCell.contentView.layer.borderWidth = 1.0
        journalCell.contentView.layer.borderColor = UIColor.clear.cgColor
        journalCell.contentView.layer.masksToBounds = false
        journalCell.layer.shadowColor = UIColor.lightGray.cgColor
        journalCell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        journalCell.layer.shadowRadius = 4.0
        journalCell.layer.shadowOpacity = 1.0
        journalCell.layer.masksToBounds = false
        journalCell.layer.shadowPath = UIBezierPath(roundedRect: journalCell.bounds, cornerRadius: journalCell.contentView.layer.cornerRadius).cgPath
        return journalCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
