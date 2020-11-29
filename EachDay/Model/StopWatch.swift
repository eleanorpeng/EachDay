//
//  StopWatch.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/29.
//

import Foundation

class Stopwatch {
    
    private var startTime: Date?

    var elapsedTime: TimeInterval {
        if let startTime = self.startTime {
            return -startTime.timeIntervalSinceNow
        } else {
            return 0
        }
    }
    
    var elapsedTimeAsString: String {
        return String(format: "%02d:%02d:%02d",
                      Int(elapsedTime / 3600),
                      Int((elapsedTime / 60).truncatingRemainder(dividingBy: 60)), Int(elapsedTime.truncatingRemainder(dividingBy: 60)))
    }
    
    var isRunning: Bool {
        return startTime != nil
    }
    
    func start() {
        startTime = Date()
    }
    
    func stop() {
        startTime = nil
    }
    
}
