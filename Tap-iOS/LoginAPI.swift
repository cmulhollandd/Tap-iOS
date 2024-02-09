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

struct LoginAPI {
    
    private static let baseAPIURL = "https://ec2-3-145-175-92.us-east-2.compute.amazonaws.com/auth"
    
    private static let encoder = JSONEncoder()
    
    private class LoginData: Codable {
        let username: String
        let password: String
        
        init(_ username: String, _ password: String) {
            self.username = username
            self.password = password
        }
    }
    
    private class SignUpData: Codable {
        let username: String
        let password: String
        
        init(_ username: String, _ password: String) {
            self.username = username
            self.password = password
        }
    }
    
    
    static let session: URLSession = {
        let sess = URLSession(configuration: .default)
        return sess
    }()
    
    
    /// Tries to login user with supplied username and password
    ///
    /// - Parameters:
    ///     - username: Username to login user
    ///     - password: Password to login user
    ///     - completion: Escaping closure
    static func loginUser(username: String, password: String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        
        func complete(_ dict: Dictionary<String, Any>) {
            OperationQueue.main.addOperation {
                completion(dict)
            }
        }
        
        func completeWithError(_ description: String) {
            let dict = ["error" : true, "description" : description] as [String: Any]
            OperationQueue.main.addOperation {
                completion(dict)
            }
        }
        
        let components = URLComponents(string: "\(baseAPIURL)/login")!
        
        let credentials = LoginData(username, password)
        
        var data: Data
        
        do {
            data = try encoder.encode(credentials)
        } catch {
            print("Failed to encode login credentials")
            completeWithError("Failed to encode login credentials")
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            return req
        }()
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let error = error {
                print(error)
                completeWithError(error.localizedDescription)
                return
            }
            
            guard let resp = processLoginJSONData(from: data) else {
                print("error: No response data downloaded")
                completeWithError("error: No response data downloaded")
                return
            }
            
            // For now, we will assume the presence of a JWT in the response implies a
            // successful login.  In the future, I would like to extend this to check
            // other ways to make sure the account is not locked.
            //
            // We are also not passing back all user info for now, this is something that
            // should be done in the future
            if let _ = resp["jwt"] as? String {
                complete(resp)
            } else {
                completeWithError("Incorrect username or password, please try again")
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
    static func createAcccount(email: String, username: String, password: String, firstName: String, lastname: String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        
        func completeWithError(_ description: String) {
            let dict: [String: Any] = ["error": true, "description": description]
            
            OperationQueue.main.addOperation {
                completion(dict)
            }
        }
        
        func complete(_ dict: Dictionary<String, Any>) {
            OperationQueue.main.addOperation {
                completion(dict)
            }
        }
        
        let components = URLComponents(string: "\(baseAPIURL)/register")!
        
        let credentials = SignUpData(username, password)
        
        var data: Data
        
        do {
            data = try encoder.encode(credentials)
        } catch {
            print("Failed to encode credentials")
            completeWithError("Failed to encode credentials")
            return
        }
        
        let request: URLRequest = {
            var req = URLRequest(url: components.url!)
            req.httpMethod = "POST"
            req.httpBody = data
            return req
        }()
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let error = error {
                print(error)
                completeWithError(error.localizedDescription)
                return
            }
            
            guard let resp = processLoginJSONData(from: data) else {
                print("error: No response data downloaded")
                completeWithError("error: No response data downloaded")
                return
            }
            
            // For now, we will assume the presence of a userID in the response indicates
            // a successful signup. In the future there may need to be more methods to
            // account for username scarcity and duplicate accounts, but for now this should be fine
            if let _ = resp["userId"] {
                complete(resp)
            } else {
                completeWithError("Unable to create account, please try again")
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
    
    private static func processLoginJSONData(from data: Data?) -> Dictionary<String, Any>? {
        guard let data = data else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any>
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private static func processSignUpJSONData(from data: Data?) -> Dictionary<String, Any>? {
        return nil
    }
    
}
