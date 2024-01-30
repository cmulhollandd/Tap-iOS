//
//  TapFeedViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/29/24.
//

import Foundation
import UIKit

class FeedViewController: UITableViewController {
    
    var dataSource: FeedPostStore!
    
    override func loadView() {
        super.loadView()
        
        self.dataSource = FeedPostStore()
        self.tableView.dataSource = self.dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }
    
}
