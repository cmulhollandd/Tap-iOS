//
//  LeaderboardStore.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/18/24.
//

import Foundation
import UIKit

class LeaderboardStore: NSObject {
    
    var entries = [LeaderboardEntry]()
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        return nf
    }()
    
    func getUsername(for indexPath: IndexPath) -> String {
        return entries[indexPath.row].entrantUsername
    }
    
    func reloadLeaderboard(completion: @escaping(Bool, String?) -> Void) {
        self.entries = []
        SocialAPI.getLeaderboard { resp in
            if resp.count != 0, let _ = resp[0]["error"] as? Bool {
                // error occured
                completion(true, resp[0]["message"] as? String)
                return
            }
            
            for entryDict in resp {
                guard
                    let username = entryDict["username"] as? String,
                    let points = entryDict["points"] as? Double,
                    let ozOfWater = entryDict["ozOfWater"] as? Double
                else {
                    continue
                }
                
                let entry = LeaderboardEntry(entrantPlace: -1, entrantUsername: username, entrantProfileImage: nil, entrantPoints: Int(points))
                self.entries.append(entry)
            }
            self.entries.sort { lhs, rhs in
                return lhs.entrantPoints > rhs.entrantPoints
            }
            completion(false, nil)
        }
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
        cell.placeLabel.text = "\(indexPath.row+1)"
        cell.pointsLabel.text = "\(entry.entrantPoints)"
        guard let image = entry.entrantProfileImage else {
            return cell
        }
        cell.profileImageView.image = image
        return cell
    }
    
}
