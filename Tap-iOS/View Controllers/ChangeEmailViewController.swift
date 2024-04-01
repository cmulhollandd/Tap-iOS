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
            AccountsAPI.changeEmail(for: user.email, to: newEmailTextField.text!) { resp in
                let alert = UIAlertController(title: resp["message"] as? String, message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
        }
    }
    
    private func checkEmail(_ email: String) -> Bool {
        return email.contains(/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/)
    }
}
