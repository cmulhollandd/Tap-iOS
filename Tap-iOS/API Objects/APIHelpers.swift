//
//  APIHelpers.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/29/24.
//

import Foundation
import UIKit

struct APIHelpers {
    
    static let encoder = JSONEncoder()
    static let session: URLSession = {
        let session = URLSession(configuration: .default)
        return session
    }()
    
    static var authToken: String {
        get {
            let localUser = (UIApplication.shared.delegate as! AppDelegate).user!
            guard let token = localUser.authToken else {
                fatalError()
            }
            return token
        }
    }
    
    /// Converts a Data object to <String:Any>?, assuming a json format
    ///
    ///  - Parameters:
    ///      - data: Data? object to be converted into Dictionary
    static func convertDataToJSON(from data: Data?) -> [String:Any]? {
        guard let data = data else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data) as? [String:Any]
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Calls an Escaping handler to return the result of an API call to the calling class
    ///
    /// - Parameters:
    ///      - dict: <String:Any> dictionary of information to be returned to the calling class
    ///      - completion: escaping handler to be called
    static func complete(_ dict: [String:Any], completion: @escaping([String:Any]) -> Void) {
        OperationQueue.main.addOperation {
            completion(dict)
        }
    }
    
    /// Calls an Escaping handler to return the result of an API call to the calling class upon error
    /// Adds an "error" and "description" entries to a dict to alert the calling class of the error
    ///
    /// - Parameters:
    ///      - description: String description of the error that occured
    ///      - completion: escaping handler to be called
    static func completeWithError(_ description: String, completion: @escaping([String:Any]) -> Void) {
        let dict = ["error" : true, "message": description] as [String:Any]
        OperationQueue.main.addOperation {
            completion(dict)
        }
    }
}
