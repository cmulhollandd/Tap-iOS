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
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newPostButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = FeedPostStore()
        self.dataSource.presentingVC = self
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .systemBackground
        self.tableView.refreshControl = refreshControl
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    /// Refreshes the posts in the table view
    @objc func refreshData() {
        self.tableView.reloadData()
        
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func newPostButtonPressed(_ sender: UIBarButtonItem) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
        vc.feedStore = self.dataSource
        present(vc, animated: true)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let spinner = SpinnerViewController()
        self.addChild(spinner)
        spinner.view.frame = self.view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        
        let post = dataSource.getPost(for: indexPath)
        let username = post.postingUserUsername
        
        // Call API to get details of the user
        let user = TapUser(first: username, last: username, username: username, email: username, loginToken: nil, profilePhoto: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
        vc.user = user
        vc.post = post
        
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
