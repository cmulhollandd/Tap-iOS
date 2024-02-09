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
    }
    
    
    // MARK: - @IBActions
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        if (validateInputs()) {
            self.presentErrorAlert(subtitle: "Please complete all required fields")
        }
        
        LoginAPI.createAcccount(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastname: lastNameTextField.text!) { (dict) in
            
            if (dict["error"] != nil) {
                self.presentErrorAlert(subtitle: dict["description"] as! String)
                return
            }
            
            let alert = UIAlertController(title: "Account Successfully Created", message: nil, preferredStyle: .alert)
            let goToLogin = UIAlertAction(title: "Go to Login", style: .default) {_ in 
                self.dismiss(animated: true)
            }
            alert.addAction(goToLogin)
            self.present(alert, animated: true)
        }
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
    
    private func validateInputs() -> Bool {
        return (firstNameTextField.text!.isEmpty ||
            lastNameTextField.text!.isEmpty ||
            emailTextField.text!.isEmpty ||
            usernameTextField.text!.isEmpty ||
            passwordTextField.text!.isEmpty)
    }
    
    private func presentErrorAlert(subtitle: String) {
        let alert = UIAlertController(title: "Unable to create account", message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
