//
//  ProfileViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/9/24.
//

import Foundation
import UIKit

class PersonalProfileViewController: UIViewController {
    
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let username = delegate.user.username
        
        self.navigationItem.title = "\(username)"
        
        settingsButton.tintColor = UIColor(named: "systemBackgroundColor")
    }
    
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsNavController")
        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
    }
}
