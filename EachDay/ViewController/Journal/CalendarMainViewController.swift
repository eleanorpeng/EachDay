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
import FirebaseAuth

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
    let defaultColor = UIColor(r: 247, g: 174, b: 0)
    var calendarData: CalendarView?
    let customAlert = CustomAlert()
    var calendarColors: [String]?
    var currentDate = Date()
    var journalData: [Journal]?
    var timeCapsule: [Journal]?
    var selectedYear = 2020
    let colorPicker = SlideUpView()
    var calendarColor: UIColor?
    var changeColorIndex: Int?
    var isChangingColor = false
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerSelected(_ sender: Any) {
        selectedYear = datePicker.date.year()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        initialSetUp()
        isChangingColor = false
//        if let colors = UserDefaults.standard.array(forKey: "calendarColors") as? [UIColor] {
//            calendarData = CalendarView(colors: colors)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.clipsToBounds = true
        fetchTimeCapsuleData()
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
    
    func fetchTimeCapsuleData() {
        JournalManager.shared.fetchTimeCapsuleData(currentDate: Date(), completion: { result in
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
    
    func fetchUser() {
        UserManager.shared.fetchUser(completion: { result in
            switch result {
            case .success(let user):
                self.user = user[0]
                if let name = self.user?.name, let color = self.user?.calendarColors {
                    self.nameLabel.text = "Hi, \(name)"
                    self.calendarColors = color
                    self.calendarData = CalendarView(colors: self.calendarColors ?? [""])
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
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
        if !isChangingColor {
            collectionView.scrollToItem(at: IndexPath(row: currentDate.month() - 1, section: 0),
                                        at: [.centeredVertically, .centeredHorizontally],
                                        animated: true)
        }
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

extension CalendarMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CalendarMainCollectionViewCellDelegate, SlideUpViewDelegate {
    func handleChangeColorButton(sender: Any) {
        colorPicker.delegate = self
        colorPicker.showSlideView(on: self)
        isChangingColor = true
        if let button = sender as? UIButton {
            changeColorIndex = button.tag
        }
    }
    
    func changeCalendarColor(color: UIColor) {
        calendarColor = color
        let calendarColorHex = calendarColor?.toHexString()
        calendarData?.colors?[changeColorIndex ?? -1] = calendarColorHex ?? ""
        UserManager.shared.updateCalendarColor(color: (calendarData?.colors)!, completion: { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        })
//        UserDefaults.setValue(calendarData?.colors, forKey: "calendarColors")
        
//        collectionView.reloadData()
//        isChangingColor = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarMainCollectionViewCell.identifier, for: indexPath)
        guard let cardCell = cell as? CalendarMainCollectionViewCell else { return cell }
        cardCell.delegate = self
        if let month = calendarData?.month[indexPath.row], let monthString = calendarData?.monthText[indexPath.row], let color = calendarData?.colors?[indexPath.row] {
            cardCell.layoutCell(monthNum: String(month), monthText: monthString, color: UIColor(hexString: color))
        }
//        cardCell.layoutCell(monthNum: String(monthNum[indexPath.row]), monthText: monthText[indexPath.row], color: UIColor(r: 247, g: 174, b: 0))
//        if indexPath.row == changeColorIndex {
//            cardCell.layoutCell(monthNum: String(monthNum[indexPath.row]), monthText: monthText[indexPath.row], color: calendarColor ?? UIColor(r: 247, g: 174, b: 0))
//        }
        cardCell.changeColorButton.tag = indexPath.row
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
