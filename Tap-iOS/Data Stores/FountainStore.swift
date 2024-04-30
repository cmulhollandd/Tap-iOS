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


/// Filter enum for fountains
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
//        var fountains = [Fountain]()
//        
//        let user = (UIApplication.shared.delegate as! AppDelegate).user!
//        
//        for i in 0 ... 10 {
//            let lon = Double.random(in: -89.99113 ... -89.98687)
//            let lat = Double.random(in: 35.15170 ... 35.15968)
//            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//            fountains.append(Fountain(id: i, author: user, location: coord, coolness: Double.random(in: 0...10), pressure: Double.random(in: 0...10), taste: Double.random(in: 0...10), type: Fountain.FountainType(rawValue: Int.random(in: 0...2))!))
//        }
//        self.addNewFountains(fountains)
    }
    
    /// Updates fountains with new data from API
    ///
    /// - Parameters:
    ///      - region: Coordinate Region in which fountain data should be requested
    func updateFountains(around region: MKCoordinateRegion, completion: @escaping(Bool, String?) -> Void) {
        // Call API to get new fountains around region
        
        let divisor = 1.7 // Can be adjusted to load more fountains outside of immediate map area, for efficiency
//        let minLat = region.center.latitude - (region.span.latitudeDelta / divisor)
//        let minLon = region.center.longitude - (region.span.longitudeDelta / divisor)
//        let maxLat = region.center.latitude + (region.span.latitudeDelta / divisor)
//        let maxLon = region.center.longitude + (region.span.longitudeDelta / divisor)
        
        let minLon = region.center.latitude - (region.span.latitudeDelta / divisor)
        let minLat = region.center.longitude - (region.span.longitudeDelta / divisor)
        let maxLon = region.center.latitude + (region.span.latitudeDelta / divisor)
        let maxLat = region.center.longitude + (region.span.longitudeDelta / divisor)
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
                guard let id = _fountain["fountainId"] as? Int else {
                    completion(true, "Invalid fountainID found in response")
                    return
                }
                if self.fountainStoreContainsFountain(with: id) {
                    continue
                }
                
                print(_fountain)
                
                guard
                    let id = _fountain["fountainId"] as? Int,
                    let author = _fountain["author"] as? String,
                    let latitude = _fountain["xCoord"] as? Double,
                    let longitude = _fountain["yCoord"] as? Double,
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
    
    /// Returns a fountain, if one exists, which is located at location
    /// - Parameter location: Location of the fountain
    /// - Returns: Fountain or nil is no fountain is found
    func getFountain(from location: CLLocationCoordinate2D) -> Fountain? {
        let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
        for fountain in allFountains {
            if (loc.distance(from: fountain.getLocation()) < 1.0) {
                return fountain
            }
        }
        return nil
    }
    
    /// Adds new fountains to this FountainStore, does **NOT** post them to the backend
    /// - Parameter fountains: Array of fountain objects to be added
    func addNewFountains(_ fountains: [Fountain]) {
        for fountain in fountains {
            allFountains.append(fountain)
        }
        filterFountains(by: currentFilter)
    }
    
    /// Adds a single new fountain to this FountainStore, does **NOT** post them to the backend
    /// - Parameter fountain: Fountain to be added
    func addNewFountain(_ fountain: Fountain) {
        allFountains.append(fountain)
        filterFountains(by: currentFilter)
    }
    
    /// Posts a new fountain to the backend by calling the appropriate method in FountainAPI.
    ///
    /// If the response from the API is not an error, the id of the fountain object passed in is updated
    /// and it is added to this FountainStore
    /// - Parameters:
    ///   - fountain: Fountain object to be added
    ///   - completion: completion handler
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
    
    /// Filters the visible fountains on the map by the specified criteria
    /// - Parameter criteria: FilterCriteria specifiying which fountains should be visible on the map
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
    
    /// Submits a new review for a fountain
    /// - Parameters:
    ///   - review: New FountainReview to be posted
    ///   - fountain: Fountain relating to this FountainReview
    ///   - completion: completion handler
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
    
    /// Checks if a fountain with a specified id is contained in this FountainStore
    /// - Parameter id: Integer id to be searched for
    /// - Returns: true if a matching fountain is present, false otherwise
    func fountainStoreContainsFountain(with id: Int) -> Bool {
        for fountain in allFountains {
            if fountain.id == id {
                return true
            }
        }
        return false
    }
    
    static func getFountainsBy(user username: String) -> [Fountain] {
        
        // Call API to get fountains
        
        return []
    }
    
}

/// Delegate protocols for FountainStore
protocol FountainStoreDelegate {
    
    /// Alerts the delegate that the FountainStore has updated the visible fountains
    /// - Parameters:
    ///   - fountainStore: This FountainStore
    ///   - didUpdateFountains: Array of new Fountain objects
    func fountainStore(_ fountainStore: FountainStore, didUpdateFountains: [Fountain])
    
}
