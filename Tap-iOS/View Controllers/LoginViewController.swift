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
        titleImage.tintColor = UIColor(named: "PrimaryTapBlue")
    }
    
    // MARK: - @IBActions
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let username = usernameTextField.text ?? "[NIL]"
        let password = passwordTextField.text ?? "[NIL]"
        
        print("Logging in with \(username) and \(password)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        
        vc.modalPresentationStyle = .overFullScreen
    
        present(vc, animated: true)
    }
}
