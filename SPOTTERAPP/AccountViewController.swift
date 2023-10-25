//
//  AccountViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 26/6/2023.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPassword: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check if user is currently signed in
        if let currentUser = Auth.auth().currentUser {
            //get users email
            let email = currentUser.email ?? "No email found"
            lblEmail.text = email
            
            //get users password
            let password = "********"
            lblPassword.text = password
        }
        
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "login")
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
