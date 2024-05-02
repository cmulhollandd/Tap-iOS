//
//  FountainDetailViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/27/24.
//

import Foundation
import UIKit
import FloatingPanel

class FountainDetailViewController: UIViewController {
    
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var leaveReviewButton: UIButton!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var deleteFountainButton: UIButton!
    
    @IBOutlet var reviewSlider: UISlider!
    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var submitReviewButton: UIButton!
    @IBOutlet var reviewStackView: UIStackView!
    
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        return nf
    }()
    private var fountain: Fountain? = nil
    var fountainStore: FountainStore!
    var referringVC: MapViewController! = nil
    private var sortMenu: UIMenu! = nil
    private var isLeavingReview = false
    var userOwnsFountain = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setFountain(to: nil)
        self.reviewStackView.isHidden = true
        
        self.reviewTextView.delegate = self
        self.reviewTextView.textColor = .lightText
        
        self.view.backgroundColor = UIColor.clear
        
        let all = UIAction(title: "Show All") { _ in
            self.referringVC.fountainStore.filterFountains(by: .all)
        }
        let fountains = UIAction(title: "Fountains") { _ in
            self.referringVC.fountainStore.filterFountains(by: .fountainOnly)
        }
        let fillers = UIAction(title: "Bottle Fillers") { _ in
            self.referringVC.fountainStore.filterFountains(by: .bottleFillerOnly)
        }
        let combo = UIAction(title: "Combo Fountains") { _ in
            self.referringVC.fountainStore.filterFountains(by: .comboFillerFountain)
        }
        self.sortMenu = UIMenu(title: "Sort", options: .singleSelection, children: [all, fountains, fillers, combo])
        self.sortButton.menu = self.sortMenu
        self.sortButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func leaveReviewButtonPressed(_ sender: Any?) {
        if !isLeavingReview {
            self.referringVC.panelController.move(to: .full, animated: true)
            self.reviewStackView.isHidden = false
            self.leaveReviewButton.setTitle("Cancel Review", for: .normal)
            self.leaveReviewButton.setTitleColor(.red, for: .normal)
            self.isLeavingReview = true
        } else {
            self.reviewStackView.isHidden = true
            self.leaveReviewButton.setTitle("Leave a Review", for: .normal)
            self.leaveReviewButton.setTitleColor(UIColor(named: "TapPrimaryBlue"), for: .normal)
            self.referringVC.panelController.move(to: .half, animated: true)
            self.isLeavingReview = false
        }
        
        
    }
    
    @IBAction func submitReviewButtonPressed(_ sender: UIButton) {
        print("Submitting a review from: ", #file, #line)
        guard let fountain = self.fountain else {
            print("No Fountain in View Controller: \(#file)")
            return
        }
        let rating = reviewSlider.value
        let description = reviewTextView.text!
        let review = FountainReview(rating: Double(rating), description: description)
        self.fountainStore.submitReview(review: review, for: fountain) {
            (error: Bool, message: String?) in
            
            if error {
                let alert = UIAlertController(title: "Unable to Submit Review", message: "Please Try Again Later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
            } else {
                print("Review submitted successfully")
                self.referringVC.panelController.move(to: .tip, animated: true)
                self.setFountain(to: nil)
            }
        }
        
    }
    
    @IBAction func deleteFountainButtonPressed(_ sender: UIButton) {
        if userOwnsFountain {
            let user = (UIApplication.shared.delegate as! AppDelegate).user!
            let alert = UIAlertController(title: "Delete Fountain", message: "Deleting this fountain will remove it from the map for everybody", preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
                guard let fountain = self.fountain else {
                    return
                }
                self.fountainStore.deleteFountain(fountain) { err, message in
                    if err {
                        let alert = UIAlertController(title: "Error", message: message!, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default)
                        alert.addAction(ok)
                        self.present(alert, animated: true)
                        return
                    }
                    self.setFountain(to: nil)
                    self.referringVC.panelController.move(to: .tip, animated: true)
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
        } else {
            guard let fountain = fountain else {
                return
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            let user = TapUser(first: fountain.authorUsername, last: fountain.authorUsername, username: fountain.authorUsername, email: fountain.authorUsername, loginToken: nil, profilePhoto: nil)
            vc.user = user
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /// Updates the ViewController's views to show information about the selected fountain
    /// - Parameter fountain: the newly selected Fountain
    func setFountain(to fountain: Fountain?) {
        if let fountain = fountain {
            self.fountain = fountain
            self.typeLabel.isEnabled = true
            self.reviewLabel.isEnabled = true
            self.reviewLabel.text = nf.string(from: NSNumber(value: fountain.getCoolness()))
            self.typeLabel.text = fountain.getFountainType()
            self.leaveReviewButton.isEnabled = true
            let localUser = (UIApplication.shared.delegate as! AppDelegate).user!
            if (localUser.username == fountain.authorUsername) {
                deleteFountainButton.isEnabled = true
                deleteFountainButton.tintColor = UIColor.red
                deleteFountainButton.setTitle("Delete Fountain", for: .normal)
                userOwnsFountain = true
            } else {
                // REconfigure delete button to show user profile
                deleteFountainButton.isEnabled = true
                deleteFountainButton.tintColor = UIColor(named: "PrimaryBlue")
                deleteFountainButton.setTitle("View Creator Profile", for: .normal)
                userOwnsFountain = false
            }
            deleteFountainButton.isEnabled = true
            deleteFountainButton.tintColor = UIColor(named: "PrimaryBlue")
            deleteFountainButton.setTitle("View Creator Profile", for: .normal)
            userOwnsFountain = false
        } else {
            self.fountain = nil
            self.reviewLabel.text = "N/A"
            self.typeLabel.text = "No Fountain Selected"
            self.deleteFountainButton.isEnabled = false
            self.reviewLabel.isEnabled = false
            self.typeLabel.isEnabled = false
            self.leaveReviewButton.isEnabled = false
            self.reviewStackView.isHidden = true
            userOwnsFountain = false
        }
    }
}

extension FountainDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightText {
            // Nothing in the textView yet
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter a fountain description here..."
            textView.textColor = UIColor.lightText
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
