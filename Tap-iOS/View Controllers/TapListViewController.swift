//
//  TapListViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/17/24.
//

import Foundation
import UIKit

class TapListViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleLabelCell", for: indexPath) as! SingleLabelCell
        cell.label.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (items.count == 0) {
            return "Thats weird, nothing here"
        }
        return ""
    }
}
