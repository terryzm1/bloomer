//
//  LoginViewController.swift
//  ZhangTianyu-HW5
//
//  Created by Terry Zhang on 10/23/24.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController, UITextFieldDelegate {



    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var confirmPassTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        status.text = ""
        confirmPassTextField.isHidden = true
        submit.setTitle("Log in", for: .normal)
        passwordTextField.delegate = self
        emailTextField.delegate = self
        confirmPassTextField.delegate = self
        
    }
    

    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            confirmPassTextField.isHidden = true
            submit.setTitle("Log in", for: .normal)
        }
        else {
            confirmPassTextField.isHidden = false
            submit.setTitle("Sign up", for: .normal)
        }
    }
    
    @IBAction func buttonClicked(_ sender: Any) {

        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.status.text = "One or more fields empty. Try again."
            self.dismiss(animated: true)
            return
        }

        if segmentedControl.selectedSegmentIndex == 0 {
            
            // Login
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.status.text = "Error logging in"
                    // Show an alert for login error
                } else {
                    print("User logged in: \(authResult?.user.email ?? "")")
                    self.performSegue(withIdentifier: "toMainView", sender: self)
                    // Navigate to the main screen or update UI for login success
                }
            }
        } else {
            guard let confirmPass = confirmPassTextField.text, !confirmPass.isEmpty, confirmPass == password else {
                self.status.text = "Passwords do not match. Try again."
                return
            }
            // Sign Up
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.status.text = "Error signing up"
                    // Show an alert for sign-up error
                } else {
                    print("User signed up: \(authResult?.user.email ?? "")")
                    self.performSegue(withIdentifier: "toMainView", sender: self)
                    // Navigate to the main screen or update UI for sign-up success
                }
            }
        }
    }
}
