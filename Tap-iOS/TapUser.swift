//
//  TapUser.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation

class TapUser {
    
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var authToken: String
    
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.username = ""
        self.email = ""
        self.authToken = ""
    }
    
    init(first: String, last: String, username: String, email: String, loginToken: String) {
        self.firstName = first
        self.lastName = last
        self.username = username
        self.email = email
        self.authToken = loginToken
    }
}
