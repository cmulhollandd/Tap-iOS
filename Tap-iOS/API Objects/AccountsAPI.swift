//
//  LoginAPI.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/25/24.
//

import Foundation


enum AccountAction {
    case newAccount
    case resetPassword
}

class AccountsAPI: NSObject {
    
    private static let baseAPIURL = "https://rhodestap.com"
    
    private class LoginData: Codable {
        let username: String
        let password: String
        
        init(_ username: String, _ password: String) {
            self.username = username
            self.password = password
        }
    }
    
    private class SignUpData: Codable {
        let firstName: String
        let lastName: String
        let email: String
        let username: String
        let password: String
        
        init(_ firstName: String, _ lastName: String, _ email: String, _ username: String, _ password: String) {
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.username = username
            self.password = password
        }
    }    
    
    /// Tries to login user with supplied username and password
    ///
    /// - Parameters:
    ///     - username: Username to login user
    ///     - password: Password to login user
    ///     - completion: Escaping closure
    static func loginUser(username: String, password: String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        
        let components = URLComponents(string: "\(baseAPIURL)/auth/login")!
        
        let credentials = LoginData(username, password)
                
        var data: Data
        
        do {
            data = try APIHelpers.encoder.encode(credentials)
        } catch {
            print("Failed to encode login credentials")
            APIHelpers.completeWithError("Failed to encode login credentials", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
                print("error: No response data downloaded")
                APIHelpers.completeWithError("error: No response data downloaded", completion: completion)
                return
            }
            
            // For now, we will assume the presence of a JWT in the response implies a
            // successful login.  In the future, I would like to extend this to check
            // other ways to make sure the account is not locked.
            if let jwt = resp["jwt"] as? String, jwt != "" {
                APIHelpers.complete(resp, completion: completion)
            } else {
                APIHelpers.completeWithError("Incorrect username or password, please try again", completion: completion)
            }
        }
        task.resume()
    }
    
    /// Resets the password using the username and reset token. If this is successful, we need to login again to get a new auth token
    ///
    /// - Parameters:
    ///     - username: username of user resetting their password
    ///     - newPassword: new password for user
    ///     - completion: escaping closure with response from server
    static func resetPassword(username: String, newPassword: String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/change-password")!
        let payload: [String: String] = ["username": username, "newPassword": newPassword]
        var data: Data
        
        do {
            data = try APIHelpers.encoder.encode(payload)
        } catch {
            print("Failed to encode data")
            APIHelpers.completeWithError("Failed to encode data", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let resp = response as? HTTPURLResponse {
                if resp.statusCode != 200 {
                    APIHelpers.completeWithError("An unexpected error occured, please try again", completion: completion)
                    return
                } else {
                    APIHelpers.complete(["message": "Password reset successful"], completion: completion)
                }
            } else {
                fatalError()
            }
        }
        task.resume()
    }
    
    
    /// Creates a new account if an existing account with the same email does not alread exist
    ///
    ///  - Parameters:
    ///     - email: Email for new user
    ///     - password: Password for new user
    ///     - firstName: First name of new user
    ///     - lastName: Last name of new user
    ///     - completion: escaping closure with response from server
    static func createAcccount(email: String, username: String, password: String, firstName: String, lastName: String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        
        let components = URLComponents(string: "\(baseAPIURL)/auth/register")!
        let credentials = SignUpData(firstName, lastName, email, username, password)
        var data: Data
        
        do {
            data = try APIHelpers.encoder.encode(credentials)
        } catch {
            print("Failed to encode credentials")
            APIHelpers.completeWithError("Failed to encode credentials", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return req
        }()
        
        let task = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            guard let resp = APIHelpers.convertDataToJSON(from: data) else {
                print("error: No response data downloaded")
                APIHelpers.completeWithError("error: No response data downloaded", completion: completion)
                return
            }
            
            // For now, we will assume the presence of a userID in the response indicates
            // a successful signup. In the future there may need to be more methods to
            // account for username scarcity and duplicate accounts, but for now this should be fine
            if let _ = resp["userId"] {
                APIHelpers.complete(resp, completion: completion)
            } else {
                APIHelpers.completeWithError("Unable to create account, please try again", completion: completion)
            }
        }
        task.resume()
    }
    
    
    /// Sends a request to the server to change the username of the user from old to new
    ///
    ///   NOTE: This method is not complete. to be completed it requires a the server to send a response code using
    ///         HTTP codes.
    ///
    /// - Parameters:
    ///   - old: Current username of the user to be changed
    ///   - new: New username of the user to be changed
    ///   - completion: Escaping closure with respone from server
    static func changeUsername(for user: TapUser, to new: String, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/change-username")!
        let payload: [String: String] = ["oldUsername": user.username, "newUsername": new]
        var data: Data
        
        do {
            try data = APIHelpers.encoder.encode(payload)
        } catch {
            print("Failed to encode \(#function) parameters")
            APIHelpers.completeWithError("Failed to encode \(#function) parameters", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(user.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let dataTask = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let resp = response as? HTTPURLResponse {
                if resp.statusCode != 200 {
                    APIHelpers.completeWithError("An unexpected error occurred, please try again", completion: completion)
                    print(resp.description)
                    print(resp.debugDescription)
                } else {
                    APIHelpers.complete(["message": "Username successfully changed!"], completion: completion)
                }
            } else {
                fatalError()
            }
        }
        
        dataTask.resume()
    }
    
    static func changeEmail(for user: TapUser, to newEmail: String, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/change-email")!
        let payload: [String: String] = ["username": user.username, "newEmail": newEmail]
        var data: Data
        
        do {
            try data = APIHelpers.encoder.encode(payload)
        } catch {
            print("Failed to encode \(#function) parameters")
            APIHelpers.completeWithError("Failed to encode \(#function) parameters", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(user.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let dataTask = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let resp = response as? HTTPURLResponse {
                if resp.statusCode != 200 {
                    APIHelpers.completeWithError("An unexpected error occurred, please try again", completion: completion)
                } else {
                    APIHelpers.complete(["message": "email successfully changed!"], completion: completion)
                }
            } else {
                fatalError()
            }
        }
        
        dataTask.resume()
    }
    
    static func changePassword(for user: TapUser, to newPassword: String, completion: @escaping([String: Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/change-email")!
        let payload: [String: String] = ["username": user.username, "newPassword": newPassword]
        var data: Data
        
        do {
            try data = APIHelpers.encoder.encode(payload)
        } catch {
            print("Failed to encode \(#function) parameters")
            APIHelpers.completeWithError("Failed to encode \(#function) parameters", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(user.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let dataTask = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let resp = response as? HTTPURLResponse {
                if resp.statusCode != 200 {
                    APIHelpers.completeWithError("An unexpected error occurred, please try again", completion: completion)
                } else {
                    APIHelpers.complete(["message": "password successfully changed"], completion: completion)
                }
            } else {
                fatalError()
            }
        }
        
        dataTask.resume()
    }
    
    static func deleteAccount(for user: TapUser, completion: @escaping([String:Any]) -> Void) {
        let components = URLComponents(string: "\(baseAPIURL)/user/delete-account")!
        let payload: [String: String] = ["username": user.username]
        var data: Data
        
        do {
            try data = APIHelpers.encoder.encode(payload)
        } catch {
            print("Failed to encode \(#function) parameters")
            APIHelpers.completeWithError("Failed to encode \(#function) parameters", completion: completion)
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "DELETE"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(user.authToken)", forHTTPHeaderField: "Authorization")
            return req
        }()
        
        let dataTask = APIHelpers.session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let error = error {
                print(error)
                APIHelpers.completeWithError(error.localizedDescription, completion: completion)
                return
            }
            
            if let resp = response as? HTTPURLResponse {
                if resp.statusCode != 200 {
                    APIHelpers.completeWithError("An unexpected error occurred, please try again", completion: completion)
                } else {
                    APIHelpers.complete(["message": "account deleted"], completion: completion)
                }
            } else {
                fatalError()
            }
        }
        
        dataTask.resume()
    }
}
