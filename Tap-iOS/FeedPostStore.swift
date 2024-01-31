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
    
    override init() {
        super.init()
        
        let post1 = TapFeedPost(postingUserUsername: "cmulholland", postingUserProfileImage: nil, hasImage: false, textContent: "Filled their bucket!", imageContent: nil, postDate: Date())
        
        let post2 = TapFeedPost(postingUserUsername: "kcarson45", postingUserProfileImage: nil, hasImage: false, textContent: "Look at all that water!", imageContent: nil, postDate: Date())
        
        self.posts = [post1, post2]
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
        
        var timeString = ""
        if hours >= 1 {
            timeString = "\(hours.rounded(.down)) hours ago"
        } else {
            timeString = "\(minutes.rounded(.down)) minutes ago"
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
