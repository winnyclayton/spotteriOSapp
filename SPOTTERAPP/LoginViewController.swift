//
//  LoginViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 5/6/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //connect fields from UI
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var loggedInEmail: String?
    var loggedInPassword: String?
    var willyWeatherAPI: WillyWeatherAPI? //create an instance of WillyWeatherAPI
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        willyWeatherAPI = WillyWeatherAPI()
        
        password.isSecureTextEntry = true
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        validateLoginFields()
    }
    
    //when user presses sign up button
    @IBAction func signUpTapped(_ sender: Any) {
        validateSignupFields()
    }
    
    //forgot password tapped
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        validateFieldsForPasswordReset()
    }
    
    //password reset fields
    func validateFieldsForPasswordReset() {
        guard let email = email.text, !email.isEmpty else {
            showAlert(message: "Please enter your email")
            print("No email provided")
            return
        }
        
        //password reset send to email that user signed up with
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print("FAILED - \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Please check your email to reset your password")
                print("SENT EMAIL")
            }
        }
    }
    
    //make sure fields arent empty
    func validateLoginFields() {
        guard let email = email.text, !email.isEmpty else {
            self.showAlert(message: "Please enter your email")
            print("No email text")
            return
        }
        
        guard let password = password.text, !password.isEmpty else {
            self.showAlert(message: "Please enter your password")
            print("No password text")
            return
        }
        
        login()
    }
    
    //login steps
    func login() {
        
        guard let email = email.text, let password = password.text else {
            print("No email or password provided")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error as NSError? {
                if error.code == AuthErrorCode.wrongPassword.rawValue {
                    print("Invalid password")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Login Error", message: "Invalid password. Please try again.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                } else {
                    print("Error signing in:", error.localizedDescription)
                    let alert = UIAlertController(title: "Login Error", message: "Invalid email. Please try again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    strongSelf.present(alert, animated: true, completion: nil)
                }
                return
            }
            //store the email and password values
            strongSelf.loggedInEmail = email
            strongSelf.loggedInPassword = password
            strongSelf.checkUserInAuthenticationConsole()
        }
    }


func validateSignupFields(){
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "signUp")
    vc.modalPresentationStyle = .overFullScreen
    present(vc, animated: true)
}

    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    func checkUserInAuthenticationConsole() {
        guard let email = email.text else {
            print("No email provided")
            return
        }
        
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] signInMethods, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error as NSError?, error.code == AuthErrorCode.userNotFound.rawValue {
                print("User does not exist in the authentication console")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Account Error", message: "User does not exist", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    strongSelf.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let error = error {
                print("Error fetching sign-in methods for email:", error.localizedDescription)
                return
            }
            
            if let signInMethods = signInMethods {
                if signInMethods.isEmpty {
                    print("User does not exist in the authentication console")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Account Error", message: "User does not exist", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                } else {
                    print("User exists in the authentication console")
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        
                        //redirect to the mainHome storyboard
                        guard let mainHomeTabBarController = storyboard.instantiateViewController(withIdentifier: "mainHome") as? UITabBarController else {
                            return
                        }
                        
                        //set the mainHomeTabBarController as the root view controller
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let delegate = windowScene.delegate as? SceneDelegate {
                            delegate.window?.rootViewController = mainHomeTabBarController
                        }
                    }

                }
            }
        }
    }
}



