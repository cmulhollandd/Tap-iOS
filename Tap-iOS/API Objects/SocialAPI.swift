//
//  SocialAPI.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/4/24.
//

import Foundation

class SocialAPI: NSObject {
    
    private static let baseAPIURL = "https://rhodestap.com"
    
    
    /// Request to follow another user
    /// - Parameters:
    ///   - username: username of user to be followed
    ///   - completion: completion handler
    public static func followUser(followee: String, follower: String, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/follow-user")!
        let payload = ["follower" : follower, "followee" : followee]
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("failed to encode request data in \(#function) in \(#file)")
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
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            APIHelpers.complete([:], completion: completion)
        }
        
        task.resume()
    }
    
    /// Request to unfollow another user
    /// - Parameters:
    ///   - username: username of user to unfollow
    ///   - completion: completion handler
    public static func unFollowUser(followee: String, follower: String, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/unfollow-user")!
        let payload = ["follower" : follower, "followee" : followee]
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("failed to encode request data in \(#function) in \(#file)")
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
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            APIHelpers.complete([:], completion: completion)
        }
        
        task.resume()
    }
    
    /// Get followers of user
    /// - Parameters:
    ///   - user: user to get followers of
    ///   - completion: completion handler
    public static func getFollowers(of user: TapUser, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/view-followers")!
        let payload = ["username": user.username]
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("failed to encode request data in \(#function) in \(#file)")
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
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            
            guard let data = data else {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [String] {
                    let ret = ["followers": resp]
                    APIHelpers.complete(ret, completion: completion)
                } else {
                    print("No response data downloaded")
                    APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                    return
                }
            } catch {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
        }
        
        task.resume()
    }
    
    /// Get followees of user
    /// - Parameters:
    ///   - user: user to get followees of
    ///   - completion: completion handler
    public static func getFollowing(of user: TapUser, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/view-following")!
        let payload = ["username": user.username]
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("failed to encode request data in \(#function) in \(#file)")
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
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            
            guard let data = data else {
                print(#line, "No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [String] {
                    let ret = ["following": resp]
                    APIHelpers.complete(ret, completion: completion)
                } else {
                    print(#line, "No response data downloaded")
                    APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                    return
                }
            } catch {
                print(#line, "No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
        }
        
        task.resume()
    }
    
    /// Get details of a user by their username
    /// - Parameters:
    ///   - username: username of user
    ///   - completion: completion handler
    public static func getUserDetails(of username: String, completion: @escaping([String:Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/get-user")!
        let payload = ["username": username]
        
        var data: Data
        
        do {
            try data = JSONSerialization.data(withJSONObject: payload)
        } catch {
            APIHelpers.completeWithError("Failed to encode payload in \(#function)", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "content-type")
            req.addValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = data
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            
            guard let data = data else {
                print(#line, "No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [String] {
                    let details = resp[0]
                    let comp = details.split(separator: /\,/)
                    print(comp)
                    let ret = ["username": String(comp[0]), "firstName": String(comp[1]), "lastName": String(comp[2]), "email": String(comp[3])]
                    print(ret)
                    APIHelpers.complete(ret, completion: completion)
                } else {
                    print(#line, "No response data downloaded")
                    APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                    return
                }
            } catch {
                print(#line, "No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
        }
        task.resume()
    }
    
    /// Send a new post to the feed
    /// - Parameters:
    ///   - post: new post
    ///   - user: user authoring the post
    ///   - completion: completion handler
    public static func newPost(_ post: TapFeedPost, user: TapUser, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/create-post")!
        let payload = ["poster": user.username, "message": post.textContent, "date": post.getDateString(), "hour": post.getHour(), "minute": post.getMinute()]
        
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("failed to encode request data in \(#function) in \(#file)")
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
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            
            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            print(resp)
            APIHelpers.complete(resp, completion: completion)
        }
        
        task.resume()
    }
    
    public static func getNewPosts(completion: @escaping([[String: Any]]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/view-posts")!
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "GET"
            req.setValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(#function, error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                }
            }
            
            guard let data = data else {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    APIHelpers.complete(resp, completion: completion)
                } else {
                    print("No response data downloaded")
                    APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                    return
                }
            } catch {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
        }
        task.resume()
    }
    
    public static func getPostsBy(user: String, completion: @escaping([[String: Any]]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/view-posts-by-user")!
        
        var data: Data
        
        do {
            try data = JSONSerialization.data(withJSONObject: ["username": user])
        } catch {
            print("failed to encode request data in \(#function) in \(#file)")
            APIHelpers.completeWithError("Failed to encode request data in \(#function)", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(#function, error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                }
            }
            
            guard let data = data else {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    APIHelpers.complete(resp, completion: completion)
                } else {
                    print("No response data downloaded")
                    APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                    return
                }
            } catch {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
        }
        task.resume()
        
    }
    
    public static func getLeaderboard(completion: @escaping([[String: Any]]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/view-leaderboard")!
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "GET"
            req.addValue("application/json", forHTTPHeaderField: "content-type")
            req.addValue("Bearer \(APIHelpers.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print(error.localizedDescription)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    APIHelpers.completeWithError(response.description, completion: completion)
                    return
                }
                
            }
            
            guard let data = data else {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
            
            do {
                if let resp = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    APIHelpers.complete(resp, completion: completion)
                } else {
                    print("No response data downloaded")
                    APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                    return
                }
            } catch {
                print("No response data downloaded")
                APIHelpers.completeWithError("Error: no response data downloaded", completion: completion)
                return
            }
        }
        task.resume()
    }
}
