//
//  DoubleExtension.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/3.
//

import Foundation

extension Double {
    func convertTime() -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
    
    func getFormattedTime() -> String {
        return String(format: "%02d:%02d:%02d",
                             Int( self / 3600),
                             Int((self / 60).truncatingRemainder(dividingBy: 60)), Int(self.truncatingRemainder(dividingBy: 60)))
    }
}
