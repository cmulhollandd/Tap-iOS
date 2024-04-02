//
//  UserProfileViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/31/24.
//

import Foundation
import UIKit


enum UserAction {
    case follow
    case unfollow
    case showSettings
}


class UserProfileViewController: UIViewController {
    @IBOutlet var postsCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var firstNameLastNameLabel: UILabel!
    @IBOutlet var profilePhotoImageView: UIImageView!
    @IBOutlet var postsTable: UITableView!
    @IBOutlet var userActionButton: UIButton!
    
    
    var user: TapUser?
    var userAction: UserAction!
    var posts = [TapFeedPost]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            firstNameLastNameLabel.text = "\(user.firstName) \(user.lastName)"
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
    }
    
    
    @IBAction func userActionButtonPressed(_ sender: UIButton) {
        switch userAction {
        case .follow:
            userActionButton.setTitle("Unfollow", for: .normal)
            userAction = .unfollow
        case .unfollow:
            userActionButton.setTitle("Follow", for: .normal)
            userAction = .follow
        case .showSettings:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainSettingsViewController")
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("Nothing to do")
        }
    }
    
    func reloadPosts() {
        // Call to API to download posts
        self.postsTable.reloadData()
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
