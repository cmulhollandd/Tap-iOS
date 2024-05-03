//
//  LeaderboardViewController.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/18/24.
//

import Foundation
import UIKit

class LeaderboardViewController: UIViewController {
    
    var dataSource: LeaderboardStore!
    private var refreshControl = UIRefreshControl()

    @IBOutlet var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = LeaderboardStore()
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dataSource.reloadLeaderboard { error, message in
            if (error) {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { alert in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
            self.tableView.reloadData()
        }
    }
    
    /// Refreshes the posts in the table view
    @objc func refreshData() {
        
        dataSource.reloadLeaderboard { error, message in
            if (error) {
                // Alert User of error
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                self.refreshControl.endRefreshing()
                return
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension LeaderboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let username = dataSource.getUsername(for: indexPath)
        
        // Call API to get details of the user
        let user = TapUser(first: username, last: username, username: username, email: username, loginToken: nil, profilePhoto: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
