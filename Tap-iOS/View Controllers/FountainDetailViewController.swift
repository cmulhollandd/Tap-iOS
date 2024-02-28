//
//  FountainDetailViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 2/27/24.
//

import Foundation
import UIKit

class FountainDetailViewController: UIViewController {
    
    @IBOutlet var coolnessLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var tasteLabel: UILabel!
    
    private var nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        return nf
    }()
    
    private var fountain: Fountain? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.clear
    }
    
    func setFountain(to fountain: Fountain?) {
        
        if let fountain = fountain {
            self.fountain = fountain
            
            self.coolnessLabel.text = nf.string(from: NSNumber(value: fountain.getCoolness()))
            self.pressureLabel.text = nf.string(from: NSNumber(value: fountain.getPressure()))
            self.tasteLabel.text = nf.string(from: NSNumber(value: fountain.getTaste()))
        } else {
            self.fountain = nil
            self.coolnessLabel.text = "0.0"
            self.pressureLabel.text = "0.0"
            self.tasteLabel.text = "0.0"
        }
    }
}
