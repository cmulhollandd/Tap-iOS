//
//  FountainAPI.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/28/24.
//

import Foundation

struct FountainAPI {
    
    private static let baseAPIURL = "https://rhodestap.com/fountain"
    
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
            req.setValue("Bearer \(author.authToken!)", forHTTPHeaderField: "Authorization")
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
            req.setValue("Bearer \(author.authToken!)", forHTTPHeaderField: "Authorization")
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
    
}
