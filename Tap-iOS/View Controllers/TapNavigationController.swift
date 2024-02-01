//
//  TapNavigationController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 1/31/24.
//

import Foundation
import UIKit


class TapNavigationController: UINavigationController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}
