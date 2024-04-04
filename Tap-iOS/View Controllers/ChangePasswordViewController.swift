//
//  ChangePasswordViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/31/24.
//

import Foundation
import UIKit
import Valet

class ChangePasswordViewController: UIViewController {
    @IBOutlet var oldPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backgroundTapRecognized(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        
        // In the future we should check to make sure the current password is actually the user's password
        // But for now we don't have an endpoint to check just that
        
        if (newPasswordTextField.text == "") {
            let alert = UIAlertController(title: "Please enter a new password", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        } else if !checkPassword(newPasswordTextField.text!) {
            let alert = UIAlertController(title: "New passeord does not match password criteria", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        }
        AccountsAPI.changePassword(for: user, to: newPasswordTextField.text!) { resp in
            let alert = UIAlertController(title: resp["message"] as? String, message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true)
            
            if let _ = resp["error"] {
                return
            }
            
            self.updateUserDetails(for: self.newPasswordTextField.text!)
        }
    }
    
    private func checkPassword(_ pw: String) -> Bool {
        return pw.contains(/[0-9]/) && pw.contains(/[a-z]/) && pw.contains(/[A-Z]/) && pw.count >= 8
    }
    
    private func updateUserDetails(for newPassword: String) {
        guard UserDefaults.standard.bool(forKey: "TapKeepUserLoggedIn") else {
            return
        }
        let myValet = Valet.valet(with: Identifier(nonEmpty: "Tap-iOS")!, accessibility: .whenUnlocked)
        do {
            try myValet.setString(newPassword, forKey: "Tap-iOS-password")
        } catch {
            print(error)
        }
    }
}
