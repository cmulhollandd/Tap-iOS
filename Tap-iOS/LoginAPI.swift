//
//  LoginAPI.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/25/24.
//

import Foundation


struct LoginAPI {
    
    private static let baseAPIURL = ""
    
    static let session: URLSession = {
        let sess = URLSession(configuration: .default)
        return sess
    }()
    
    
    /*
     Trys to login a user using the supplied username and password
     */
    static func loginUser(username: String, password: String, completion: @escaping(String) -> Void) {
        
    }
    
    /*
     Requests a password reset token from the server
     */
    static func requestPasswordReset(username: String, completion: @escaping(String) -> Void) {
        
    }
    
    /*
     Resets the password using the username and reset token
     */
    static func resetPassword(username: String, resetToken: String, newPassword: String, completion: @escaping(String) -> Void) {
        
    }
    
    /*
     Creates a new account
     */
    static func createAcccount(email: String, password: String, firstName: String, lastname: String, completion: @escaping(String) -> Void) {
        
    }
    
}
