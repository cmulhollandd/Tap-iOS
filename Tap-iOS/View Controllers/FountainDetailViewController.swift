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
    
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        
        self.referringVC.panelController.move(to: .full, animated: true)
        
    }
    
    func setFountain(to fountain: Fountain?) {
        
        if let fountain = fountain {
            self.fountain = fountain
            self.coolnessLabel.text = nf.string(from: NSNumber(value: fountain.getCoolness()))
            self.pressureLabel.text = nf.string(from: NSNumber(value: fountain.getPressure()))
            self.tasteLabel.text = nf.string(from: NSNumber(value: fountain.getTaste()))
            let typeText: String = fountain.getFountainType()
            self.typeLabel.text = typeText
            self.reviewButton.isEnabled = true
        } else {
            self.fountain = nil
            self.coolnessLabel.text = "N/A"
            self.pressureLabel.text = "N/A"
            self.tasteLabel.text = "N/A"
            self.typeLabel.text = "No Fountain Selected"
            self.reviewButton.isEnabled = false
        }
    }
    
    
}
