//
//  PushNotificationsViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 15/8/2023.
//

import UIKit
import CoreLocation

class PushNotificationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func signUpPremiumTapped(_ sender: Any) {
        
        //please note this is a dummy url and will be invalid - scenario purposes only
        let appStoreURL = URL(string: "https://apps.apple.com/app/spotter-app")!
        
        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
        
    }
}

