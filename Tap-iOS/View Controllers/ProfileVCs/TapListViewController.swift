//
//  TapListViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/17/24.
//

import Foundation
import UIKit

class TapListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    var items = [String]()
    var isShowingUsers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let nav = self.navigationController {
            return nil
        }
        return "Users"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!isShowingUsers) {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as! SingleLabelCell
        let username = cell.label.text!
        
        let user = TapUser(first: "", last: "", username: username, email: "", loginToken: nil, profilePhoto: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true)
        }
    }
}
