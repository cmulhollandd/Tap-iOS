//
//  TapFeedViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import UIKit

class FeedViewController: UIViewController {
    
    var dataSource: FeedPostStore!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newPostButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        
        self.dataSource = FeedPostStore()
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let username = dataSource.getUsername(for: indexPath)
        
        // Call API to get details of the user
        let user = TapUser(first: username, last: username, username: username, email: username, loginToken: nil, profilePhoto: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
