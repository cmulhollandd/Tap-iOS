//
//  FountainStore.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/22/24.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class FountainStore: NSObject {
    
    var fountains: [Fountain] = []
    var delegate: FountainStoreDelegate? = nil
    
    override init() {
        super.init()
        
        // Dummy Data until API call is available
        let fountain1 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15489, longitude: -89.98926), coolness: 4.8, pressure: 8.3, taste: 3.4, type: .comboFillerFountain)
        let fountain2 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15560, longitude: -89.98986), coolness: 7.2, pressure: 2.5, taste: 5.9, type: .comboFillerFountain)
        let fountain3 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15516, longitude: -89.98989), coolness: 1.6, pressure: 6.4, taste: 4.8, type: .bottleFillerOnly)
        let fountain4 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15645, longitude: -89.98821), coolness: 8.1, pressure: 1.5, taste: 5.7, type: .bottleFillerOnly)
        let fountain5 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15487, longitude: -89.98929), coolness: 7.3, pressure: 3.9, taste: 9.2, type: .comboFillerFountain)
        
        self.fountains = [fountain1, fountain2, fountain3, fountain4, fountain5]
    }
    
    /// Updates fountains with new data from API
    ///
    /// - Parameters:
    ///      - region: Coordinate Region in which fountain data should be requested
    func updateFountains(around region: MKCoordinateRegion) {
        // Call API to get new fountains around region
        
        // Alert delegate of new change
        if let delegate = self.delegate {
            delegate.fountainStore(self, didUpdateFountains: fountains)
        }
    }
    
    func getFountain(from location: CLLocationCoordinate2D) -> Fountain? {
        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        for fountain in fountains {
            if (loc.distance(from: fountain.getLocation()) < 1.0) {
                return fountain
            }
        }
        return nil
    }
}

protocol FountainStoreDelegate {
    
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains: [Fountain])
    
}
