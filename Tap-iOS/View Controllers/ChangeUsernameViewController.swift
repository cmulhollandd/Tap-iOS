//
//  ChangeUsernameViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/31/24.
//

import Foundation
import UIKit

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
            AccountsAPI.changeUsername(from: user.username, to: newUsernameTextField.text!) { resp in
                let alert = UIAlertController(title: resp["message"] as? String, message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
        }
    }
}
