//
//  JournalTag.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/3.
//

import Foundation

struct JournalTag: Identifiable, Codable {
    let id: String
    let tag: String
    let isSelected: Bool
    
    init(id: String, tag: String, isSelected: Bool) {
        self.id = id
        self.tag = tag
        self.isSelected = isSelected
    }
    
    enum CodingKeys: String, CodingKey {
        case id, tag, isSelected
    }
}


