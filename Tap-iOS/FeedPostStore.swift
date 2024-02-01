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
    var user: TapUser!
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }()
    
    override init() {
        super.init()
        
        let post1 = TapFeedPost(postingUserUsername: "cmulholland14", postingUserProfileImage: nil, hasImage: false, textContent: "Filled their bucket for the day!", imageContent: nil, postDate: Date(timeInterval: 45, since: Date()))
        
        let post2 = TapFeedPost(postingUserUsername: "kcarson45", postingUserProfileImage: nil, hasImage: false, textContent: "Look at all that water!", imageContent: nil, postDate: Date(timeInterval: 120, since: Date()))
        
        let post3 = TapFeedPost(postingUserUsername: "dorgil21", postingUserProfileImage: nil, hasImage: false, textContent: "I could really go for a nice water right now", imageContent: nil, postDate: Date(timeInterval: 500, since: Date()))
        
        let post4 = TapFeedPost(postingUserUsername: "jbeuerlein38", postingUserProfileImage: nil, hasImage: false, textContent: "Have you guys tried sparkling water?", imageContent: nil, postDate: Date(timeInterval: 1200, since: Date()))
        
        self.posts = [post1, post2, post3, post4]
    }

    /// Updates posts stored in this FeedPostStore
    func refreshData() {
        // Interact with API
    }
}


extension FeedPostStore: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Creating post for index \(indexPath.row)")
        let post = posts[indexPath.row]
        
        let hours = post.postDate.timeIntervalSinceNow / 3600
        let minutes = post.postDate.timeIntervalSinceNow / 60
        let seconds = post.postDate.timeIntervalSinceNow
        
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
            cell.contentImageView.image = UIImage(cgImage: post.imageContent!)
            cell.usernameLabel.text = post.postingUserUsername
            cell.timeSincePostLabel.text = timeString
            cell.contentLabel.text = post.textContent
            guard let image = post.postingUserProfileImage else {
                return cell
            }
            cell.profileImageView.image = UIImage(cgImage: image)
            return cell
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NonImageCell", for: indexPath) as! FeedTableViewCell
            cell.usernameLabel.text = post.postingUserUsername
            cell.timeSincePostLabel.text = timeString
            cell.contentLabel.text = post.textContent
            guard let image = post.postingUserProfileImage else {
                return cell
            }
            cell.profileImageView.image = UIImage(cgImage: image)
            return cell
        }
    
    }
}
