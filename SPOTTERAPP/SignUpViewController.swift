//
//  SignUpViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 5/6/2023.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var postCode: UITextField!
    @IBOutlet weak var reEnterPassword: UITextField!
    
    //declare Firestore reference
    var firestoreRef: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialise the Firestore reference
        firestoreRef = Firestore.firestore()
        
        //set password textfields to secure entry
        password.isSecureTextEntry = true
        reEnterPassword.isSecureTextEntry = true
    }

    @IBAction func signUpTapped(_ sender: Any) {
        if firstName.text?.isEmpty ?? true ||
           lastName.text?.isEmpty ?? true ||
           postCode.text?.isEmpty ?? true ||
           email.text?.isEmpty ?? true ||
           password.text?.isEmpty ?? true ||
           reEnterPassword.text?.isEmpty ?? true {
            
            showAlert(message: "All fields are required")
            return
        }
        
        if let postCodeText = postCode.text, postCodeText.count != 4 || !postCodeText.allSatisfy({ $0.isNumber }) {
            showAlert(message: "Post code must be exactly 4 digits")
            return
        }

        if let emailText = email.text, !isValidEmail(emailText) {
            showAlert(message: "Invalid email address")
            return
        }

        if let passwordText = password.text, passwordText.count < 8 {
            showAlert(message: "Password must be 8 characters or longer")
            return
        }

        if password.text != reEnterPassword.text {
            showAlert(message: "Passwords do not match")
            return
        }

        signUp()
    }

    //when user presses login
    @IBAction func loginTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    //sign up method
    func signUp() {
        guard let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty,
              let firstName = firstName.text, !firstName.isEmpty,
              let lastName = lastName.text, !lastName.isEmpty,
              let postCode = postCode.text, !postCode.isEmpty
        else {
            showAlert(message: "All fields are required")
            return
        }

        if !isValidEmail(email) {
            showAlert(message: "Invalid email address")
            return
        }

        if password.count < 8 {
            showAlert(message: "Password must be 8 characters or longer")
            return
        }

        if password != reEnterPassword.text {
            showAlert(message: "Passwords do not match")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }

            if let error = error {
                print("Error: \(error.localizedDescription)")
                strongSelf.showAlert(message: error.localizedDescription)
                return
            }

            //successful signup
            strongSelf.saveUserData(firstName: firstName, lastName: lastName, postCode: postCode, email: email)
            strongSelf.showSignupSuccessAlert()
            strongSelf.navigateToMainHome()
        }
    }


    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    //check email format
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    //save user data to Firestore
    func saveUserData(firstName: String, lastName: String, postCode: String, email: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }
        
        let db = Firestore.firestore()
        
        let userData = [
            "firstName": firstName,
            "lastName": lastName,
            "postCode": postCode,
            "email": email
        ]
        
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Failed to save user data: \(error)")
            } else {
                print("User data saved successfully")
            }
        }
    }
    
    
    func showSignupSuccessAlert() {
        let alert = UIAlertController(title: "Successful Signup", message: "Welcome!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }

    
    func navigateToMainHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainHomeVC = storyboard.instantiateViewController(withIdentifier: "mainHome")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        //set main home view controller as the root view controller
        sceneDelegate.window?.rootViewController = mainHomeVC
    }
}
