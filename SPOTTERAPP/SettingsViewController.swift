//
//  SettingsViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 26/6/2023.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem = UITabBarItem(title: "SETTINGS", image: UIImage(named: "spotterHelp"), tag: 2)

    }
    

    @IBAction func sendEmailButtonTapped(_ sender: Any) {
        sendEmail(to: "winnymusic@outlook.com")
    }
    
    
    func sendEmail(to recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients([recipient])

            //set the subject and body of the email
            mailComposeVC.setSubject("Subject")
            mailComposeVC.setMessageBody("Message body", isHTML: false)

            self.present(mailComposeVC, animated: true, completion: nil)
        } else {
            //display an alert indicating that the device cannot send emails
            let alertController = UIAlertController(title: "Cannot Send Email", message: "Your device is not configured to send emails.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func reviewOnAppStoreTapped(_ sender: Any) {
        //please note this is a dummy url and will be invalid - scenario purposes only
            let appStoreURL = URL(string: "https://apps.apple.com/app/spotter-app?action=write-review")!

            if UIApplication.shared.canOpenURL(appStoreURL) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                   }
               }
}
