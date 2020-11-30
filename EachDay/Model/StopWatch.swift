//
//  StopWatch.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/29.
//

import Foundation
import UIKit

class Stopwatch {
    
    private var startTime: Date?

    var startTime1: TimeInterval?
    
    var pausedTime: Date?
    
    var resumeTime: Date?
    
    var resumeStartTime: Date?
    
    var isTiming = false
    
    var isPaused = false
    
    var pausedIntervals: [TimeInterval] = []
    
    var timer = Timer()
    
    var elapsedTime: TimeInterval {
        if let startTime = self.startTime {
            return -startTime.timeIntervalSinceNow
        } else {
            return 0
        }
    }
    var elapsedTime1: TimeInterval? {
        didSet {
            newElapsedTimeAsString = String(format: "%02d:%02d:%02d",
                                            Int( elapsedTime1! / 3600),
                                            Int((elapsedTime1! / 60).truncatingRemainder(dividingBy: 60)), Int(elapsedTime1!.truncatingRemainder(dividingBy: 60)))
        }
    }
    
    var elapsedTimeAsString: String {
        return String(format: "%02d:%02d:%02d",
                      Int(elapsedTime / 3600),
                      Int((elapsedTime / 60).truncatingRemainder(dividingBy: 60)), Int(elapsedTime.truncatingRemainder(dividingBy: 60)))
    }
    
    var newElapsedTimeAsString: String?
    
    
    var isRunning: Bool {
        return startTime != nil
    }
    
    func start() {
        startTime = Date()
        resumeStartTime = Date()
    }
    func resume() {
        
    }
//    func pause() {
//        pauseTime = elapsedTime
//        startTime = nil
//    }

    func stop() {
        startTime = nil
    }
    
    @objc func updateTimer() {
        let currentTime = Date().timeIntervalSinceReferenceDate
        var pausedSeconds = pausedIntervals.reduce(0) { $0 + $1 }
        if let pausedTime = pausedTime {
            pausedSeconds += Date().timeIntervalSince(pausedTime)
        }
        elapsedTime1 = currentTime - startTime1! - pausedSeconds
    }
    
//    func updateText(text: String) {
//        label.text = String(format: "%02d:%02d:%02d",
//                            Int( elapsedTime1! / 3600),
//                            Int((elapsedTime1! / 60).truncatingRemainder(dividingBy: 60)), Int(elapsedTime1!.truncatingRemainder(dividingBy: 60)))
//    }
    
    func begin() {
        if !timer.isValid {
            startTime = Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            startTime1 = Date().timeIntervalSinceReferenceDate
        }
        isTiming = true
        isPaused = false
        pausedIntervals = []
        updateTimer()
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
        updateTimer()
    }
    //pause should record the moment we stop, which can be used in resume to know when we stopped
    //stop stop entirely, record the moment we click stop button
    //resume resume from the moment we stop the timer, need to take into acount of the time before we click pause button
    
}
