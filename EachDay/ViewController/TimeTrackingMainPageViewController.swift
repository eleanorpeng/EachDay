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
    let stopWatch = Stopwatch()
    var elapsedTime: String? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var hasAddedNewRecord = false
//    var pauseTimeInterval: Date?
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
    var timeRecords: [TrackedTime] = []
    var startTime: TimeInterval?
    var pausedTime: Date?
    var isTiming = false
    var isPaused = false
    var timer = Timer()
    var pausedIntervals: [TimeInterval] = []
    var elapsedTimeInterval: TimeInterval?
    var endTime: TimeInterval?
    var taskName: String? {
        didSet {
            tableView.reloadData()
        }
    }
    var taskDescription: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var category: String?
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateNewTaskViewController {
            destination.delegate = self
        }
    }

}

extension TimeTrackingMainPageViewController: UITableViewDelegate, UITableViewDataSource, TimeTrackingTopTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
//        return timeRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingMainTableViewCell.identifier)
        guard let timeTrackingCell = cell as? TimeTrackingMainTableViewCell else { return cell! }
        if indexPath.row == 0 && hasAddedNewRecord {
            return configureTopCell(tableView: tableView)
        } else {
            return configurePastCell(tableView: tableView, index: indexPath.row + 1)
        }
    }
    
    func configureTopCell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingTopTableViewCell.identifier)
        guard let topCell = cell as? TimeTrackingTopTableViewCell else { return cell! }
        topCell.delegate = self
        topCell.layoutCell(activity: taskName ?? "", description: taskDescription ?? "", elapsedTime: elapsedTime ?? "00:00:00", duration: "9:00 AM - 5:00 PM", color: .yellow)
        topCell.configurePauseButtonImage(image: (isPaused ? UIImage(named: "play-button")! : UIImage(named: "pause"))!)
        return topCell
    }
    
    func configurePastCell(tableView: UITableView, index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingMainTableViewCell.identifier)
        guard let pastCell = cell as? TimeTrackingMainTableViewCell else { return cell! }
        pastCell.layoutCell(activity: "Reading", elapsedTime: "00:25:35", duration: "3:10 - 3:40 PM", description: "Description")
        return pastCell
    }
    
    func stopTiming() {
        stop()
        tableView.reloadData()
    }
    
    func pauseTiming() {
        pause()
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

extension TimeTrackingMainPageViewController: CreateNewTaskViewControllerDelegate {
    func getRecord(task: String, description: String) {
        taskName = task
        taskDescription = description
    }

    func getCategory(category: String) {
        
    }
    
    func getTaskName(task: String) {
        taskName = task
    }
    
    func getDescription(description: String) {
        taskDescription = description
        tableView.reloadData()
    }
    
//    func startTiming() {
//        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateElapsedTimeLabel(timer:)), userInfo: nil, repeats: true)
//        stopWatch.start()
//        stopWatch.begin()
//        elapsedTime = stopWatch.newElapsedTimeAsString
//        print("IN main: \(elapsedTime)")
//
//        tableView.reloadData()
//    }
//
//    @objc func updateElapsedTimeLabel(timer: Timer) {
//        if stopWatch.isRunning {
//            elapsedTime = stopWatch.elapsedTimeAsString
//            tableView.reloadData()
//        } else {
//            timer.invalidate()
//        }
//    }
    
    func startTiming() {
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            startTime = Date().timeIntervalSinceReferenceDate
        }
        isTiming = true
        isPaused = false
        pausedIntervals = []
        hasAddedNewRecord = true
        updateTimer()
    }
    
    @objc func updateTimer() {
        let currentTime = Date().timeIntervalSinceReferenceDate
        var pausedSeconds = pausedIntervals.reduce(0) { $0 + $1 }
        if let pausedTime = pausedTime {
            pausedSeconds += Date().timeIntervalSince(pausedTime)
        }
        elapsedTimeInterval = currentTime - startTime! - pausedSeconds
        elapsedTime = String(format: "%02d:%02d:%02d",
                             Int( elapsedTimeInterval! / 3600),
                             Int((elapsedTimeInterval! / 60).truncatingRemainder(dividingBy: 60)), Int(elapsedTimeInterval!.truncatingRemainder(dividingBy: 60)))
        tableView.reloadData()
    }
    
    func pause() {
        if isTiming == true && isPaused == false {
            timer.invalidate()
            isPaused = true
            isTiming = false
            pausedTime = Date()
        } else if isTiming == false && isPaused == true {
            let pausedSeconds = Date().timeIntervalSince(pausedTime!)
            pausedIntervals.append(pausedSeconds)
            pausedTime = nil
            
            if !timer.isValid {
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                isPaused = false
                isTiming = true
            }
        }
        tableView.reloadData()
    }
    
    func stop() {
        timer.invalidate()
        endTime = elapsedTimeInterval
        updateTimer()
    }
}
