//
//  AccountSettingsViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/19/24.
//

import Foundation
import UIKit

class AccountSettingsViewController: TapSettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsPlist = "AccountSettingsIndex"
        store.indexPlist(from: settingsPlist)
        print(store.numberOfSections(in: self.tableView))
        self.tableView.reloadData()
        self.navigationItem.title = "Account Settings"
    }
}
