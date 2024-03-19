//
//  ToggleSettingTableCell.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/9/24.
//

import Foundation
import UIKit

class ToggleSettingsTableCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    var settingsKey: String!
    
    @IBAction func toggleSwitched(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: settingsKey)
    }
    
    
}
