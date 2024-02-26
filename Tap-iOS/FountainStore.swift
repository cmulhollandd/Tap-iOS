//
//  FountainStore.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/22/24.
//

import Foundation
import UIKit
import MapKit

class FountainStore: NSObject {
    
    var fountains: [Fountain] = []
    var delegate: FountainStoreDelegate? = nil
    
    override init() {
        super.init()
        
        // Dummy Data until API call is available
        let fountain1 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15489, longitude: -89.98926), coolness: 5, pressure: 5, taste: 5, type: .comboFillerFountain)
        let fountain2 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15560, longitude: -89.98986), coolness: 5, pressure: 5, taste: 5, type: .comboFillerFountain)
        let fountain3 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15516, longitude: -89.98989), coolness: 5, pressure: 5, taste: 5, type: .bottleFillerOnly)
        let fountain4 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15645, longitude: -89.98821), coolness: 5, pressure: 5, taste: 5, type: .bottleFillerOnly)
        let fountain5 = Fountain(location: CLLocationCoordinate2D(latitude: 35.15487, longitude: -89.98929), coolness: 5, pressure: 5, taste: 5, type: .comboFillerFountain)
        
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
}

protocol FountainStoreDelegate {
    
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains: [Fountain])
    
}
