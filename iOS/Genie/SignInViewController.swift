//
//  SignInViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/24/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    
    var ref: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Firebase(url:"https://getgenie.firebaseio.com/")

        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        
        
        // Set the textfield delegates ----------------------------------------------------------
        
        self.password.delegate = self
        self.emailAddress.delegate = self
        
        // --------------------------------------------------------------------------------------
        
    }
    
    @IBAction func signIn(sender: UIButton) {
        // form validation ----------------------------------------------------------------------
        
        if emailAddress.text == "" && password.text == "" {
            
            let alertController = UIAlertController(title: "", message: "Please enter your email address and password to sign in.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        }
        else if emailAddress.text == "" {
            
            let alertController = UIAlertController(title: "", message: "Please enter your email address to sign in.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        }
        else if password.text == "" {
        
            let alertController = UIAlertController(title: "", message: "Please enter your password to sign in.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        
        }
            
        // --------------------------------------------------------------------------------------
            
        
        // signing in user ----------------------------------------------------------------------
            
        else {
        
            self.ref.authUser(self.emailAddress.text, password: self.password.text) {
                error, authData in
                if error != nil {
                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                        switch (errorCode) {
                        case .InvalidEmail:
                            let alertController = UIAlertController(title: "", message: "The specified email address is invalid.", preferredStyle: .Alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            
                            alertController.addAction(okAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        case .UserDoesNotExist:
                            let alertController = UIAlertController(title: "", message: "The specified email address is not registered.", preferredStyle: .Alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            
                            alertController.addAction(okAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        case .InvalidPassword:
                            let alertController = UIAlertController(title: "", message: "The specified password is incorrect.", preferredStyle: .Alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            
                            alertController.addAction(okAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        default:
                            print("Error creating user:", error)
                        }
                    }
                } else {
                    print("Signed in successfully:", authData.uid)
                    self.performSegueWithIdentifier("SIGN_IN", sender: authData)
                }
            }
            
            // --------------------------------------------------------------------------------------
            
        }
    }

    @IBAction func cancelSignIn(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Dismissing Keyboard ------------------------------------------------------------------
    
    // Dismiss keyboard on pressing the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Dismiss the keyboard when tap is recognized
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // --------------------------------------------------------------------------------------
    
    
    // Orientation fixed to Portrait --------------------------------------------------------
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    // --------------------------------------------------------------------------------------
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
