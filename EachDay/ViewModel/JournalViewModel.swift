//
//  JournalViewModel.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import Foundation

class JournalViewModel {
    let journal: Journal
    
    init(journal: Journal) {
        self.journal = journal
    }
    
    var id: String {
        return journal.id
    }
    
    var title: String {
        return journal.title
    }
    
    var date: Int {
        let date1 = Date(timeIntervalSince1970: journal.date)
        return date1.month()
//        return journal.date
    }
    
    var content: String {
        return journal.content
    }
    
    var tags: [String] {
        return journal.tags
    }
    
    var image: String {
        return journal.image
    }
    
    var hasTracker: Bool {
        return journal.hasTracker
    }
    
    var isTimeCapsule: Bool {
        return journal.isTimeCapsule
    }
    
    var day: String {
        let date1 = Date(timeIntervalSince1970: journal.date)
        switch date1.day() {
        case 1:
            return "Mon"
        case 2:
            return "Tue"
        case 3:
            return "Wed"
        case 4:
            return "Thu"
        case 5:
            return "Fri"
        case 6:
            return "Sat"
        case 7:
            return "Sun"
        default:
            return "None"
        }
    }
}
