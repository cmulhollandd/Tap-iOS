//
//  LoginViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/23/24.
//

import Foundation
import UIKit


class LoginViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet var titleImage: UIImageView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleImage.image = titleImage.image?.withRenderingMode(.alwaysTemplate)
        titleImage.tintColor = UIColor(named: "PrimaryBlue")
    }
    
    // MARK: - @IBActions
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        let username = usernameTextField.text ?? "[NIL]"
        let password = passwordTextField.text ?? "[NIL]"
        
        print("Logging in with \(username) and \(password)")
        
        loginUser(username: username, password: password)
    }
    
    private func loginUser(username: String, password: String) {
        LoginAPI.loginUser(username: username, password: password) { response in
            if (response["error"] != nil) {
                // Could not login, alert user
                let alert = UIAlertController(title: "Login Failed", message: response["description"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            } else {
                let dict = response
                _ = TapUser(first: "", last: "", username: username, email: "", loginToken: dict["jwt"] as! String, profilePhoto: nil)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                
                vc.modalPresentationStyle = .overFullScreen
            
                self.present(vc, animated: true)
            }
        }
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            self.view.endEditing(true)
            guard let username = usernameTextField.text, let password = passwordTextField.text else {
                return true
            }
            self.loginUser(username: username, password: password)
        default:
            print("Unknown textField from \(#file)")
        }
        return true
    }
}
