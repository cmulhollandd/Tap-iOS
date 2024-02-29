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

class LoginAPI: NSObject {
    
    private static let baseAPIURL = "https://rhodestap.com/auth"
    
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
        
        let components = URLComponents(string: "\(baseAPIURL)/login")!
        
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
    
    
    /// Requests a password reset token from the server.
    ///
    /// - Parameters:
    ///     - email: email used to register user resetting their password
    ///     - completion: escaping closure with response from server
    static func requestPasswordReset(email: String, completion: @escaping(String) -> Void) {
        
    }
    
    /// Resets the password using the username and reset token. If this is successful, we need to login again to get a new auth token
    ///
    /// - Parameters:
    ///     - email: email used to register user resetting their password
    ///     - newPassword: new password for user
    ///     - completion: escaping closure with response from server
    static func resetPassword(email: String, resetToken: String, newPassword: String, completion: @escaping(String) -> Void) {
        
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
        
        let components = URLComponents(string: "\(baseAPIURL)/register")!
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
    
    
    /// Sends a code back to the server to verify an account action such as resetting the password or creating an account
    ///
    /// - Parameters:
    ///     - email: Email for account
    ///     - accountAction: action being taken on the account
    ///     - code: unique code received by the user through email
    ///     - completion: Escaping closure with response from server
    static func verifyAccountAction(email: String, accountAction: AccountAction, code: String, completion: @escaping(String) -> Void) {
        
    }
}
