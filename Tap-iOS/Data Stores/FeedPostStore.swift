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
    var presentingVC: UIViewController!
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }()
    
    private var df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:MM aa"
        return df
    }()
    
    override init() {
        super.init()
        
        self.posts = []
        refreshData()
    }

    /// Updates posts stored in this FeedPostStore
    func refreshData() {
        var newPosts = [TapFeedPost]()
        SocialAPI.getNewPosts { posts in
            if posts.count != 0, let _ = posts[0]["error"] as? Bool {
                // Error occurred
                print(posts[0]["message"] as! String)
                return
            }
            
            for postDict in posts {
                guard
                    let postId = postDict["postId"] as? Int,
                    let author = postDict["poster"] as? String,
                    let message = postDict["message"] as? String,
                    let dateString = postDict["date"] as? String
                else {
                    print("failed to parse \(postDict) in \(#function)")
                    continue
                }
                if let timeString = postDict["time"] as? String {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd hh:mm aa"
                    guard let date = df.date(from: "\(dateString) \(timeString)") else {
                        print("Failed to get date from string: \(dateString) \(timeString) in \(#function)")
                        continue
                    }
                    let post = TapFeedPost(postId: postId, postingUserUsername: author, textContent: message, postDate: date)
                    newPosts.append(post)
                } else {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    guard let date = df.date(from: "\(dateString)") else {
                        print("Failed to get date from string: \(dateString) in \(#function)")
                        continue
                    }
                    let post = TapFeedPost(postId: postId, postingUserUsername: author, textContent: message, postDate: date)
                    newPosts.append(post)
                }
            }
            
            self.posts = newPosts.sorted(by: { lhs, rhs in
                return lhs.postDate.distance(to: rhs.postDate) < 0
            })
        }
        
    }
    
    /// Gets the username at indexPath
    /// - Parameter indexPath: indexPath into the array posts
    /// - Returns: username of the user who made the post specified by indexPath
    func getUsername(for indexPath: IndexPath) -> String {
        return posts[indexPath.row].postingUserUsername
    }
    
    /// Gets the post at indexPath
    /// - Parameter indexPath: indexPath into the array posts
    /// - Returns: post at index path
    func getPost(for indexPath: IndexPath) -> TapFeedPost {
        return posts[indexPath.row]
    }
    
    /// Adds a new post to this FeedPostStore, subsequently calling SocialAPI.newPost(...)
    /// **NOTE**: The post is not added to this local version of the store if the API fails to except the new post for any reason
    /// - Parameter post: TapFeedPost to be added
    func newPost(_ post: TapFeedPost) {
        // Make API call
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        SocialAPI.newPost(post, user: user) { resp in
            if let _ = resp["error"] as? Bool {
                // error occurred
                return
            }
            guard let id = resp["postId"] as? Int else {
                return
            }
            post.postId = id
            self.posts.append(post)
            self.posts = self.posts.sorted(by: { lhs, rhs in
                return lhs.postDate.distance(to: rhs.postDate) < 0
            })
        }
    }
    
    func deletePost(_ post: TapFeedPost, completion: @escaping(Bool, String?) -> Void) {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        SocialAPI.deletePost(post, requester: user.username) { resp in
            if let _ = resp["error"] as? Bool {
                completion(true, resp["message"] as? String)
                return
            }
            self.posts.removeAll { _post in
                _post.postId == post.postId
            }
            completion(false, nil)
        }
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
            cell.post = post
            cell.presentingVC = self.presentingVC
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
            cell.post = post
            cell.presentingVC = self.presentingVC
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
