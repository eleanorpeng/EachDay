//
//  CalendarMainViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class CalendarMainViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var userProfileButtonClicked: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedMonth = 0
    var user: User?
    let monthNum = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    let monthText = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    var currentDate = Date()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
//        JournalManager.shared.fetchJournalData(userDocID: "JIbda5gvgUa9DhWS8NLw", selectedMonth: 12, completion: { result in
//            switch result {
//            case .success(let journal):
//                print(journal)
//            case .failure(let error):
//                print(error)
//            }
//        })
    }
    
    func initialSetUp() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        dateLabel.text = currentDate.getFormattedDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellsLayout()
        collectionView.scrollToItem(at: IndexPath(row: currentDate.month() - 1, section: 0),
                                    at: [.centeredVertically, .centeredHorizontally],
                                    animated: true)
    }

    func updateCellsLayout() {
        let centerX = collectionView.contentOffset.x + (collectionView.frame.size.width)/2

        for cell in collectionView.visibleCells {
            var offsetX = centerX - cell.center.x
            if offsetX < 0 {
                offsetX *= -1
            }
            cell.transform = CGAffineTransform.identity
            let offsetPercentage = offsetX / (view.bounds.width * 2.7)
            let scaleX = 1-offsetPercentage
            cell.transform = CGAffineTransform(scaleX: scaleX, y: scaleX)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellsLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailJournalViewController {
            destination.selectedMonth = selectedMonth
            self.navigationController?.navigationBar.isHidden = false
        }
    }

}

extension CalendarMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarMainCollectionViewCell.identifier, for: indexPath)
        guard let cardCell = cell as? CalendarMainCollectionViewCell else { return cell }
        cardCell.layoutCell(monthNum: String(monthNum[indexPath.row]), monthText: monthText[indexPath.row])
        cardCell.layer.cornerRadius = 10
        cardCell.clipsToBounds = true
        cardCell.contentView.layer.cornerRadius = 10.0
        cardCell.contentView.layer.borderWidth = 1.0
        cardCell.contentView.layer.borderColor = UIColor.clear.cgColor
        cardCell.contentView.layer.masksToBounds = false
        cardCell.layer.shadowColor = UIColor.lightGray.cgColor
        cardCell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cardCell.layer.shadowRadius = 4.0
        cardCell.layer.shadowOpacity = 1.0
        cardCell.layer.masksToBounds = false
        cardCell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        return cardCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize: CGSize = collectionView.bounds.size

        cellSize.width -= collectionView.contentInset.left * 2
        cellSize.width -= collectionView.contentInset.right * 2
        cellSize.height = cellSize.width + 70

        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedMonth = monthNum[indexPath.row]
        performSegue(withIdentifier: "ShowJournalDetailSegue", sender: self)
    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        let screenWidth = view.frame.width
//        let itemSize = collectionView.frame.width - 20
//        return (screenWidth - itemSize) / 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//    }
    
}
