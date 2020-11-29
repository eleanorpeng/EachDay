//
//  CreateNewTaskViewController.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/28.
//

import UIKit

class CreateNewTaskViewController: UIViewController {
    
    enum TimerState {
        case initial
        case isRunning
        case notRunning
    }

    var timerState: TimerState = .initial
    let stopWatch = Stopwatch()
    
    @IBOutlet weak var addTagButton: UIButton!
    @IBAction func addTagButtonClicked(_ sender: Any) {
        
    }
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var taskDetailTextView: UITextView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        startTiming()
        initialSetUp()
    }
    
    func initialSetUp() {
        taskDetailTextView.delegate = self
        setUpTextView()
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    func startTiming() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateElapsedTimeLabel(timer:)), userInfo: nil, repeats: true)
        stopWatch.start()
    }
    
    
    func setUpTextView() {
        taskDetailTextView.text = "Add task details"
        taskDetailTextView.textColor = .lightGray
    }
    
    @objc func updateElapsedTimeLabel(timer: Timer) {
        if stopWatch.isRunning {
            elapsedTimeLabel.text = stopWatch.elapsedTimeAsString
        } else {
            timer.invalidate()
        }
    }
}

extension CreateNewTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskDetailTextView.textColor == UIColor.lightGray {
            taskDetailTextView.text = nil
            taskDetailTextView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if taskDetailTextView.text.isEmpty {
            setUpTextView()
        }
    }
}
