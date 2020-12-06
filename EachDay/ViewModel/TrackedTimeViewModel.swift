//
//  TrackedTime.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import Foundation

class TrackedTimeViewModel {
    let trackedTime: TrackedTime
    init(trackedTime: TrackedTime) {
        self.trackedTime = trackedTime
    }
    
    var id: String {
        return trackedTime.id
    }
    
    var startTime: String {
        let time = trackedTime.startTime.dateValue()
        return time.getFormattedTime()
    }


    var endTime: String {
        let time = trackedTime.endTime.dateValue()
        return time.getFormattedTime()
    }

    var taskName: String {
        return trackedTime.taskName
    }
    
    var duration: String {
        let elapsedTimeInterval = trackedTime.duration
        return String(format: "%02d:%02d:%02d",
                             Int( elapsedTimeInterval / 3600),
                             Int((elapsedTimeInterval / 60).truncatingRemainder(dividingBy: 60)), Int(elapsedTimeInterval.truncatingRemainder(dividingBy: 60)))
    }
    
    var taskDescription: String {
        return trackedTime.taskDescrpition
    }
    
}
