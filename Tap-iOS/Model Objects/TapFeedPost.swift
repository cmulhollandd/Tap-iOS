//
//  TapFeedPost.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import UIKit

class TapFeedPost {
    
    let postingUserUsername: String
    let postingUserProfileImage: UIImage?
    let hasImage: Bool
    let textContent: String
    let imageContent: UIImage?
    let postDate: Date
    var comments: [TapComment]
    
    class TapComment {
        let author: String
        let content: String
        
        init(author: String, content: String) {
            self.author = author
            self.content = content
        }
    }
    
    init() {
        self.postingUserUsername = ""
        self.postingUserProfileImage = nil
        self.hasImage = false
        self.textContent = ""
        self.imageContent = nil
        self.postDate = Date()
        self.comments = [TapComment]()
    }
    
    init(postingUserUsername: String, postingUserProfileImage: UIImage?, hasImage: Bool, textContent: String, imageContent: UIImage?, postDate: Date) {
        self.postingUserUsername = postingUserUsername
        self.postingUserProfileImage = postingUserProfileImage
        self.hasImage = hasImage
        self.textContent = textContent
        self.imageContent = imageContent
        self.postDate = postDate
        self.comments = [TapComment]()
    }
}
