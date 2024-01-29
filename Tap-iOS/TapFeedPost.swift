//
//  TapFeedPost.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import CoreGraphics

class TapFeedPost {
    
    let postingUser: TapUser
    let hasImage: Bool
    let textContent: String
    let imageContent: CGImage?
    let postDate: Date
    
    
    init() {
        self.postingUser = TapUser()
        self.hasImage = false
        self.textContent = ""
        self.imageContent = nil
        self.postDate = Date()
    }
    
    init(postingUser: TapUser, hasImage: Bool, textContent: String, imageContent: CGImage, postDate: Date) {
        self.postingUser = postingUser
        self.hasImage = hasImage
        self.textContent = textContent
        self.imageContent = imageContent
        self.postDate = postDate
    }    
}
