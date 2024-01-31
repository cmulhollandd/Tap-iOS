//
//  ForgotPasswordViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/30/24.
//

import Foundation
import UIKit


class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        // Send request to server to make sure account with email exists
        // If the request is successful, the user should receive and email with a code to type into the app
        // Once they type in the code they may choose a new password
    }
    
    
}
