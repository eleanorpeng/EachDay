//
//  UserViewModel.swift
//  EachDay
//
//  Created by Eleanor Peng on 2020/11/25.
//

import Foundation

class UserViewModel {
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var name: String {
        return user.name
    }
    
    var id: String {
        return user.id
    }
    
    var email: String {
        return user.email
    }
    
    var passcode: String {
        return user.passcode
    }
    
    var journalTags: [String] {
        return user.journalTags
    }
    
    var trackTimeCategories: [String] {
        return user.trackTimeCategories
    }
    
    var image: String {
        return user.image
    }

}
