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

class WaterLoggingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var ozField: UITextField!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var editBottleButton: UIBarButtonItem!
    
    var total: Float = 0
    var bottleSize: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ozField.delegate = self
        // Retrieve total & bottle size from storage
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
        if let daysTotal = UserDefaults.standard.object(forKey: "WaterIntake_\(user.username)") as? Float {
            // Use the retrieved value
            // daysTotal now contains the value retrieved from UserDefaults
            if daysTotal >= 128 {
                total = 128
                totalLabel.text = "Gallon Limit Reached!"
            }
            else {
                total = daysTotal
                totalLabel.text = "Today's Total: \(Int(total)) oz."
            }
        } else {
            // Set a default value of 0
            UserDefaults.standard.set(0, forKey: "WaterIntake_\(user.username)")
            totalLabel.text = "Today's Total: \(Int(0)) oz."
            // total will now be 0
        }
        if let savedSize = UserDefaults.standard.object(forKey: "bottle_\(user.username)") as? Int {
            // A value is already stored in UserDefaults for the key "bottle"
            // You can use the value stored in savedSize here
            print("Bottle value found in UserDefaults: \(savedSize)")
            bottleSize = savedSize
        } else {
            // No value is stored in UserDefaults for the key "bottle"
            print("No value found in UserDefaults for key 'bottle'")
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
        // button cooldown
        sender.isEnabled = false
        // adds button value to text field
        if let currentOz = ozField.text {
            if var currentNumber = Int(currentOz) {
                currentNumber = min(currentNumber + bottleSize, 128)
                ozField.text = String(currentNumber)
            }
            else {
                ozField.text = String(bottleSize)
            }
        }
        animationView.play(completion: { finished in
            // This code will be executed when the animation finishes playing
            if finished {
                print("Animation finished playing")
                // enable button again
                sender.isEnabled = true
            }
        })
    }
    @IBAction func plusButton(_ sender: UIButton) {
        if let currentOz = ozField.text {
            if var currentNumber = Int(currentOz) {
                currentNumber = min(currentNumber + 1, 128)
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
                currentNumber = max(currentNumber - 1, 0)
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
                // check if daily total exceeded
                let prevTotal = UserDefaults.standard.float(forKey: "WaterIntake_\(currentUser.username)")
                if prevTotal >= 128 {
                    // Display a warning alert
                    let warningAlert = UIAlertController(title: "Gallon Limit Reached", message: "You may not log any more water.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    warningAlert.addAction(okAction)
                    self.present(warningAlert, animated: true, completion: nil)
                } else {
                    // submit locally
                    total = min(prevTotal + currentNumber, 128) // global total set
                    let user = currentUser.username
                    UserDefaults.standard.set(total, forKey: "WaterIntake_\(user)")
                    updateUI()
                    // submit backend
                    // make currentNumber limit
                    let submission = total - prevTotal
                    let userwater = Water(username: user, ozOfWater: submission)
                    postNewWater(water: userwater, user: currentUser) { (error, description) -> Void in
                        if error {
                            let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default)
                            alert.addAction(ok)
                            self.present(alert, animated: true)
                        } else {
                            let alert = UIAlertController(title: "Water Added", message: nil, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default) {_ in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alert.addAction(ok)
                            self.present(alert, animated: true)
                        }
                    }
                }
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
            if let _ = resp["error"] as? Bool {
                completion(true, resp["message"] as? String)
                return
            }
            completion(false, nil)
        }
    }
    
    // Function to handle bar button item tap
    @IBAction func editBarButtonTapped(_ sender: UIBarButtonItem) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Edit Bottle Size", message: "Enter a new value (oz.)", preferredStyle: .alert)
        
        // Add a text field to the alert controller
        alertController.addTextField { textField in
            textField.placeholder = "Enter a number"
            textField.keyboardType = .numberPad // Set keyboard type to number pad
            textField.delegate = self
        }
        
        // Add a confirm action
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let textField = alertController.textFields?.first,
               let text = textField.text,
               let newValue = Int(text) {
                // Check if the entered value is above 100
                if newValue > 128 {
                    // Display a warning alert
                    let warningAlert = UIAlertController(title: "Gallon Limit Exceeded", message: "Please enter a number equal to or less than 128.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    warningAlert.addAction(okAction)
                    self.present(warningAlert, animated: true, completion: nil)
                } else {
                    // The entered value is valid, proceed with updating bottle size
                    self.bottleSize = newValue
                    // Perform any action with the new integer value
                    print("New bottle size: \(self.bottleSize)")
                    let user = (UIApplication.shared.delegate as! AppDelegate).user!
                    UserDefaults.standard.set(self.bottleSize, forKey: "bottle_\(user.username)")
                }
            }
        }
        
        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert controller
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Define allowed characters (in this case, only numbers)
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        // Check if the replacement string contains only allowed characters
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: characterSet)
    }
}
