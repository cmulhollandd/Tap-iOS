//
//  LeaderboardEntry.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/18/24.
//

import Foundation
import UIKit

class LeaderboardEntry {
    
    let entrantPlace: Int
    let entrantUsername: String
    let entrantProfileImage: UIImage?
    let entrantPoints: Int
    
    init() {
        self.entrantPlace = 0
        self.entrantUsername = ""
        self.entrantProfileImage = nil
        self.entrantPoints = 0
    }
    
    init(entrantPlace: Int, entrantUsername: String, entrantProfileImage: UIImage?, entrantPoints: Int) {
        self.entrantPlace = entrantPlace
        self.entrantUsername = entrantUsername
        self.entrantProfileImage = entrantProfileImage
        self.entrantPoints = entrantPoints
    }
}
