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
    @IBOutlet var ozField: UITextField!
    @IBOutlet var headerText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.contentMode = .scaleToFill
        // animationView.play(fromFrame: 24, toFrame: 48)
        // LottieAnimationView.pause()
        
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.systemBackground,
            .foregroundColor: UIColor.primaryBlue,
            .strokeWidth: -15.0, // Adjust the value as needed
        ]
        headerText.attributedText = NSAttributedString(string: headerText.text ?? "", attributes: strokeTextAttributes)
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        animationView.play()
        // can only press button once
        sender.isEnabled = false
        // adds arbitrary value to text field
        let bottleValue = 10
        if let currentOz = ozField.text {
            if var currentNumber = Int(currentOz) {
                currentNumber += bottleValue
                ozField.text = String(currentNumber)
            }
            else {
                ozField.text = String(bottleValue)
            }
        }
    }
    @IBAction func plusButton(_ sender: UIButton) {
        if let currentOz = ozField.text {
            if var currentNumber = Int(currentOz) {
                currentNumber += 1
                ozField.text = String(currentNumber)
            }
            else {
                ozField.text = String(1)
            }
        }
    }
    @IBAction func minusButton(_ sender: UIButton) {
        if let currentOz = ozField.text {
            if var currentNumber = Int(currentOz),
            currentNumber != 0 {
                currentNumber -= 1
                ozField.text = String(currentNumber)
            }
            else {
                print("Nothing to subtract from")
            }
        }
    }
}
