//
//  TimeTrackingMainPageViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit

class TimeTrackingMainPageViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
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
    }

}

extension TimeTrackingMainPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingMainTableViewCell.identifier, for: indexPath)
        guard let timeTrackingCell = cell as? TimeTrackingMainTableViewCell else { return cell }
        if indexPath.row == 0 {
            timeTrackingCell.layoutCell(activity: "Reading", activityDuration: "00:25:35", time: "3:10 - 3:40 PM", description: "Description")
            timeTrackingCell.changeActivityDurationColor(color: UIColor(r: 247, g: 174, b: 0))
            timeTrackingCell.activityLabel.backgroundColor = .yellow
        } else {
            timeTrackingCell.layoutCell(activity: "Reading", activityDuration: "00:25:35", time: "3:10 - 3:40 PM", description: "Description")
        }
        return timeTrackingCell
    }
    
}

extension TimeTrackingMainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
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
