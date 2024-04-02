//
//  LaunchScreenViewController.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 3/21/24.
//

import UIKit
import Lottie

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet var animationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animationView = .init(name: "NEW_taplauncher_lottie_v2")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleToFill
        view.addSubview(animationView!)
        
        let destinationViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        destinationViewController?.modalPresentationStyle = .fullScreen
        destinationViewController?.modalTransitionStyle = .crossDissolve
        present(destinationViewController!, animated: true, completion: nil)
        
        animationView!.loopMode = .playOnce
                animationView!.animationSpeed = 1.0
                animationView!.play(completion: { _ in
                    self.performSegue(withIdentifier: "LoginViewController", sender: nil)
                })
    }
}

