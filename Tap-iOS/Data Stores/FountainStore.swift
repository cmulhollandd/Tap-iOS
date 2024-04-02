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


enum FilterCriteria: Int {
    case all = -1
    case fountainOnly = 0
    case bottleFillerOnly = 1
    case comboFillerFountain = 2
}

class FountainStore: NSObject {
    
    var allFountains: [Fountain] = []
    var visibleFountains: [Fountain] = []
    var delegate: FountainStoreDelegate? = nil
    var currentFilter: FilterCriteria = .all
    
    override init() {
        super.init()
        
        // Dummy Data until API call is available
        var fountains = [Fountain]()
        
        for i in 0 ... 9 {
            let lon = Double.random(in: -89.99113 ... -89.98687)
            let lat = Double.random(in: 35.15170 ... 35.15968)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            fountains.append(Fountain(id: i, location: coord, coolness: Double.random(in: 0...10), pressure: Double.random(in: 0...10), taste: Double.random(in: 0...10), type: Fountain.FountainType(rawValue: Int.random(in: 0...2))!))
        }
        self.addNewFountains(fountains)
    }
    
    /// Updates fountains with new data from API
    ///
    /// - Parameters:
    ///      - region: Coordinate Region in which fountain data should be requested
    func updateFountains(around region: MKCoordinateRegion) {
        // Call API to get new fountains around region
        
        filterFountains(by: currentFilter)
    }
    
    func getFountain(from location: CLLocationCoordinate2D) -> Fountain? {
        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        for fountain in allFountains {
            if (loc.distance(from: fountain.getLocation()) < 1.0) {
                return fountain
            }
        }
        return nil
    }
    
    func addNewFountains(_ fountains: [Fountain]) {
        for fountain in fountains {
            allFountains.append(fountain)
        }
        filterFountains(by: currentFilter)
    }
    
    
    func filterFountains(by criteria: FilterCriteria) {
        currentFilter = criteria
        switch (criteria) {
        case .all:
            self.visibleFountains = allFountains
        default:
            visibleFountains = []
            for fountain in allFountains {
                if fountain.getFountainType().rawValue == criteria.rawValue {
                    visibleFountains.append(fountain)
                }
            }
        }
        delegate?.fountainStore(self, didUpdateFountains: visibleFountains)
    }
    
}

protocol FountainStoreDelegate {
    
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains: [Fountain])
    
}
