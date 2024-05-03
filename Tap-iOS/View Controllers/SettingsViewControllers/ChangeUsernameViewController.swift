//
//  ChangeUsernameViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/31/24.
//

import Foundation
import UIKit
import Valet

class ChangeUsernameViewController: UIViewController {
    @IBOutlet var oldUsernameTextField: UITextField!
    @IBOutlet var newUsernameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backgroundTapRecognized(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        if (user.username != oldUsernameTextField.text) {
            let alert = UIAlertController(title: "Incorrect username", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { action in
                self.oldUsernameTextField.text = ""
            }
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            if (newUsernameTextField.text == "") {
                let alert = UIAlertController(title: "Please enter a new username", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                present(alert, animated: true)
            }
            AccountsAPI.changeUsername(for: user, to: newUsernameTextField.text!) { resp in
                let alert = UIAlertController(title: resp["message"] as? String, message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
                
                if let _ = resp["error"] {
                    return
                }
                
                self.updateUserDetails(for: self.newUsernameTextField.text!)
            }
        }
    }
    
    /// Updates the saved username after a change
    /// - Parameter newUsername: new username string 
    private func updateUserDetails(for newUsername: String) {
        guard UserDefaults.standard.bool(forKey: "TapKeepUserLoggedIn") else {
            return
        }
        let myValet = Valet.valet(with: Identifier(nonEmpty: "Tap-iOS")!, accessibility: .whenUnlocked)
        do {
            try myValet.setString(newUsername, forKey: "Tap-iOS-username")
        } catch {
            print(error)
        }
        
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        user.username = newUsername
    }
}
