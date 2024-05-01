//
//  Water.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/30/24.
//

import Foundation
import UIKit

struct Water: Codable {
    // a log of total oz drank by a user
    let username: String
    let ozOfWater: Float
    
    init(username: String, ozOfWater: Float) {
        self.username = username
        self.ozOfWater = ozOfWater
    }
    
    func getOzOfWater() -> Float {
        return ozOfWater
    }
}
