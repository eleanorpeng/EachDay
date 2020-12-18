//
//  CalendarView.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/18.
//

import Foundation
import UIKit

class CalendarView {
    let month =  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    let monthText = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    var colors: [String]?
    
    init(colors: [String]) {
        self.colors = colors
    }
}
