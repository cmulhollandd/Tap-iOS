//
//  LeaderboardStore.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/18/24.
//

import Foundation
import UIKit

class LeaderboardStore: NSObject {
    
    var entries: [LeaderboardEntry]!
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }()
    
    override init() {
        super.init()
        
        let entry1 = LeaderboardEntry(entrantPlace: 1, entrantUsername: "charlie", entrantProfileImage: nil, entrantPoints: 1000)
        
        let entry2 = LeaderboardEntry(entrantPlace: 2, entrantUsername: "kcarson45", entrantProfileImage: nil, entrantPoints: 750)
        
        let entry3 = LeaderboardEntry(entrantPlace: 3, entrantUsername: "dorgil21", entrantProfileImage: nil, entrantPoints: 500)
        
        let entry4 = LeaderboardEntry(entrantPlace: 4, entrantUsername: "jbeuerlein38", entrantProfileImage: nil, entrantPoints: 250)
        
        self.entries = [entry1, entry2, entry3, entry4]
    }
    
    func getUsername(for indexPath: IndexPath) -> String {
        return entries[indexPath.row].entrantUsername
    }
}
    
extension LeaderboardStore: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! LeaderboardTableViewCell
        cell.usernameLabel.text = entry.entrantUsername
        cell.placeLabel.text = String (entry.entrantPlace)
        cell.pointsLabel.text = String (entry.entrantPoints)
        guard let image = entry.entrantProfileImage else {
            return cell
        }
        cell.profileImageView.image = image
        return cell
        }
    
}
