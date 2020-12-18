//
//  TimeTrackingSummaryViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/1.
//

import UIKit
import Charts
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

class TimeTrackingSummaryViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func selectedIndexChanged(_ sender: Any) {
        selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        setUpData()
    }
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var writeReflectionButton: UIButton!
    @IBAction func writeReflectionButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteReflectionSegue", sender: self)
    }
    let helper = Helper()
    var selectedSegmentIndex = 0
    var timeRecords: [String:TimeInterval]?
    var trackedTime: [TrackedTime]?
    var trackedTimeCategories: [String]?
    var percentageTimeValues: [Double]?
    var timeValues: [Double]? {
        didSet {
            tableView.reloadData()
        }
    }
    var categories: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    var startDateTS: Timestamp?
    var endDateTS: Timestamp?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        createBackButton()
    }
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        pieChartView.delegate = self
        setUpData()
        writeReflectionButton.layer.cornerRadius = 10
        writeReflectionButton.clipsToBounds = true
    }
    
    func setUpData() {
        switchSegmentIndex()
        fetchFilteredData(startDate: startDateTS, endDate: endDateTS)
        
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pieChartView.entryLabelColor = .black
    }
    
    func calculatePieChartValue() {
        guard let timeRecord = self.timeRecords else { return }
        categories = Array(timeRecord.keys)
        timeValues = Array(timeRecord.values)
        guard let sum = timeValues?.reduce(0, +) else { return }
        percentageTimeValues = timeValues?.map({
            return ($0 / sum) * 100
        })
        tableView.reloadData()
    }
    
    func createBackButton() {
        let backButtonBackground = helper.createCircularBackground(view: view, color: UIColor(hexString: "F1F1F1"), width: 40, height: 40)
        let button = helper.createButton(background: backButtonBackground, image: UIImage(named: "back")!, padding: 10)
        NSLayoutConstraint.activate([
            backButtonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButtonBackground.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    func setUpPieChart(value: [Double], label: [String]) {
        let entries = (0..<label.count).map { (num) -> PieChartDataEntry in
            return PieChartDataEntry(value: value[num],
                                     label: label[num])
        }
        
        let set = PieChartDataSet(entries: entries, label: "Activities")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        let data = PieChartData(dataSet: set)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        pieChartView.data = data
        pieChartView.highlightValues(nil)
    }
    
    func fetchFilteredData(startDate: Timestamp?, endDate: Timestamp?) {
        guard let startDate = startDate, let endDate = endDate else { return }
        TimeTrackingManager.shared.fetchFilteredTimeRecord(startDate: startDate, endDate: endDate, completion: { result in
            switch result {
            case .success(let trackedTime):
                self.trackedTime = trackedTime
                self.calculateTotalTime()
                self.calculatePieChartValue()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.setUpPieChart(value: self.percentageTimeValues ?? [], label: self.categories ?? [])
                }
            case .failure(let error):
                print(error)
            }
        })
    }

    func switchSegmentIndex() {
        switch selectedSegmentIndex {
        case 0:
            startDateTS = Timestamp(date: Date().startOfDay)
            endDateTS = Timestamp(date: Date().endOfDay)
        case 1:
            startDateTS = Timestamp(date: Date().startOfWeek)
            endDateTS = Timestamp(date: Date().endOfWeek)
        case 2:
            startDateTS = Timestamp(date: Date().startOfMonth)
            endDateTS = Timestamp(date: Date().endOfMonth)
        default:
            break
        }
    }
    
    func calculateTotalTime() {
        timeRecords = [:]
        guard let trackedTime = trackedTime else { return }
        for num in 0..<trackedTime.count {
            let time = trackedTime[num]
            if let previousRecord = self.timeRecords?[time.taskName] {
                let duration = previousRecord + time.duration
                self.timeRecords?.updateValue(duration, forKey: time.taskName)
            } else {
                self.timeRecords?.updateValue(time.duration, forKey: time.taskName)
            }
        }
    }
    
    func fetchUser() {
        JournalManager.shared.fetchUser(completion: { result in
            switch result {
            case .success(let user):
                self.trackedTimeCategories = user[0].trackTimeCategories
                self.calculateTotalTime()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WriteJournalViewController {
            let pieChartImage = pieChartView.asImage()
            destination.journalImage = pieChartImage
            destination.isWritingSummary = true
        }
    }
}

extension TimeTrackingSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingSummaryTableViewCell.identifier, for: indexPath)
        guard let summaryCell = cell as? TimeTrackingSummaryTableViewCell else { return cell }
        summaryCell.layoutCell(activity: categories?[indexPath.row] ?? "",
                               time: timeValues?[indexPath.row].getFormattedTime() ?? "")
        return summaryCell
    }
}
