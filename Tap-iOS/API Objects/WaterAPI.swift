//
//  WaterAPI.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/30/24.
//

import Foundation

struct WaterAPI {
    
    private static let baseAPIURL = "https://rhodestap.com/user"
    
    /// Data payload object for the method addWater(...)
    private class AddWaterPayload: Codable {
        let author: String
        let ozOfWater: Float
        
        init(author: String, ozOfWater: Float) {
            self.author = author
            self.ozOfWater = ozOfWater
        }
    }
    
    /// Calls Backend to log newly drank water to Tap
    /// - Parameters:
    ///   - water: Newly drank water to be added
    ///   - user: TapUser who logged the water (*should* always be the user logged into the app)
    ///   - completion: completion handler
    public static func submitWater(_ ozOfWater: Water, by author: TapUser, completion: @escaping([String:Any]) -> Void) {
        
        let components = URLComponents(string: "\(baseAPIURL)/submit-water")!
//        let payload = AddWaterPayload(author: author.username, ozOfWater: ozOfWater.getOzOfWater())
        let payload: [String : Any] = ["username": author.username, "ozOfWater": ozOfWater.getOzOfWater()]
        
        var data: Data
        
        do {
//            data = try APIHelpers.encoder.encode(payload)
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to encode water data")
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
            APIHelpers.complete([:], completion: completion)
        }
        task.resume()
    }
}
