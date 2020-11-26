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
    
    var startTime: Double {
        return trackedTime.startTime
    }
    
    var endTime: Double {
        return trackedTime.endTime
    }
    
    var category: String {
        return trackedTime.category
    }
    
    var totalTime: Double {
        return endTime - startTime
    }
}
