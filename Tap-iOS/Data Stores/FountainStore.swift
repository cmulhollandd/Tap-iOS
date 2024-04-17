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
        
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        
        for i in 0 ... 1 {
//            let lon = Double.random(in: -89.99113 ... -89.98687)
//            let lat = Double.random(in: 35.15170 ... 35.15968)
            
            let lon = Double.random(in: -90.0 ... -89.97)
            let lat = Double.random(in: 35.14 ... 35.17)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            fountains.append(Fountain(id: i, author: user, location: coord, coolness: Double.random(in: 0...10), pressure: Double.random(in: 0...10), taste: Double.random(in: 0...10), type: Fountain.FountainType(rawValue: Int.random(in: 0...2))!))
        }
        self.addNewFountains(fountains)
    }
    
    /// Updates fountains with new data from API
    ///
    /// - Parameters:
    ///      - region: Coordinate Region in which fountain data should be requested
    func updateFountains(around region: MKCoordinateRegion, completion: @escaping(Bool, String?) -> Void) {
        // Call API to get new fountains around region
        
        let divisor = 1.7 // Can be adjusted to load more fountains outside of immediate map area, for efficiency
        let minLat = region.center.latitude - (region.span.latitudeDelta / divisor)
        let minLon = region.center.longitude - (region.span.longitudeDelta / divisor)
        let maxLat = region.center.latitude + (region.span.latitudeDelta / divisor)
        let maxLon = region.center.longitude + (region.span.longitudeDelta / divisor)
        FountainAPI.getFountains(in: FountainAPI.Region(minLat: minLat, minLon: minLon, maxLat: maxLat, maxLon: maxLon)) { resp in
            
            if let _ = resp["error"] as? Bool {
                completion(true, resp["message"] as? String)
                return
            }
            
            // Create new fountains and add to all fountains if they are not already present
            guard let fountainsDict = (resp["fountains"] as? [Dictionary<String, Any>]) else {
                completion(true, "Fountains not present in response")
                return
            }
            
            var newFountains = [Fountain]()
            for _fountain in fountainsDict {
                guard let id = _fountain["ID"] as? Int else {
                    completion(true, "Invalid fountainID found in response")
                    return
                }
                if self.fountainStoreContainsFountain(with: id) {
                    continue
                }
                
                guard
                    let id = _fountain["ID"] as? Int,
                    let author = _fountain["author"] as? String,
                    let latitude = _fountain["x_coord"] as? Double,
                    let longitude = _fountain["x_coord"] as? Double,
                    let rating = _fountain["rating"] as? Double,
                    let type = _fountain["description"] as? String
                else {
                    completion(true, "Failed to create fountain objects from response in \(#function)")
                    return
                }
                
                let fountain = Fountain(id: id, author: author, latitude: latitude, longitude: longitude, rating: rating, type: type)
                newFountains.append(fountain)
            }
            
            self.addNewFountains(newFountains)
            completion(false, nil)
        }
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
    
    func addNewFountain(_ fountain: Fountain) {
        allFountains.append(fountain)
        filterFountains(by: currentFilter)
    }
    
    func postNewFountain(fountain: Fountain, completion: @escaping(Bool, String?) -> Void)  {
        let localUser = (UIApplication.shared.delegate as! AppDelegate).user!
        
        FountainAPI.addFountain(fountain, by: localUser) { (resp) in
            
            if let _ = resp["error"] {
                completion(true, resp["message"] as? String)
            }
            
            if let id = resp["fountainId"] as? Int {
                fountain.setFountainID(id)
                self.addNewFountain(fountain)
                completion(false, nil)
            }
            
        }
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
    
    func submitReview(review: FountainReview, for fountain: Fountain, completion: @escaping(Bool, String?) -> Void) {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        FountainAPI.addReview(review, for: fountain, by: user) { resp in
            
            if let _ = resp["error"] as? Bool {
                completion(true, resp["message"] as? String)
            } else {
                fountain.addReview(review: review)
                completion(false, nil)
            }
        }
    }
    
    func fountainStoreContainsFountain(with id: Int) -> Bool {
        for fountain in allFountains {
            if fountain.id == id {
                return true
            }
        }
        return false
    }
    
}

protocol FountainStoreDelegate {
    
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains: [Fountain])
    
}
