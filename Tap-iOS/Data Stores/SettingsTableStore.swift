//
//  SettingsTableStore.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/9/24.
//

import Foundation
import UIKit


class TableSection {
    var index: Int
    var title: String
    var rows: [TableRow]
    
    init() {
        index = -1
        title = ""
        rows = []
    }
}

class TableRow {
    var index: Int
    var title: String
    var type: String
    var VCID: String?
    var prefKey: String?
    
    init() {
        index = -1
        title = ""
        type = ""
        VCID = ""
        prefKey = ""
    }
}

class SettingsTableStore: NSObject, UITableViewDataSource {
    
    private var numSections: Int = 0
    
    private var sections = [TableSection]()
    
    
    func getRow(at indexPath: IndexPath) -> TableRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        if (row.type == "toggle") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleSettingsCell", for: indexPath) as! ToggleSettingsTableCell
            cell.titleLabel.text = row.title
            cell.settingsKey = row.prefKey
            cell.toggle.isOn = UserDefaults.standard.bool(forKey: cell.settingsKey)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSettingsCell", for: indexPath) as! BasicSettingsTableCell
            cell.titleLabel.text = row.title
            cell.actionVCID = row.VCID
            return cell
        }
    }
    
    
    /// Indexes a property list for the settings view controller
    /// - Parameter fname: filename of the property list
    func indexPlist(from fname: String) {
        guard let path = Bundle.main.path(forResource: fname, ofType: "plist") else {
            fatalError("Failed to find settings plist")
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Failed to open settings plist")
        }
        
        do {
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            if let dict = plistData as? [String: Any] {
                if let sections = dict["sections"] as? [String: Any] {
                    self.sections = parseSections(sections).sorted(by: { lhs, rhs in
                        return lhs.index < rhs.index
                    })
                    self.numSections = self.sections.count
                }
            }
        } catch {
            print("Error reading Plist: \(error)")
        }
    }
    
    /// Parses the sections of a property list,
    /// *Section refers to a section in a table view*
    /// - Parameter sections: sections dictionary to be parsed
    /// - Returns: Array of TableSection
    private func parseSections(_ sections: [String:Any]) -> [TableSection] {
        print(#function)
        var ret = [TableSection]()
        for sect in sections {
            if let dict = sect.value as? [String: Any] {
                let section = TableSection()
                section.index = try! Int(sect.key, format: .number, lenient: true)
                section.title = dict["title"] as! String
                section.rows = parseRows(dict["rows"] as! [String: Any]).sorted(by: { lhs, rhs in
                    return lhs.index < rhs.index
                })
                ret.append(section)
            }
        }
        return ret
    }
    
    /// Parses the rows of a section
    /// - Parameter rows: Rows dictionary to be parsed
    /// - Returns: Array of TableRow
    private func parseRows(_ rows: [String: Any]) -> [TableRow] {
        print(#function)
        var ret = [TableRow]()
        for r in rows {
            if let dict = r.value as? [String: Any] {
                let row = TableRow()
                row.index = try! Int(r.key, format: .number, lenient: true)
                row.title = dict["title"] as! String
                row.type = dict["type"] as! String
                if (row.type == "toggle") {
                    row.VCID = nil
                    row.prefKey = dict["prefKey"] as? String
                } else {
                    row.prefKey = nil
                    row.VCID = dict["VCID"] as? String
                }
                ret.append(row)
                
            }
        }
        return ret
    }
    
}
