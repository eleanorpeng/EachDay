//
//  CalendarMainViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/2.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import Kingfisher

class CalendarMainViewController: UIViewController, CustomAlertDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var userProfileButton: UIButton!
    @IBAction func userProfileButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowUserSettingSegue", sender: self)
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedMonth = 0
    var user: User?
    let monthNum = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    let monthText = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    let customAlert = CustomAlert()
    var currentDate = Date()
    var journalData: [Journal]?
    var timeCapsule: [Journal]?
    var selectedYear = 2020
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerSelected(_ sender: Any) {
        selectedYear = datePicker.date.year()
        print(selectedYear)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.clipsToBounds = true
        fetchData(userDocID: "Eleanor")
        fetchUser(userDocID: "Eleanor")
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveProfileImage(_:)), name: Notifications.receiveProfileImageNotification, object: nil)
    }
    
    func createTimeCapAlert() {
        NotificationCenter.default.post(Notification(name: Notifications.receiveTimeCapsule, object: nil))
        customAlert.delegate = self
        customAlert.showAlert(on: self)
    }

    @objc func dismissAlert() {
        NotificationCenter.default.post(Notification(name: Notifications.dismissTimeCapsule, object: nil))
        performSegue(withIdentifier: "ShowJournalContentSegue", sender: self)
//        customAlert.dismissAlert()
    }
    
    func fetchData(userDocID: String) {
        JournalManager.shared.fetchTimeCapsuleData(userDocID: "Eleanor", currentDate: Date().timeIntervalSince1970, completion: { result in
            switch result {
            case .success(let timeCapsule):
                self.timeCapsule = timeCapsule
                guard let timeCapsule = self.timeCapsule else { return }
                if !timeCapsule.isEmpty {
                    self.createTimeCapAlert()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func fetchUser(userDocID: String) {
        UserManager.shared.fetchUser(userID: userDocID, completion: { result in
            switch result {
            case .success(let user):
                self.user = user[0]
                guard self.user?.image != nil else { return }
                guard let url = URL(string: self.user?.image ?? "") else { return }
                let resource = ImageResource(downloadURL: url)
                KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    self.userProfileButton.setImage(image ?? UIImage(named: "user"), for: .normal)
                })
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @objc func didReceiveProfileImage(_ notification: Notification) {
        if let profileImage = notification.object as? UIImage {
            userProfileButton.setImage(profileImage, for: .normal)
        }
    }
    
    func initialSetUp() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        dateLabel.text = currentDate.getFormattedDate()
        userProfileButton.clipsToBounds = true
        userProfileButton.layer.cornerRadius = userProfileButton.frame.width / 2
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
            destination.selectedYear = selectedYear
            self.navigationController?.navigationBar.isHidden = false
        }
        if let destination = segue.destination as? UserSettingViewController {
            self.navigationController?.navigationBar.isHidden = false
        }
        if let destination = segue.destination as? DetailJournalContentViewController {
            self.navigationController?.navigationBar.isHidden = false
            destination.isTimeCapsule = true
            destination.journalData = timeCapsule?[0]
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
    
}
