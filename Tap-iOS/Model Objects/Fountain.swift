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

class Fountain: Codable, Equatable {
    
    enum FountainType: Int, Codable {
        case fountainOnly = 0
        case bottleFillerOnly = 1
        case comboFillerFountain = 2
    }
    
    var id: Int
    let authorUsername: String
    private var location: FountainCoordinate
    private var coolness: Double
    private var pressure: Double
    private var taste: Double
    private var type: FountainType
    private var reviews = [FountainReview]()
    
    convenience init(id: Int, author: TapUser, location: CLLocationCoordinate2D, coolness: Double, pressure: Double, taste: Double, type: FountainType) {
        let avgRating = (coolness + pressure + taste) / 3.0
        
        var typeString = ""
        
        switch (type) {
        case .fountainOnly:
            typeString = "Drinking Fountain Only"
        case .bottleFillerOnly:
            typeString = "Bottle Filler Only"
        case .comboFillerFountain:
            typeString = "Fountain and Bottle Filler"
        }
        
        self.init(id: id, author: author.username, latitude: location.latitude, longitude: location.longitude, rating: avgRating, type: typeString)
    }
    
    init(id: Int, author: String, latitude: Double, longitude: Double, rating: Double, type: String) {
        self.id = id
        self.authorUsername = author
        self.coolness = rating
        self.pressure = rating
        self.taste = rating
        self.location = FountainCoordinate(latitude: latitude, longitude: longitude)
        switch (type) {
        case "Drinking Fountain Only":
            self.type = .fountainOnly
        case "Bottle Filler Only":
            self.type = .bottleFillerOnly
        case "Fountain and Bottle Filler":
            self.type = .comboFillerFountain
        default: // This should never hit, but just in case
            self.type = .comboFillerFountain
        }
    }
    
    func setFountainID(_ id: Int) {
        self.id = id
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
            return "Drinking Fountain Only"
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
    
    static func == (lhs: Fountain, rhs: Fountain) -> Bool {
        return lhs.id == rhs.id
    }
    
    func addReview(review: FountainReview) {
        self.reviews.append(review)
    }
    
    static func fountainType(from _string: String) -> FountainType {
        switch (_string) {
        case "Drinking Fountain Only":
            return .fountainOnly
        case "Bottle Filler Only":
            return .bottleFillerOnly
        case "Fountain and Bottle Filler":
            return .comboFillerFountain
        default:
            return .comboFillerFountain
        }
    }
}
