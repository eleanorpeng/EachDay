//
//  DateExtension.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/3.
//

import Foundation

extension Date {
    func year() ->Int {
            let calendar = NSCalendar.current
            let com = calendar.dateComponents([.year,.month,.day], from: self)
            return com.year!
        }
  
        func month() ->Int {
            let calendar = NSCalendar.current
            let com = calendar.dateComponents([.year,.month,.day], from: self)
            return com.month!
        }

        func day() ->Int {
            let calendar = NSCalendar.current
            let com = calendar.dateComponents([.year,.month,.day], from: self)
            return com.day!
        }
     
        func weekDay()->Int{
            let interval = Int(self.timeIntervalSince1970)
            let days = Int(interval/86400) // 24*60*60
            let weekday = ((days + 4)%7+7)%7
            return weekday == 0 ? 7 : weekday
        }
    
        func countOfDaysInMonth() ->Int {
            let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
            let range = (calendar as NSCalendar?)?.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
            return (range?.length)!

        }
      
        func firstWeekDay() ->Int {
            //1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
            let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
            let firstWeekDay = (calendar as NSCalendar?)?.ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfMonth, for: self)
            return firstWeekDay! - 1
            
        }
       
        func isToday()->Bool {
            let calendar = NSCalendar.current
            let com = calendar.dateComponents([.year,.month,.day], from: self)
            let comNow = calendar.dateComponents([.year,.month,.day], from: Date())
            return com.year == comNow.year && com.month == comNow.month && com.day == comNow.day
        }
        
        func isThisMonth()->Bool {
            let calendar = NSCalendar.current
            let com = calendar.dateComponents([.year,.month,.day], from: self)
            let comNow = calendar.dateComponents([.year,.month,.day], from: Date())
            return com.year == comNow.year && com.month == comNow.month
        }
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
    
    func getFormattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
}
