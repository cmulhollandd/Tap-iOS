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
    
    @IBOutlet var coolnessLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var tasteLabel: UILabel!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var reviewButton: UIButton!
    @IBOutlet var coolnessSlider: UISlider!
    @IBOutlet var pressureSlider: UISlider!
    @IBOutlet var tasteSlider: UISlider!
    @IBOutlet var fountainWorkingSwitch: UISegmentedControl!
    @IBOutlet var submitReviewButton: UIButton!
    @IBOutlet var deleteFountainButton: UIButton!
    
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        return nf
    }()
    private var fountain: Fountain? = nil
    var referringVC: MapViewController! = nil
    private var sortMenu: UIMenu! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setFountain(to: nil)
        
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
        
        self.reviewButton.isEnabled = false
    }
    
    @IBAction func leaveReviewButtonPressed(_ sender: UIButton) {
        self.referringVC.panelController.move(to: .full, animated: true)
    }
    
    @IBAction func submitReviewButtonPressed(_ sender: UIButton) {
        // Submit review to API
        
        // Move back down to half
        self.referringVC.panelController.move(to: .half, animated: true)
    }
    
    @IBAction func deleteFountainButtonPressed(_ sender: UIButton) {
        
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        
        let alert = UIAlertController(title: "Delete Fountain", message: "Deleting this fountain will remove it from the map for everybody", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            // Delete fountain
            FountainAPI.deleteFountain(self.fountain!, by: user) { resp in
                if let error = resp["error"] {
                    let alert = UIAlertController(title: "Error", message: resp["description"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true)
                    return
                }
                
                self.referringVC.panelController.move(to: .tip, animated: true)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
        
    }
    
    func setFountain(to fountain: Fountain?) {
        
        if let fountain = fountain {
            self.fountain = fountain
            self.coolnessLabel.isEnabled = true
            self.pressureLabel.isEnabled = true
            self.tasteLabel.isEnabled = true
            self.typeLabel.isEnabled = true
            self.reviewButton.isEnabled = true
            self.tasteSlider.isEnabled = true
            self.coolnessSlider.isEnabled = true
            self.pressureSlider.isEnabled = true
            self.submitReviewButton.isEnabled = true
            self.fountainWorkingSwitch.isEnabled = true
            
            
            self.coolnessLabel.text = nf.string(from: NSNumber(value: fountain.getCoolness()))
            self.pressureLabel.text = nf.string(from: NSNumber(value: fountain.getPressure()))
            self.tasteLabel.text = nf.string(from: NSNumber(value: fountain.getTaste()))
            self.typeLabel.text = fountain.getFountainType()
            let localUser = (UIApplication.shared.delegate as! AppDelegate).user!
            if (localUser.username == fountain.authorUsername) {
                deleteFountainButton.isEnabled = true
            } else {
                deleteFountainButton.isEnabled = false
            }
        } else {
            self.fountain = nil
            self.coolnessLabel.text = "N/A"
            self.pressureLabel.text = "N/A"
            self.tasteLabel.text = "N/A"
            self.typeLabel.text = "No Fountain Selected"
            
            self.reviewButton.isEnabled = false
            self.deleteFountainButton.isEnabled = false
            self.coolnessLabel.isEnabled = false
            self.pressureLabel.isEnabled = false
            self.tasteLabel.isEnabled = false
            self.typeLabel.isEnabled = false
            self.tasteSlider.isEnabled = false
            self.coolnessSlider.isEnabled = false
            self.pressureSlider.isEnabled = false
            self.submitReviewButton.isEnabled = false
            self.fountainWorkingSwitch.isEnabled = false
        }
    }
    
    
}
