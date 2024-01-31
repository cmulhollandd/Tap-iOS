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
    
    private static let baseAPIURL = "http://ec2-3-145-175-92.us-east-2.compute.amazonaws.com/"
    
    
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
    static func loginUser(username: String, password: String, completion: @escaping(String) -> Void) {
        
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
    static func createAcccount(email: String, password: String, firstName: String, lastname: String, completion: @escaping(String) -> Void) {
        
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
