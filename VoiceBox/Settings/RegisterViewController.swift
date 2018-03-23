//
//  RegisterViewController.swift
//  VoiceBox
//
//  Created by Andrew Hale on 3/19/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func register(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) {(user, error) in
            Database.database().reference(withPath: "users/" + user!.uid).setValue(["email": self.emailTextField.text!,
                                                                                    "first_name": self.firstNameTextField.text!,
                                                                                    "last_name": self.lastNameTextField.text!,
                                                                                    "uid": user!.uid,
                                                                                    "username": self.usernameTextField.text!])

            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                ((((self.navigationController?.parent as! TabBarController).viewControllers![2]) as! UINavigationController).viewControllers[0] as! SettingsViewController).loadUserInfo()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
