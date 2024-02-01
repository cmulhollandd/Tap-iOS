//
//  SignUpViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/23/24.
//

import Foundation
import UIKit


class SignUpViewController: UIViewController, UITextFieldDelegate {
    // MARK: - @IBOutlets
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        passwordTextField.delegate = self
        signUpButton.isUserInteractionEnabled = false
    }
    
    
    // MARK: - @IBActions
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /// Validates the supplied password matches all criteria
    ///
    /// - Returns: Boolean specifying where password matches criteria
    private func validatePassword() -> Bool {
        let password = passwordTextField.text ?? ""
        return password.contains("[A-Z]") &&
                password.contains("[a-z]") &&
                password.contains("[0-9]") &&
                password.count >= 8
    }
    
    /// Validates the supplied email is in the correct format
    ///
    /// - Returns: Boolean specifying where password matches criteria
    private func validateEmail() -> Bool {
        guard let email = emailTextField.text else {
            return false
        }
        return email.contains(/\w{2,}@\w+\.\w{2,}/)
    }
    
    
    // MARK: - TextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (!validatePassword()) {
            // Set textField border to red
        }
    }
}
