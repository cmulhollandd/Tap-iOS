//
//  LoginViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/23/24.
//

import Foundation
import UIKit
import Valet


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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (UserDefaults.standard.bool(forKey: "TapKeepUserLoggedIn")) {
            tryAutoLogin()
        }
    }
    
    // MARK: - @IBActions
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            let alert = UIAlertController(title: "Login Failed", message: "Please enter username & password", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        print("Logging in with \(username) and \(password)")
        
        if !(usernameTextField.hasText && passwordTextField.hasText) {
            let alert = UIAlertController(title: "Login Failed", message: "Please enter username & password", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        loginUser(username: username, password: password)
    }
    
    /// Attempts to login the user using the supplied credentials
    /// Upon successful login, the main tabBarController for Tap is presented
    ///
    ///  - Parameters;
    ///      - username: String username
    ///      - password: String password
    private func loginUser(username: String, password: String) {
        AccountsAPI.loginUser(username: username, password: password) { response in
            if (response["error"] != nil) {
                // Could not login, alert user
                let alert = UIAlertController(title: "Login Failed", message: response["description"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
                self.removeLoginInfo()
            } else {
                // Successful login, create global user instance, save login info if needed, present homescreen
                let dict = response
                
                do {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.user = try TapUser(from: dict)
                } catch {
                    print(error.localizedDescription)
                    return
                }

                if (UserDefaults.standard.bool(forKey: "TapKeepUserLoggedIn")) {
                    self.saveLoginInfo(username: username, password: password)
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    /// Attempts to save userLogin info securely in the keychain for autologins in the future
    ///
    ///  Parameters:
    ///     - username: Username to be saved in the keychain
    ///     - password: Password to be saved in the keychain
    func saveLoginInfo(username: String, password: String) {
        let myValet = Valet.valet(with: Identifier(nonEmpty: "Tap-iOS")!, accessibility: .whenUnlocked)
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        
        do {
            let containsUsername = try myValet.containsObject(forKey: "Tap-iOS-username")
            let containsPassword = try myValet.containsObject(forKey: "Tap-iOS-password")
            
            if (containsUsername && containsPassword) {
                return
            }
        } catch {
            print("Error checking if credentials already saved \(#function)")
        }
        
        do {
            try myValet.setString(username, forKey: "Tap-iOS-username")
            try myValet.setString(password, forKey: "Tap-iOS-password")
        } catch {
            print("Error saving credentials to keychain: \(#function)")
        }
    }
    
    /// Attemps to retrieve saved login info from the keychain. If login credentials are available, attempts to login user.
    func tryAutoLogin() {
        let myValet = Valet.valet(with: Identifier(nonEmpty: "Tap-iOS")!, accessibility: .whenUnlocked)
        
        do {
            let username = try myValet.string(forKey: "Tap-iOS-username")
            let password = try myValet.string(forKey: "Tap-iOS-password")
            
            print("Retreived saved username: \(username) and password: \(password)")
            
            
            loginUser(username: username, password: password)
        } catch {
            print("Error retrieving credentials from keychain: \(#function)")
        }
    }
    
    func removeLoginInfo() {
        let myValet = Valet.valet(with: Identifier(nonEmpty: "Tap-iOS")!, accessibility: .whenUnlocked)
        
        do {
            try myValet.removeObject(forKey: "Tap-iOS-username")
            try myValet.removeObject(forKey: "Tap-iOS-password")
        } catch {
            print("Could not remove login items, possible they didn't exist to begin with")
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
            self.loginButtonPressed(textField)
        default:
            print("Unknown textField from \(#file)")
        }
        return true
    }
}
