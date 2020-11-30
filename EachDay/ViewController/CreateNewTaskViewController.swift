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
    var taskName: String?
    var taskDescription: String?
    weak var delegate: CreateNewTaskViewControllerDelegate?
    @IBOutlet weak var addTagButton: UIButton!
    @IBAction func addTagButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "ShowTimeTrackingTagSegue", sender: self)
    }
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var taskDetailTextView: UITextView!
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.delegate?.startTiming()
        self.delegate?.getRecord(task: taskName ?? "", description: taskDescription ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        startTiming()
        initialSetUp()
    }
    
    func initialSetUp() {
        taskDetailTextView.delegate = self
        setUpTextView()
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
//
//    func startTiming() {
//        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateElapsedTimeLabel(timer:)), userInfo: nil, repeats: true)
//        stopWatch.start()
//    }
    
    func setUpTextView() {
        taskDetailTextView.text = "Add task details"
        taskDetailTextView.textColor = .lightGray
    }
    
//    @objc func updateElapsedTimeLabel(timer: Timer) {
//        if stopWatch.isRunning {
//            elapsedTimeLabel.text = stopWatch.elapsedTimeAsString
//        } else {
//            timer.invalidate()
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TimeTrackingTagViewController {
            destination.delegate = self
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
        taskDescription = taskDetailTextView.text
        self.delegate?.getDescription(description: taskDetailTextView.text)
        if taskDetailTextView.text.isEmpty {
            setUpTextView()
        }
    }
}

extension CreateNewTaskViewController: TimeTrackingTagViewControllerDelegate {
    func getSelectedTag(tag: String) {
        taskName = tag
        self.delegate?.getCategory(category: taskName ?? "")
        addTagButton.setTitle(taskName, for: .normal)
        addTagButton.setTitleColor(.black, for: .normal)
        tagImageView.tintColor = .black
    }
}

protocol CreateNewTaskViewControllerDelegate: AnyObject {
    func startTiming()
    func getTaskName(task: String)
    func getDescription(description: String)
    func getCategory(category: String)
    func getRecord(task: String, description: String)
}
