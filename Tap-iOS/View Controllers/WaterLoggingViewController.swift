//
//  WaterLoggingViewController.swift
//  Tap-iOS
//
//  Created by John Beuerlein on 4/25/24.
//

import Foundation
import UIKit
import Lottie
import SwiftUI

class WaterLoggingViewController: UIViewController {
    @IBOutlet var animationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.contentMode = .scaleToFill
        // animationView.play(fromFrame: 24, toFrame: 48)
        // LottieAnimationView.pause()
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        animationView.play()
    }
}
