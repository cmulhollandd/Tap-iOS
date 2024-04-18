//
//  ChangeEmailViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/31/24.
//

import Foundation
import UIKit

class ChangeEmailViewController: UIViewController {
    @IBOutlet var oldEmailTextField: UITextField!
    @IBOutlet var newEmailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backgroundTapRecognized(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        if (user.email != oldEmailTextField.text) {
            let alert = UIAlertController(title: "Incorrect email", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { action in
                self.oldEmailTextField.text = ""
            }
            alert.addAction(ok)
            present(alert, animated: true)
        } else {
            if (newEmailTextField.text == "" || !checkEmail(newEmailTextField.text!)) {
                let alert = UIAlertController(title: "Please enter a new email", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                present(alert, animated: true)
            }
            AccountsAPI.changeEmail(for: user, to: newEmailTextField.text!) { resp in
                let alert = UIAlertController(title: resp["message"] as? String, message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
        }
    }
    
    /// Checks if the proposed email string matches the format for an email address
    /// *This may not be entirely foolproof, but it is better than nothing*
    /// - Parameter email: proposed new email string
    /// - Returns: true if email appears to be an email, false otherwise
    private func checkEmail(_ email: String) -> Bool {
        return email.contains(/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/)
    }
}
