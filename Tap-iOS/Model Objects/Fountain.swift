//
//  Fountain.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/15/24.
//

import Foundation
import CoreLocation
import CoreGraphics


struct FountainCoordinate: Codable {
    var latitude: Double
    var longitude: Double
}

class Fountain: Codable {
    
    enum FountainType: Int, Codable {
        case fountainOnly = 0
        case bottleFillerOnly = 1
        case comboFillerFountain = 2
    }
    
    private var location: FountainCoordinate
    private var coolness: Int
    private var pressure: Int
    private var taste: Int
    private var type: FountainType
    
    init(location: CLLocationCoordinate2D, coolness: Int, pressure: Int, taste: Int, type: FountainType) {
        let loc = FountainCoordinate(latitude: location.latitude, longitude: location.longitude)
        self.location = loc
        self.coolness = coolness
        self.pressure = pressure
        self.taste = taste
        self.type = type
    }
}
