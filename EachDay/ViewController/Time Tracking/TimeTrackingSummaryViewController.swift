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
import Lottie

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
    @IBOutlet weak var animationView: AnimationView!
    let helper = Helper()
    var selectedSegmentIndex = 0
    var timeRecords: [String:TimeInterval]?
    var trackedTime: [TrackedTime]?
    var trackedTimeCategories: [String]?
    var percentageTimeValues: [Double]?
    var startDateTS: Timestamp?
    var endDateTS: Timestamp?
    
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
    
    func configurePieChart() {
        guard let timeRecord = self.timeRecords else { return }
        categories = Array(timeRecord.keys)
        timeValues = Array(timeRecord.values)
        computePieChartValue(time: timeValues)
        tableView.reloadData()
    }
    
    func computePieChartValue(time: [Double]?) {
        guard let sum = time?.reduce(0, +) else { return }
        percentageTimeValues = time?.map({
            return (($0 / sum) * 100).rounded(toPlaces: 1)
        })
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
                self.configurePieChart()
                DispatchQueue.main.async {
                    self.configureEmptyView()
                    self.tableView.reloadData()
                    self.setUpPieChart(value: self.percentageTimeValues ?? [], label: self.categories ?? [])
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func configureEmptyView() {
        if let trackedTime = trackedTime {
            if trackedTime.isEmpty {
                pieChartView.isHidden = true
                animationView.isHidden = false
                animationView.loopMode = .loop
                animationView.animationSpeed = 1
                animationView.contentMode = .scaleAspectFit
                animationView.play()
            } else {
                pieChartView.isHidden = false
                animationView.isHidden = true
            }
        }
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
        if let categories = categories {
            if categories.isEmpty {
                tableView.backgroundView = configureEmptyTableViewBackground()
            } else {
                tableView.backgroundView = nil
            }
        }
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingSummaryTableViewCell.identifier, for: indexPath)
        guard let summaryCell = cell as? TimeTrackingSummaryTableViewCell else { return cell }
        summaryCell.layoutCell(activity: categories?[indexPath.row] ?? "",
                               time: timeValues?[indexPath.row].getFormattedTime() ?? "")
        return summaryCell
    }
    
    func configureEmptyTableViewBackground() -> UIView {
        let customView = UIView()
        view.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        let customLabel = UILabel()
        customLabel.customLabel(text: "Seems like you haven't tracked any time yet!",
                                font:  UIFont.boldSystemFont(ofSize: 16))
        customLabel.textAlignment = .center
        customView.addSubview(customLabel)
        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customView.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20),
            customLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            customLabel.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            customLabel.topAnchor.constraint(equalTo: customView.topAnchor, constant: 16),
            customLabel.heightAnchor.constraint(equalToConstant: 50),
            customLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
        return customView
    }

}
