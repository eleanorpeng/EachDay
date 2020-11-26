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
    
    var date: Double {
        return journal.date
    }
    
    var content: String {
        return journal.content
    }
    
    var theme: String {
        return journal.theme
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
}
