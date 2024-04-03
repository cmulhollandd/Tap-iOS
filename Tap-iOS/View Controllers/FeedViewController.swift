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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }
    
    @IBAction func newPostButtonPressed(_ sender: UIBarButtonItem) {
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewPostViewController")
//        self.navigationController!.pushViewController(vc, animated: true)
    }
    
}
