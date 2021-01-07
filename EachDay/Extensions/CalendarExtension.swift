//
//  Calendar.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/15.
//

import Foundation

extension Calendar {
    
    static let gregorian = Calendar(identifier: .gregorian)

    var gregorianUTC: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }
}
