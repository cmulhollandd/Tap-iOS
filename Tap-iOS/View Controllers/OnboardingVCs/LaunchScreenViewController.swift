//
//  LaunchScreenViewController.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 3/21/24.
//

import Foundation
import UIKit
import Lottie

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet var animationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animationView = .init(name: "NEW_taplauncher_lottie_v2")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFill
        view.addSubview(animationView!)
        
        // let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        // destinationViewController?.modalPresentationStyle = .fullScreen
        // destinationViewController?.modalTransitionStyle = .crossDissolve
        // present(destinationViewController!, animated: true, completion: nil)
        
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.animationView!.loopMode = .playOnce
            self.animationView!.animationSpeed = 1.0
            self.animationView!.play(completion: { _ in
                self.performSegue(withIdentifier: "LoginViewController", sender: nil)
            })
        }
    }
}

