//
//  User.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import Foundation

struct User: Identifiable, Codable {
    let name: String
    let id: String
    let email: String
    let passcode: String
    let journalTags: [String]
    let trackTimeCategories: [String]
//    let trackedTime: [TrackedTime]
//    let journal: [Journal]
    
    init(name: String, id: String, email: String, passcode: String, journalTags: [String], trackTimeCategories: [String]) {
        self.name = name
        self.id = id
        self.email = email
        self.passcode = passcode
        self.journalTags = journalTags
        self.trackTimeCategories = trackTimeCategories
//        self.trackedTime = trackedTime
//        self.journal = journal
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id, email, passcode, journalTags, trackTimeCategories
//        case journal = "Journal"
//        case trackedTime = "TrackedTime"
    }
}

struct TrackedTime: Identifiable, Codable {
    var id: String
    var startTime: Double
    var endTime: Double
    var category: String
    init(startTime: Double, endTime: Double, category: String, id: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.id = id
    }
    
    enum CodingKeys: String, CodingKey {
        case startTime, endTime, category, id
    }
}

struct Journal: Identifiable, Codable {
    var id: String
    var title: String
    var date: Double
    var content: String
    var tags: [String]
    var image: String
    var hasTracker: Bool
    var isTimeCapsule: Bool
    
    init(title: String, date: Double, content: String, tags: [String], image: String, hasTracker: Bool, isTimeCapsule: Bool, id: String) {
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


