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
    @IBOutlet var totalLabel: UILabel!
    
    var total: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        // Retrieve total from storage
        total = UserDefaults.standard.float(forKey: "total")
        updateUI()
        
        // Check if date has changed to reset total daily
        resetTotalIfNecessary()
        
        // Set up animated button
        animationView.contentMode = .scaleToFill
        if let containerView = animationView.superview {
            containerView.sendSubviewToBack(animationView)
        } else {
            print("Animation view doesn't have a superview.")
        }
        // animationView.play(fromFrame: 24, toFrame: 48)
        // LottieAnimationView.pause()
        
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.systemBackground,
            .foregroundColor: UIColor.primaryBlue,
            .strokeWidth: -15.0, // Adjust the value as needed
        ]
        headerText.attributedText = NSAttributedString(string: headerText.text ?? "", attributes: strokeTextAttributes)
    }
    func updateUI() {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        total = UserDefaults.standard.float(forKey: "WaterIntake_\(user.username)")
        if total > 100 {
            totalLabel.text = "Water Limit Reached!"
        }
        else {
            totalLabel.text = "Today's Total: \(total) oz."
        }
    }
    
    func resetTotalIfNecessary() {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        let lastDate = UserDefaults.standard.object(forKey: "lastDate") as? Date
        let currentDate = Date()
        
        // Compare current date with last saved date
        if let lastDate = lastDate, Calendar.current.isDate(lastDate, inSameDayAs: currentDate) == false {
            // Reset total if date has changed
            total = 0
            UserDefaults.standard.set(total, forKey: "WaterIntake_\(user.username)")
            UserDefaults.standard.set(currentDate, forKey: "lastDate")
            updateUI()
        }
    }
    @IBAction func buttonPressed(_ sender: UIButton) {
        animationView.play()
        // can only press button once
        sender.isEnabled = false
        // adds arbitrary value to text field
        let bottleValue = Int(10)
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
    @IBAction func submitButton(_ sender: UIButton) {
        if let currentOz = ozField.text {
            if let currentOz = ozField.text,
               let currentNumber = Float(currentOz), currentNumber != 0,
               let delegate = UIApplication.shared.delegate as? AppDelegate,
               let currentUser = delegate.user {
                // submit locally
                total += currentNumber
                let user = currentUser.username
                UserDefaults.standard.set(total, forKey: "WaterIntake_\(user)")
                updateUI()
                let userwater = Water(username: user, ozOfWater: currentNumber)
                postNewWater(water: userwater, user: currentUser) { (error, description) -> Void in
                    if error {
                        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(ok)
                        self.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Water Added", message: nil, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(ok)
                        self.present(alert, animated: true)
                    }
                }
                // Dismiss the view controller
                navigationController?.popViewController(animated: true)
                } else {
                    print("User not available")
                    // Handle the case where user is nil
                }
            } else {
                print("Nothing to submit")
            }
        }
    func postNewWater(water: Water, user: TapUser, completion: @escaping(Bool, String?) -> Void)  {
        WaterAPI.submitWater(water, by: user) { (resp) in
            if let _ = resp["error"] {
                completion(true, resp["message"] as? String)
            }
        }
    }
}
