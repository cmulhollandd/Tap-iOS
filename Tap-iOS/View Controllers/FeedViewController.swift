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
