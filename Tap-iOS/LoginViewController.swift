//
//  LoginViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/23/24.
//

import Foundation
import UIKit


class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        
        vc.modalPresentationStyle = .overFullScreen
    
        present(vc, animated: true)
    }
}
