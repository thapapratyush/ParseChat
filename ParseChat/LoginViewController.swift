//
//  LoginViewController.swift
//  ParseChat
//
//  Created by Pratyush Thapa on 2/24/17.
//  Copyright © 2017 Pratyush Thapa. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!

    @IBAction func signUpPressed(_ sender: AnyObject) {
        let user = PFUser()
        user.username = emailTextField.text
        user.password = pwTextField.text
        
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            let message: String = {
                if let error = error {
                    return error.localizedDescription
                } else {
                    return "Success"
                }
            }()
            
            let ac = UIAlertController(title: "Sign Up", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            ac.addAction(okAction)
            self.present(ac, animated: true, completion: nil)
        }
    }

    @IBAction func loginPressed(_ sender: AnyObject) {
        PFUser.logInWithUsername(inBackground: emailTextField.text!, password: pwTextField.text!) { (user: PFUser?, error: Error?) in
            
            if user != nil {
                self.performSegue(withIdentifier: "ChatRoomViewController", sender: nil)
            } else {
                let ac = UIAlertController(title: "Login Failed", message: "Email or Password is Incorrect", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                ac.addAction(okAction)
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}
