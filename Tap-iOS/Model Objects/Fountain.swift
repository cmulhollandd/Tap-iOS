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
    private var coolness: Double
    private var pressure: Double
    private var taste: Double
    private var type: FountainType
    
    init(location: CLLocationCoordinate2D, coolness: Double, pressure: Double, taste: Double, type: FountainType) {
        let loc = FountainCoordinate(latitude: location.latitude, longitude: location.longitude)
        self.location = loc
        self.coolness = coolness
        self.pressure = pressure
        self.taste = taste
        self.type = type
    }
    
    
    func getLocationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.location.latitude, longitude: self.location.longitude)
    }
    
    func getLocation() -> CLLocation {
        return CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
    }
    
    func getCoolness() -> Double {
        return self.coolness
    }
    
    func getPressure() -> Double {
        return self.pressure
    }
    
    func getTaste() -> Double {
        return self.taste
    }
    
    func getFountainType() -> String {
        switch (self.type) {
        case .fountainOnly:
            return "Fountain Only"
        case .bottleFillerOnly:
            return "Bottle Filler Only"
        case .comboFillerFountain:
            return "Fountain and Bottle Filler"
        }
    }
    
    func getFountainType() -> FountainType {
        return self.type
    }
    
    func getAvgRating() -> Double {
        return (self.coolness + self.pressure + self.taste) / 3.0
    }
}
