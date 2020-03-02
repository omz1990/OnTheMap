//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 23/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signupTextView: UITextView!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Initialise UI
    override func viewDidLoad() {
        super.viewDidLoad()
        addSignupLink()
    }
    
    // Add the Signup link in the text
    private func addSignupLink() {
    
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign Up")
        let url = URL(string: "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated")!

        attributedString.setAttributes([.link: url], range: NSMakeRange(23, 7))

        self.signupTextView.attributedText = attributedString
        self.signupTextView.isUserInteractionEnabled = true
        self.signupTextView.isEditable = false
        self.signupTextView.font = .systemFont(ofSize: 18.0)
        self.signupTextView.textAlignment = .center

        // Set how links should appear: blue and underlined
        self.signupTextView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    // MARK: UI Listener
    @IBAction func loginClick(_ sender: Any) {
        setLoggingIn(true)
        UdacityClient.login(userName: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    // MARK: Handle API Responses
    private func handleLoginResponse(success: Bool, error: Error?) {
        if (success) {
            // Get user data
            UdacityClient.getUserData(completion: handleGetUserDataResponse(success:error:))
        } else {
            setLoggingIn(false)
            showLoginFailure(message: error?.localizedDescription ?? "Couldn't login")
        }
    }
    
    private func handleGetUserDataResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if (success) {
            // Login complete
            self.performSegue(withIdentifier: "loginComplete", sender: nil)
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "Couldn't fetch your details")
        }
    }
    
    // MARK: Class Utility Functions
    private func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.stopAnimating()
        }
        self.emailTextField?.isEnabled = !loggingIn
        self.passwordTextField?.isEnabled = !loggingIn
        self.loginButton?.isEnabled = !loggingIn
    }
    
    private func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}

