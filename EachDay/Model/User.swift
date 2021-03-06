//
//  User.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import Foundation
import Firebase

struct User: Identifiable, Codable {
    var name: String
    var id: String
    var email: String
    var passcode: String
    var journalTags: [String]
    var trackTimeCategories: [String]
    var image: String
    var calendarColors: [String]
    var routineTime: Timestamp?
//    let trackedTime: [TrackedTime]
//    let journal: [Journal]
    
    init(name: String, id: String, email: String, passcode: String, journalTags: [String], trackTimeCategories: [String], image: String, colors: [String], routineTime: Timestamp?) {
        self.name = name
        self.id = id
        self.email = email
        self.passcode = passcode
        self.journalTags = journalTags
        self.trackTimeCategories = trackTimeCategories
        self.image = image
        self.calendarColors = colors
        self.routineTime = routineTime
//        self.trackedTime = trackedTime
//        self.journal = journal
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id, email, passcode, journalTags, trackTimeCategories, image,  calendarColors, routineTime
    }
}

//Added a new date field, changed startTime and endTime from Double to Timestamp, added duration

struct TrackedTime: Identifiable, Codable {
    var id: String
    var date: Timestamp
    var startTime: Timestamp
    var endTime: Timestamp
    var taskName: String
    var duration: Double
    var taskDescrpition: String
    var pauseIntervals: [TimeInterval]?
    var pauseTime: Date?
    
    init(date: Timestamp, startTime: Timestamp, endTime: Timestamp, taskName: String, id: String, duration: Double, taskDescrpition: String, pauseIntervals: [TimeInterval]?, pauseTime: Date?) {
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.taskName = taskName
        self.id = id
        self.duration = duration
        self.taskDescrpition = taskDescrpition
        self.pauseIntervals = pauseIntervals
        self.pauseTime = pauseTime
    }
    
    enum CodingKeys: String, CodingKey {
        case startTime, endTime, taskName, id, date, duration, taskDescrpition, pauseIntervals, pauseTime
    }
}

struct Journal: Identifiable, Codable {
    var id: String
    var title: String
//    var date: Double
    var date: Timestamp
    var content: String
    var tags: [String]
    var image: String
    var hasTracker: Bool
    var isTimeCapsule: Bool
    
    init(title: String, date: Timestamp, content: String, tags: [String], image: String, hasTracker: Bool, isTimeCapsule: Bool, id: String) {
        self.title = title
        self.date = date
        self.content = content
        self.tags = tags
        self.image = image
        self.hasTracker = hasTracker
        self.isTimeCapsule = isTimeCapsule
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case title, date, content, tags, image, hasTracker, isTimeCapsule, id
    }
}
