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

    var hasAddedNew = false
    let helper = Helper()
    let loadingView = LoadingView()
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
    var trackedTime: [TrackedTime]? {
        didSet {
            tableView.reloadData()
        }
    }
    var startTime: TimeInterval?
    var pausedTime: Date?
    var isTiming = false {
        didSet {
            if isTiming || isPaused {
                createNewTaskButton.isEnabled = false
                createNewTaskButton.backgroundColor = .lightGray
            } else {
                createNewTaskButton.isEnabled = true
                createNewTaskButton.backgroundColor = UIColor(r: 247, g: 174, b: 0)
            }
        }
    }
    var isPaused = false
    var timer = Timer()
    var pausedIntervals: [TimeInterval] = []
    var elapsedTimeInterval: TimeInterval?
    @IBOutlet weak var totalTimeLabel: UILabel!
    var totalTime: Double? = 0
    
    var trackedTimeDic: [String : TimeInterval]?
    var endTime: TimeInterval?
    var endTimeTS: Timestamp?
    var trackedTimeCategories: [String]?
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
        fetchUser()
        trackedTimeDic = [:]
        fetchTimeRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchTimeRecord()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard hasAddedNew else { return }
    }
    
    func fetchUser() {
        JournalManager.shared.fetchUser(completion: { result in
            switch result {
            case .success(let user):
                self.trackedTimeCategories = user[0].trackTimeCategories
            case .failure(let error):
                print(error)
            }
        })
    }

    func fetchTimeRecord() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
        
        let midnightTS = Timestamp(date: midnight)
        let tomorrowTS = Timestamp(date: tomorrow)
        
        TimeTrackingManager.shared.fetchFilteredTimeRecord(startDate: midnightTS, endDate: tomorrowTS, completion: { result in
            switch result {
            case .success(let trackedTime):
                self.trackedTime = trackedTime
                DispatchQueue.main.async {
                    self.resumeFromBackground()
                    self.tableView.reloadData()
                    self.displayTotalTime()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
  
    func resumeFromBackground() {
        if let trackedTime = trackedTime {
            guard !trackedTime.isEmpty else { return }
            let filteredTrackedTime = trackedTime.filter({
                $0.startTime == $0.endTime
            })
            guard !filteredTrackedTime.isEmpty else { return }
            trackedTime.forEach({
                if $0.startTime == $0.endTime {
                    let currentTime = Timestamp(date: Date()).dateValue().timeIntervalSince1970
                    hasNewRecord = true
                    taskName = $0.taskName
                    taskDescription = $0.taskDescrpition
                    let pauseSeconds = $0.pauseIntervals?.reduce(0) { $0 + $1 }
                    startTime = $0.startTime.dateValue().timeIntervalSince1970
                    if let pauseTime = $0.pauseTime {
                        self.pausedTime = pauseTime
                        self.isPaused = true
                        self.isTiming = false
                        let lastTimeInterval = currentTime - pauseTime.timeIntervalSince1970
                        elapsedTimeInterval = currentTime -
                            ($0.startTime).dateValue().timeIntervalSince1970
                            - (pauseSeconds ?? 0) - lastTimeInterval
                    } else {
                        if let pauseIntervals = $0.pauseIntervals {
                            self.pausedIntervals = pauseIntervals
                        }
                        self.isPaused = false
                        elapsedTimeInterval = currentTime -
                            ($0.startTime).dateValue().timeIntervalSince1970
                            - (pauseSeconds ?? 0)
                        if !timer.isValid {
                            timer.invalidate()
                            timer = Timer.scheduledTimer(timeInterval: 1,
                                                         target: self,
                                                         selector: #selector(updateTimer),
                                                         userInfo: nil,
                                                         repeats: true)
                            isTiming = true
                        }
                    }
                    elapsedTime = elapsedTimeInterval?.getFormattedTime()
                    tableView.reloadData()
                }
            })
        }
    }
    
    func displayTotalTime() {
        self.calculateTotalTime()
        totalTime = 0
        guard let recordedTime = trackedTimeDic else { return }
        for (category, time) in recordedTime {
            totalTime! += time
        }
        totalTimeLabel.text = totalTime?.getFormattedTime() ?? "00:00:00"
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
        trackedTimeDic = [:]
        guard let trackedTime = trackedTime else { return }

        for num in 0..<trackedTime.count {
            let time = trackedTime[num]
            if let previousRecord = self.trackedTimeDic?[time.taskName] {
                let duration = previousRecord + time.duration
                self.trackedTimeDic?.updateValue(duration, forKey: time.taskName)
            } else {
                self.trackedTimeDic?.updateValue(time.duration, forKey: time.taskName)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CreateNewTaskViewController {
            destination.delegate = self
        }
        if let destination = segue.destination as? TimeTrackingSummaryViewController {
            destination.timeRecords = self.trackedTimeDic
        }
    }

}

extension TimeTrackingMainPageViewController: UITableViewDelegate, UITableViewDataSource, TimeTrackingTopTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackedTime?.count ?? 0
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
        let trackedTimeVM = TrackedTimeViewModel(trackedTime: (trackedTime?[index])!)
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
                                     taskDescrpition: taskDescription ?? "",
                                     pauseIntervals: [0],
                                     pauseTime: nil)
        TimeTrackingManager.shared.uploadTimeRecord(record: &timeRecord, completion: { result in
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
        stop()
        hasAddedNew = true
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
            isTiming = false
            pausedTime = Date()
            TimeTrackingManager.shared.updatePauseTime(pauseTime: pausedTime ?? Date(), completion: { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print(error)
                }
            })
            isPaused = true
            updateTimer()
        } else if isTiming == false && isPaused == true {
            let pausedSeconds = Date().timeIntervalSince(pausedTime!)
            pausedIntervals.append(pausedSeconds)
            TimeTrackingManager.shared.updatePauseIntervals(pauseIntervals: pausedIntervals, completion: { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print(error)
                }
            })
            pausedTime = nil
            if !timer.isValid {
                timer.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                isPaused = false
                isTiming = true
                TimeTrackingManager.shared.deletePauseTime(completion: { result in
                    switch result {
                    case .success(let message):
                        print(message)
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        }
        tableView.reloadData()
    }
    
    func stop() {
        guard isTiming || isPaused else { return }
        loadingView.startLoadingWithDots(on: self)
        timer.invalidate()
        endTime = elapsedTimeInterval
        endTimeTS = Timestamp(date: Date())
        TimeTrackingManager.shared.updateFields(endTime: endTimeTS!,
                                                duration: elapsedTimeInterval ?? 0, completion: { result in
                                                    switch result {
                                                    case .success(let message):
                                                        print(message)
                                                        self.loadingView.dismissLoadingDots()
                                                    case .failure(let error):
                                                        print(error)
                                                    }
                                                })
        trackedTimeDic?[taskName ?? ""] = elapsedTimeInterval
        hasNewRecord = false
        pausedTime = nil
        TimeTrackingManager.shared.deletePauseTime(completion: { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        })
        isPaused = false
        isTiming = false
        endTimeTS = nil
        pausedIntervals = []
        updateTimer()
    }
    
}
