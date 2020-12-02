//
//  TimeTrackingSummaryViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/1.
//

import UIKit
import Charts

class TimeTrackingSummaryViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var writeReflectionButton: UIButton!
    @IBAction func writeReflectionButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowWriteReflectionSegue", sender: self)
    }
    let helper = Helper()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        createBackButton()
    }
    
    func initialSetUp() {
        tableView.delegate = self
        tableView.dataSource = self
        pieChartView.delegate = self
        let data = ["Reading", "Eating", "Sleeping", "Studying"]
        let values: [Double] = [23, 51, 19, 7]
        setUpPieChart(value: values, label: data)
        pieChartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        pieChartView.entryLabelColor = .black
        writeReflectionButton.layer.cornerRadius = 10
        writeReflectionButton.clipsToBounds = true
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
}

extension TimeTrackingSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeTrackingSummaryTableViewCell.identifier, for: indexPath)
        guard let summaryCell = cell as? TimeTrackingSummaryTableViewCell else { return cell }
        summaryCell.layoutCell(activity: "Reading", time: "01:23:35")
        return summaryCell
    }
}
