//
//  TimeTrackingMainPageViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit

class TimeTrackingMainPageViewController: UIViewController {

    let helper = Helper()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createNewTaskButton: UIButton!
    @IBAction func createNewTask(_ sender: Any) {
        performSegue(withIdentifier: "ShowCreateNewTaskSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        setUpButton()
    }
    
    let icons: [TimeTrackingButton] = [
        TimeTrackingButton(name: "Sleep", icon: "sleep"),
        TimeTrackingButton(name: "Work", icon: "work"),
        TimeTrackingButton(name: "Eat", icon: "eat"),
        TimeTrackingButton(name: "Workout", icon: "workout"),
        TimeTrackingButton(name: "Music", icon: "music"),
        TimeTrackingButton(name: "Read", icon: "read"),
        TimeTrackingButton(name: "Commute", icon: "commute"),
        TimeTrackingButton(name: "TV", icon: "tv")
    ]
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.collectionViewLayout = layout
        tableView.separatorColor = .clear
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func createStartTimingButton() {
        let buttonBackground = helper.createCircularBackground(view: view, color: .black, width: 40, height: 40)
        let button = helper.createButton(background: buttonBackground, image: UIImage(named: "play")!, padding: 10)
        NSLayoutConstraint.activate([
            buttonBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonBackground.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func setUpButton() {
        createNewTaskButton.layer.cornerRadius = 8
        createNewTaskButton.clipsToBounds = true
   
    }

}

extension TimeTrackingMainPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingMainTableViewCell.identifier)
        guard let timeTrackingCell = cell as? TimeTrackingMainTableViewCell else { return cell! }
        if indexPath.row == 0 {
            timeTrackingCell.layoutFirstCell(activity: "Reading", activityDuration: "00:25:35", time: "3:10 - 3:40 PM", description: "Description", color: .yellow)
        } else {
            timeTrackingCell.layoutCell(activity: "Reading", activityDuration: "00:25:35", time: "3:10 - 3:40 PM", description: "Description")
        }
        return timeTrackingCell

    }
   
}

extension TimeTrackingMainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeTrackingMainCollectionViewCell.identifier, for: indexPath)
        guard let timeTrackingCell = cell as? TimeTrackingMainCollectionViewCell else { return cell }
        let icon = icons[indexPath.row]
        timeTrackingCell.layoutCell(imageName: icon.icon, label: icon.name)
        return timeTrackingCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = view.frame.width
        let height = collectionView.frame.height
        return CGSize(width: screenWidth/6.25, height: height / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let screenWidth = view.frame.width
        let itemSpace = screenWidth - 32
        let itemSize = screenWidth / 6
        return (itemSpace - (itemSize * 4)) / 3

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
