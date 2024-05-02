//
//  UserProfileViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/2/24.
//

import Foundation
import UIKit

enum UserAction {
    case follow
    case unfollow
    case showSettings
}


class UserProfileViewController: UIViewController {
    @IBOutlet var postsButton: UIButton!
    @IBOutlet var followersButton: UIButton!
    @IBOutlet var followingButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profilePhotoImageView: UIImageView!
    @IBOutlet var postsTable: UITableView!
    @IBOutlet var userActionButton: UIButton!


    var user: TapUser?
    var userAction: UserAction!
    var posts = [TapFeedPost]()
    
    let df: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm aa"
        return df
    }()
    
    let nf: NumberFormatter = {
        var nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = user else {
            return
        }
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.title = user.username
        
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        followersButton.titleLabel?.text = "\(user.followers.count)"
        followingButton.titleLabel?.text = "\(user.following.count)"
        postsButton.titleLabel?.text = "\(posts.count)"
        
        let localUser = (UIApplication.shared.delegate as! AppDelegate).user!
        if (localUser.username == user.username) {
            userActionButton.setTitle("Settings", for: .normal)
            userAction = .showSettings
        } else {
            userActionButton.setTitle("Follow", for: .normal)
            userAction = .follow
        }
        self.postsTable.dataSource = self
        self.postsTable.delegate = self
        
        loadFollowersAndFollowing()
        reloadPosts()
    }

    @IBAction func userActionButtonPressed(_ sender: UIButton) {
        switch userAction {
        case .follow:
            followUser()
        case .unfollow:
            unfollowUser()
        case .showSettings:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainSettingsViewController")
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true)
            }

        default:
            print("Nothing to do")
        }
    }
    
    @IBAction func userFountainsButtonPressed(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserFountainsViewController") as! UserFountainsViewController
        vc.user = self.user
        self.present(vc, animated: true)
    }
    
    /// Reloads teh posts in the postsTable
    func reloadPosts() {
        // Call to API to download posts
        guard let user = user else {
            return
        }
        SocialAPI.getPostsBy(user: user.username) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                // error occurred
                print(resp[0]["message"] as! String)
                return
            }
            for postDict in resp {
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
                    self.posts.append(post)
                } else {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    guard let date = df.date(from: "\(dateString)") else {
                        print("Failed to get date from string: \(dateString) in \(#function)")
                        continue
                    }
                    let post = TapFeedPost(postId: postId, postingUserUsername: author, textContent: message, postDate: date)
                    self.posts.append(post)
                }
            }
//            self.postsButton.titleLabel?.text = "\(self.posts.count)"
            self.postsButton.setTitle("\(self.posts.count)", for: .normal)
            self.posts.sort { lhs, rhs in
                return lhs.postDate.timeIntervalSince(rhs.postDate) > 0
            }
            self.postsTable.reloadData()
        }
        
        
    }
    
    /// Asks the API for the following and follower lists for this user and updates the interface to show their counts
    func loadFollowersAndFollowing() {
        guard let user = user else {
            return
        }
        SocialAPI.getFollowers(of: user) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                // present error to user
                self.followersButton.titleLabel?.text = "??"
                return
            }
            let numFollowers = resp.count
            print(numFollowers, #line)
//            self.followersButton.titleLabel?.text = "\(numFollowers)"
            self.followersButton.setTitle("\(numFollowers)", for: .normal)
        }
        SocialAPI.getFollowing(of: user) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                // present error to user
                self.followingButton.titleLabel?.text = "??"
                return
            }
            let numFollowing = resp.count
            print(numFollowing, #line)
//            self.followingButton.titleLabel?.text = "\(numFollowing)"
            self.followingButton.setTitle("\(numFollowing)", for: .normal)
        }
    }
    
    /// Sends a request to the API to follow this new user
    private func followUser() {
        let selfUser = (UIApplication.shared.delegate as! AppDelegate).user!
        if let user = user {
            SocialAPI.followUser(followee: user.username, follower: selfUser.username) { resp in
                if let _ = resp["error"] as? Bool {
                    let alert = UIAlertController(title: "Unable to follow \(user.username)", message: "Please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                } else {
                    self.userActionButton.setTitle("Unfollow", for: .normal)
                    self.userAction = .unfollow
                }
            }
        }
    }
    
    /// Sends a request to the API to unfollow this user
    private func unfollowUser() {
        let selfUser = (UIApplication.shared.delegate as! AppDelegate).user!
        if let user = user {
            SocialAPI.unFollowUser(followee: user.username, follower: selfUser.username) { resp in
                if let _ = resp["error"] as? Bool {
                    let alert = UIAlertController(title: "Unable to unfollow \(user.username)", message: "Please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                } else {
                    self.userActionButton.setTitle("Follow", for: .normal)
                    self.userAction = .follow
                }
            }
        }
    }
    
    @IBAction func followersButtonPressed(_ sender: UIButton) {
        guard let user = user else {
            return
        }
        SocialAPI.getFollowers(of: user) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                return
            }
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TapListViewController") as! TapListViewController
            vc.navigationItem.title = "Followers"
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func followingButtonPressed(_ sender: UIButton) {
        guard let user = user else {
            return
        }
        SocialAPI.getFollowing(of: user) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                return
            }
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TapListViewController") as! TapListViewController
            vc.navigationItem.title = "Following"
            if let nav = self.navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true)
            }
        }
    }
}


// Since we are hopefully not doing too much work here, we can be our own data source
extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let intv = Date().timeIntervalSince(post.postDate)
        let hours = intv / 3600
        let minutes = intv / 60
        
        var timeString = ""
        if hours >= 1 {
            timeString = "\(nf.string(from: hours as NSNumber) ?? "na") hours ago"
        } else if minutes >= 1{
            timeString = "\(nf.string(from: minutes as NSNumber) ?? "na") minutes ago"
        } else {
            timeString = "Just Now"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NonImageCell", for: indexPath) as! FeedTableViewCell
        
        cell.post = post
        cell.presentingVC = self
        cell.usernameLabel.text = post.postingUserUsername
        cell.timeSincePostLabel.text = timeString
        cell.contentLabel.text = post.textContent
        guard let image = post.postingUserProfileImage else {
            return cell
        }
        cell.profileImageView.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let username = post.postingUserUsername
        
        // Call API to get details of the user
        let user = TapUser(first: username, last: username, username: username, email: username, loginToken: nil, profilePhoto: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
        vc.user = user
        vc.post = post
        
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true)
        }
    }
}
