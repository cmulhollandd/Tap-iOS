//
//  TapSettingsViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/19/24.
//

import Foundation
import UIKit

class TapSettingsViewController: UITableViewController {
    
    let store = SettingsTableStore()
    
    var settingsPlist: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = store
        self.tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = store.getRow(at: indexPath)
        if (row.type == "toggle") {
            self.tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: row.VCID!)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
