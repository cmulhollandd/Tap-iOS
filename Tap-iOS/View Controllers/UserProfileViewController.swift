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

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = user {
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
        }

        self.postsTable.register(FeedTableViewCell.self, forCellReuseIdentifier: "NonImageCell")
        self.postsTable.register(FeedTableViewCellWithImage.self, forCellReuseIdentifier: "ImageCell")
        self.postsTable.dataSource = self

        reloadPosts()
        
        loadFollowersAndFollowing()
    }


    @IBAction func userActionButtonPressed(_ sender: UIButton) {
        switch userAction {
        case .follow:
            followUser()
        case .unfollow:
            unfollowUser()
        case .showSettings:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainSettingsViewController")
            self.navigationController?.pushViewController(vc, animated: true)

        default:
            print("Nothing to do")
        }
    }
    
    /// Reloads teh posts in the postsTable
    func reloadPosts() {
        // Call to API to download posts
        self.postsTable.reloadData()
    }
    
    /// Asks the API for the following and follower lists for this user and updates the interface to show their counts
    func loadFollowersAndFollowing() {
        guard let user = user else {
            return
        }
        SocialAPI.getFollowers(of: user) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                // present error to user
                self.followersButton.titleLabel?.text = "?"
                return
            }
            let numFollowers = resp.count
            print(numFollowers, #line)
            self.followersButton.titleLabel?.text = "\(numFollowers)"
        }
        SocialAPI.getFollowing(of: user) { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                // present error to user
                self.followingButton.titleLabel?.text = "?"
                return
            }
            let numFollowing = resp.count
            print(numFollowing, #line)
            self.followingButton.titleLabel?.text = "\(numFollowing)"
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
            self.navigationController?.pushViewController(vc, animated: true)
            
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
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}


// Since we are hopefully not doing too much work here, we can be our own data source
extension UserProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "NonImageCell", for: indexPath)
    }
}
