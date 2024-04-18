//
//  FeedPostStore.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import UIKit

class FeedPostStore: NSObject {
    
    var posts: [TapFeedPost]!
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }()
    
    override init() {
        super.init()
        
        let post1 = TapFeedPost(postingUserUsername: "charlie", postingUserProfileImage: nil, hasImage: false, textContent: "Filled their bucket for the day!", imageContent: nil, postDate: Date(timeInterval: -45, since: Date()))
        
        let post2 = TapFeedPost(postingUserUsername: "kcarson45", postingUserProfileImage: nil, hasImage: false, textContent: "Look at all that water!", imageContent: nil, postDate: Date(timeInterval: -120, since: Date()))
        
        let post3 = TapFeedPost(postingUserUsername: "dorgil21", postingUserProfileImage: nil, hasImage: false, textContent: "I could really go for a nice water right now", imageContent: nil, postDate: Date(timeInterval: -500, since: Date()))
        
        let post4 = TapFeedPost(postingUserUsername: "jbeuerlein38", postingUserProfileImage: nil, hasImage: false, textContent: "Have you guys tried sparkling water?", imageContent: nil, postDate: Date(timeInterval: -1200, since: Date()))
        
        self.posts = [post1, post2, post3, post4]
    }

    /// Updates posts stored in this FeedPostStore
    func refreshData() {
        // Interact with API
    }
    
    /// Gets the username at indexPath
    /// - Parameter indexPath: indexPath into the array posts
    /// - Returns: username of the user who made the post specified by indexPath
    func getUsername(for indexPath: IndexPath) -> String {
        return posts[indexPath.row].postingUserUsername
    }
    
    /// Adds a new post to this FeedPostStore, subsequently calling SocialAPI.newPost(...)
    /// **NOTE**: The post is not added to this local version of the store if the API fails to except the new post for any reason
    /// - Parameter post: TapFeedPost to be added
    func newPost(_ post: TapFeedPost) {
        self.posts.append(post)
        self.posts = posts.sorted { p1, p2 in
            return p1.postDate.distance(to: p2.postDate) < 0
        }
        // Make API call
    }
}


extension FeedPostStore: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let intv = Date().timeIntervalSince(post.postDate)
        let hours = intv / 3600
        let minutes = intv / 60
        let seconds = intv
        
        var timeString = ""
        if hours >= 1 {
            timeString = "\(nf.string(from: hours as NSNumber) ?? "na") hours ago"
        } else if minutes >= 1{
            timeString = "\(nf.string(from: minutes as NSNumber) ?? "na") minutes ago"
        } else {
            timeString = "\(nf.string(from: seconds as NSNumber) ?? "na") seconds ago"
        }
        
        switch post.hasImage {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! FeedTableViewCellWithImage
            cell.contentImageView.image = post.imageContent!
            cell.usernameLabel.text = post.postingUserUsername
            cell.timeSincePostLabel.text = timeString
            cell.contentLabel.text = post.textContent
            guard let image = post.postingUserProfileImage else {
                return cell
            }
            cell.profileImageView.image = image
            return cell
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NonImageCell", for: indexPath) as! FeedTableViewCell
            cell.usernameLabel.text = post.postingUserUsername
            cell.timeSincePostLabel.text = timeString
            cell.contentLabel.text = post.textContent
            guard let image = post.postingUserProfileImage else {
                return cell
            }
            cell.profileImageView.image = image
            return cell
        }
    
    }
}
