//
//  ProfileViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 3/9/24.
//

import Foundation
import UIKit

class PersonalProfileViewController: UserProfileViewController {
    
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    
    override func loadView() {
        super.loadView()
        
        if let user = (UIApplication.shared.delegate as! AppDelegate).user {
            self.user = user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsButton.tintColor = UIColor(named: "systemBackgroundColor")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let username = delegate.user.username
        
        self.navigationItem.title = "\(username)"
    }
    
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsNavController")
        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
    }
}
