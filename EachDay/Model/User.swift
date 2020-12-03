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
    let trackedTime: [TrackedTime]
    let journal: [Journal]
    
    init(name: String, id: String, email: String, passcode: String, journalTags: [String], trackTimeCategories: [String], trackedTime: [TrackedTime], journal: [Journal]) {
        self.name = name
        self.id = id
        self.email = email
        self.passcode = passcode
        self.journalTags = journalTags
        self.trackTimeCategories = trackTimeCategories
        self.trackedTime = trackedTime
        self.journal = journal
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id, email, passcode, journal, journalTags, trackTimeCategories, trackedTime
    }
}

struct TrackedTime: Identifiable, Codable {
    let id: String
    let startTime: Double
    let endTime: Double
    let category: String
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
    let id: String
    let title: String
    let date: Double
    let content: String
    let tags: [String]
    let image: String
    let hasTracker: Bool
    let isTimeCapsule: Bool
    
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


