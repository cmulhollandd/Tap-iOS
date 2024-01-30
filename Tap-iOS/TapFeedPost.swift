//
//  TapFeedPost.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import CoreGraphics

class TapFeedPost {
    
    let postingUserUsername: String
    let postingUserProfileImage: CGImage?
    let hasImage: Bool
    let textContent: String
    let imageContent: CGImage?
    let postDate: Date
    
    
    init() {
        self.postingUserUsername = ""
        self.postingUserProfileImage = nil
        self.hasImage = false
        self.textContent = ""
        self.imageContent = nil
        self.postDate = Date()
    }
    
    init(postingUserUsername: String, postingUserProfileImage: CGImage?, hasImage: Bool, textContent: String, imageContent: CGImage?, postDate: Date) {
        self.postingUserUsername = postingUserUsername
        self.postingUserProfileImage = postingUserProfileImage
        self.hasImage = hasImage
        self.textContent = textContent
        self.imageContent = imageContent
        self.postDate = postDate
    }    
}
