//
//  DeleteAccountViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/4/24.
//

import Foundation
import UIKit

class DeleteAccountViewController: UIViewController {
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Account?", message: "This action cannot be undone, you will lose all access to fountains and posts on Tap.", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteAccount()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    private func deleteAccount() {
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        AccountsAPI.deleteAccount(for: user) { resp in
            if let error = resp["error"] {
                let alert = UIAlertController(title: resp["description"] as? String, message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
                return
            }
            
            self.tabBarController?.dismiss(animated: true)
        }
    }
}
