//
//  Notifications.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/12/11.
//

import Foundation

class Notifications {
    static let receiveProfileImageNotification = NSNotification.Name(rawValue: "ReceivedProfileImage")
    static let modifiedTagsNotification = NSNotification.Name(rawValue: "ModifiedTags")
    static let receiveTimeCapsule = NSNotification.Name(rawValue: "ReceivedTimeCapsule")
    static let dismissTimeCapsule = NSNotification.Name(rawValue: "DismissedTimeCapsule")
}
