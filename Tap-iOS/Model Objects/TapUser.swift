//
//  TapUser.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import CoreGraphics

enum TapUserError: Error {
    case JSONError(String)
}

class TapUser {
    
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var authToken: String
    var profilePhoto: CGImage?
    
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.username = ""
        self.email = ""
        self.authToken = ""
    }
    
    init(first: String, last: String, username: String, email: String, loginToken: String, profilePhoto: CGImage?) {
        self.firstName = first
        self.lastName = last
        self.username = username
        self.email = email
        self.authToken = loginToken
        self.profilePhoto = profilePhoto
    }
    
    
    convenience init(from dict: [String:Any]) throws {
        guard let userDict = dict["user"] as? [String:Any] else {
            self.init(first: "", last: "", username: "", email: "", loginToken: "", profilePhoto: nil)
            print(dict)
            throw TapUserError.JSONError("Invalid JSON contents")
        }
        self.init(first: userDict["firstName"] as? String ?? "",
                  last: userDict["lastName"] as? String ?? "",
                  username: userDict["username"] as? String ?? "",
                  email: userDict["email"] as? String ?? "",
                  loginToken: dict["jwt"] as? String ?? "",
                  profilePhoto: nil)
    }
}
