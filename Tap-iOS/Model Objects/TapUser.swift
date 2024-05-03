//
//  TapUser.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import UIKit

enum TapUserError: Error {
    case JSONError(String)
}

class TapUser {
    
    var firstName: String
    var lastName: String
    var username: String
    var email: String
    var authToken: String?
    var profilePhoto: UIImage?
    var followers: [String]
    var following: [String]
    
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.username = ""
        self.email = ""
        self.authToken = ""
        self.followers = [String]()
        self.following = [String]()
    }
    
    init(first: String, last: String, username: String, email: String, loginToken: String?, profilePhoto: UIImage?) {
        self.firstName = first
        self.lastName = last
        self.username = username.lowercased()
        self.email = email
        self.authToken = loginToken
        self.profilePhoto = profilePhoto
        self.followers = [String]()
        self.following = [String]()
    }
    
    
    convenience init(from dict: [String:Any]) throws {
        guard let userDict = dict["user"] as? [String:Any] else {
            self.init(first: "", last: "", username: "", email: "", loginToken: "", profilePhoto: nil)
            print(dict)
            throw TapUserError.JSONError("Invalid JSON contents")
        }
        self.init(first: userDict["firstName"] as? String ?? "",
                  last: userDict["lastName"] as? String ?? "",
                  username: (userDict["username"] as? String)?.lowercased() ?? "",
                  email: userDict["email"] as? String ?? "",
                  loginToken: dict["jwt"] as? String,
                  profilePhoto: nil)
    }
}
