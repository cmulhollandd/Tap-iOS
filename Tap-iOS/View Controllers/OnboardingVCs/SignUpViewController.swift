//
//  SignUpViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/23/24.
//

import Foundation
import UIKit


class SignUpViewController: UIViewController {
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
        
        // Assign all textField Delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    // MARK: - @IBActions
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
        createAccount()
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
    
    /// Validates all fields are completed
    ///
    ///  - Returns: Boolean specifying required fields are completed
    private func validateInputs() -> Bool {
        return !(firstNameTextField.text!.isEmpty &&
                lastNameTextField.text!.isEmpty &&
                emailTextField.text!.isEmpty &&
                usernameTextField.text!.isEmpty &&
                passwordTextField.text!.isEmpty)
    }
    
    /// Presents a generic error alert to user
    ///
    /// - Parameters:
    ///     - subtitle: String subtitle for the alert controller
    private func presentErrorAlert(subtitle: String) {
        let alert = UIAlertController(title: "Unable to create account", message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    /// Attemps to login the user using the contents of the text fields
    /// Upon successful account creation the user is prompted to return to the login screen
    private func createAccount() {
        guard validateInputs() else {
            self.presentErrorAlert(subtitle: "Please complete all required fields")
            return
        }
        LoginAPI.createAcccount(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (dict) in
            
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
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (!validatePassword()) {
            // Set textField border to red
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            self.view.endEditing(true)
            createAccount()
        default:
            print("Unknown textfield from \(#file)")
        }
        return true
    }
}
