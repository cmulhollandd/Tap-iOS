//
//  Water.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/30/24.
//

import Foundation
import UIKit

class Water: Codable {
    // a log of total oz drank by a user
    var username: String
    var ozOfWater: Float
    
    init(username: String, ozOfWater: Float) {
        self.username = username
        self.ozOfWater = ozOfWater
    }
    
    func getUsername() -> String {
        return self.username
    }
    
    func setUsername(_ username: String) {
        self.username = username
    }
    
    func getOzOfWater() -> Float {
        return self.ozOfWater
    }
    
    func setOzOfWater(_ ozOfWater: Float) {
        self.ozOfWater = ozOfWater
    }
}
