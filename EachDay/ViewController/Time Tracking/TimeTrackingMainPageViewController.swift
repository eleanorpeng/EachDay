//
//  TimeTrackingMainPageViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/27.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class TimeTrackingMainPageViewController: UIViewController {

    let helper = Helper()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createNewTaskButton: UIButton!
    @IBAction func createNewTask(_ sender: Any) {
        performSegue(withIdentifier: "ShowCreateNewTaskSegue", sender: self)
    }
    
    let stopWatch = Stopwatch()
    var elapsedTime: String? {
        didSet {
            self.tableView.reloadData()
        }
    }
    @IBAction func timeTrackingSummaryButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTimeTrackingSummarySegue", sender: self)
    }
    var hasNewRecord = false
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
    var timeRecords: [TrackedTime]? {
        didSet {
            tableView.reloadData()
        }
    }
    var startTime: TimeInterval?
    var pausedTime: Date?
    var isTiming = false
    var isPaused = false
    var timer = Timer()
    var pausedIntervals: [TimeInterval] = []
    var elapsedTimeInterval: TimeInterval?
    var totalTime: [String : TimeInterval]?
    var endTime: TimeInterval?
    var endTimeTS: Timestamp?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        setUpButton()
        totalTime = [:]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchTimeRecord()
    }
    func fetchTimeRecord() {
        TimeTrackingManager.shared.fetchTimeRecord(userDocID: "Eleanor", completion: { result in
            switch result {
            case .success(let trackedTime):
                self.timeRecords = trackedTime
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func getSomeDate() {
        var calendar = Calendar.current
        // Use the following line if you want midnight UTC instead of local time
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
        print(midnight)
        print(tomorrow)
    }
  
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
    
    func calculateTotalTime() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateNewTaskViewController {
            stop()
            destination.delegate = self
        }
    }

}

extension TimeTrackingMainPageViewController: UITableViewDelegate, UITableViewDataSource, TimeTrackingTopTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeRecords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingMainTableViewCell.identifier)
        guard let timeTrackingCell = cell as? TimeTrackingMainTableViewCell else { return cell! }
        if indexPath.row == 0 && hasNewRecord {
            return configureTopCell(tableView: tableView)
        } else {
            return configurePastCell(tableView: tableView, index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureTopCell(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingTopTableViewCell.identifier)
        guard let topCell = cell as? TimeTrackingTopTableViewCell else { return cell! }
        topCell.delegate = self
        topCell.layoutCell(activity: taskName ?? "", description: taskDescription ?? "", elapsedTime: elapsedTime ?? "00:00:00", duration: "", color: .yellow)
        topCell.configurePauseButtonImage(image: (isPaused ? UIImage(named: "play-button")! : UIImage(named: "pause"))!)
        return topCell
    }

    func configurePastCell(tableView: UITableView, index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingMainTableViewCell.identifier)
        let trackedTimeVM = TrackedTimeViewModel(trackedTime: (timeRecords?[index])!)
        guard let pastCell = cell as? TimeTrackingMainTableViewCell else { return cell! }
        pastCell.layoutCell(activity: trackedTimeVM.taskName,
                            elapsedTime: trackedTimeVM.duration,
                            duration: "\(trackedTimeVM.startTime) - \(trackedTimeVM.endTime)",
                            description: trackedTimeVM.taskDescription)
        return pastCell
    }
    
    func stopTiming() {
        stop()
        tableView.reloadData()
    }
    
    func pauseTiming() {
        pause()
    }
    
    func addData() {
        let startTimeTS = Timestamp.init(date: Date(timeIntervalSince1970: startTime ?? 0))
        let today = Timestamp.init(date: Date())
        var timeRecord = TrackedTime(date: today,
                                     startTime: startTimeTS,
                                     endTime: endTimeTS ?? startTimeTS,
                                     taskName: taskName ?? "",
                                     id: "",
                                     duration: elapsedTimeInterval ?? 0,
                                     taskDescrpition: taskDescription ?? "")
        TimeTrackingManager.shared.uploadTimeRecord(userDocID: "Eleanor", record: &timeRecord, completion: { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        })
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        taskName = icons[indexPath.row].name
        taskDescription = ""
        startTiming()
        updateTimer()
    }
}

extension TimeTrackingMainPageViewController: CreateNewTaskViewControllerDelegate {
   
    func getTaskName(task: String) {
        taskName = task
    }
    
    func getDescription(description: String) {
        taskDescription = description
        tableView.reloadData()
    }
    
    func startTiming() {
        hasNewRecord = true
        if isPaused {
            pause()
        }
        timer.invalidate()
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            startTime = Date().timeIntervalSince1970
        }
        isTiming = true
        isPaused = false
        pausedIntervals = []
        addData()
        updateTimer()
    }
    
    @objc func updateTimer() {
        let currentTime = Date().timeIntervalSince1970
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
        endTimeTS = Timestamp(date: Date())
        TimeTrackingManager.shared.updateFields(userDocID: "Eleanor",
                                                endTime: endTimeTS!,
                                                duration: elapsedTimeInterval ?? 0)
        totalTime?[taskName ?? ""] = elapsedTimeInterval
        print(totalTime)
        hasNewRecord = false
        tableView.reloadData()
        isPaused = false
        isTiming = false
        pausedIntervals = []
        updateTimer()
    }
}
