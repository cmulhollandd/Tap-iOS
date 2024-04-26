//
//  FountainAPI.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/28/24.
//

import Foundation

struct FountainAPI {
    
    private static let baseAPIURL = "https://rhodestap.com/fountain"
    
    /// Data payload object for the method addFountain(...)
    private class AddFountainPayload: Codable {
        let xCoord: Double
        let yCoord: Double
        let rating: Double
        let author: String
        let description: String
        
        init(xCoord: Double, yCoord: Double, rating: Double, author: String, description: String) {
            self.xCoord = xCoord
            self.yCoord = yCoord
            self.rating = rating
            self.author = author
            self.description = description
        }
    }
    
    /// Object specifying a region on a map represented by a minimum and maximum latitude and longitude
    class Region {
        let minLat: Double
        let minLon: Double
        let maxLat: Double
        let maxLon: Double
        
        init(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double) {
            self.minLat = minLat
            self.minLon = minLon
            self.maxLat = maxLat
            self.maxLon = maxLon
        }
        
        func getDict() -> [String: Double] {
            return [
                "minLat": minLat,
                "minLon": minLon,
                "maxLat": maxLat,
                "maxLon": maxLon
            ]
        }
    }
    
    
    /// Calls Backend to post a newly created fountain to Tap
    /// - Parameters:
    ///   - fountain: Newly created fountain to be added
    ///   - author: TapUser who created the new fountain (*should* always be the user loggd into the app
    ///   - completion: completion handler
    public static func addFountain(_ fountain: Fountain, by author: TapUser, completion: @escaping([String:Any]) -> Void) {
        
        let components = URLComponents(string: "\(baseAPIURL)/add")!
        let payload = AddFountainPayload(xCoord: fountain.getLocationCoordinate().latitude,
                                         yCoord: fountain.getLocationCoordinate().longitude,
                                         rating: fountain.getAvgRating(),
                                         author: author.username,
                                         description: fountain.getFountainType())
        
        var data: Data
        
        do {
            data = try APIHelpers.encoder.encode(payload)
        } catch {
            print("Failed to encode fountain data")
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print("\(#file) \(#line) \(error.localizedDescription)")
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                }
            }
            
            
            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
                print("error: NO response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            print(#file, #line, resp)
            APIHelpers.complete(resp, completion: completion)
        }
        task.resume()
    }
    
    
    /// Calls the backend to delete and existing fountain from Tap
    /// - Parameters:
    ///   - fountain: Fountain to be deleted
    ///   - author: Author who created and is now deleting the fountain (*should* always be the user logged into the app
    ///   - completion: completion handler
    public static func deleteFountain(_ fountain: Fountain, by author: TapUser, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/delete")!
        let payload = ["fountainID": fountain.id]
        
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to encode fountain data")
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "DELETE"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print(response.description)
                    APIHelpers.completeWithError(response.description, completion: completion)
                }
            }
            
            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
                print("error: NO response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            print(resp)
            APIHelpers.complete(resp, completion: completion)
                        
        }
        task.resume()
    }
    
    
    /// Calls the backend server to post a new fountain review to a fountain on Tap
    /// - Parameters:
    ///   - review: New review to be added to fountain
    ///   - fountain: Fountain the review relates to
    ///   - user: author of the new review
    ///   - completion: completion handler
    public static func addReview(_ review: FountainReview, for fountain: Fountain, by user: TapUser, completion: @escaping([String: Any]) -> Void) {
        
        let components = URLComponents(string: "\(baseAPIURL)/add-review")!
        let payload: [String: Any] = [
            "fountainId": "\(fountain.id)",
            "reviewer": user.username,
            "description": review.getDescription(),
            "rating": review.getRatingString()
        ]
        
        var data: Data
        
        do {
            try data = JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to encode JSON Data")
            APIHelpers.completeWithError("Failed to encode request payload in \(#function)", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error.localizedDescription, #line)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print(response.description, #line)
                    APIHelpers.completeWithError(response.description, completion: completion)
                }
            }
            
            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
                print("error: NO response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            print(resp)
            APIHelpers.complete(resp, completion: completion)
        }
        task.resume()
    }
    
    
    /// Calls the backend server to return all the fountains contained in region
    /// - Parameters:
    ///   - region: Region object specifiying the search space for the fountains
    ///   - completion: completion handler
    public static func getFountains(in region: Region, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/get-in-area")!
        
        var data: Data
        
        do {
            try data = JSONSerialization.data(withJSONObject: region.getDict())
        } catch {
            print("Failed to encode JSON Data")
            APIHelpers.completeWithError("Failed to encode request payload in \(#function)", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error.localizedDescription, #line)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print(response.description, #line)
                    APIHelpers.completeWithError(response.description, completion: completion)
                }
            }
            
            guard let data = data else {
                print("error: No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            var resp: [[String: Any]] = []
            
            do {
                resp = try JSONSerialization.jsonObject(with: data) as! [[String:Any]]
            } catch {
                print("error: could not parse data")
                APIHelpers.completeWithError("Error: could not parse data", completion: completion)
                return
            }
            
//            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
//                print("error: NO response data downloaded")
//                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
//                return
//            }
            
            
            let ret: [String: Any] = ["fountains": resp]
            APIHelpers.complete(ret, completion: completion)
        }
        task.resume()
    }
    
    
}
