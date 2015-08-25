//
//  RegisterViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/24/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var mobileNumber: UITextField!
    
    var ref = Firebase(url:"https://getgenie.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        
        
        // Set the textfield delegates ----------------------------------------------------------
        
        self.firstName.delegate = self
        self.password.delegate = self
        self.lastName.delegate = self
        self.emailAddress.delegate = self
        self.mobileNumber.delegate = self
        
        // --------------------------------------------------------------------------------------
        
        
        // Display all fonts --------------------------------------------------------------------
        /*
        for family: String in UIFont.familyNames()
        {
            print("\(family)")
            for names: String in UIFont.fontNamesForFamilyName(family)
            {
                print("== \(names)")
            }
        }
        */
        // --------------------------------------------------------------------------------------
    
        
        // Setting title attributes -------------------------------------------------------------
        /*
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 27, green: 165, blue: 221, alpha: 1.0),
            NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 20)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        */
        // --------------------------------------------------------------------------------------
    
    }
    
    @IBAction func register(sender: UIButton) {
        
        if firstName.text == "" || lastName.text == "" || emailAddress.text == "" || password.text == "" || mobileNumber.text == "" {
            let alertController = UIAlertController(title: "", message: "All fields are required.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
        else {
            self.ref.createUser(emailAddress.text!, password: password.text!,
                withValueCompletionBlock: { error, result in
                    if error != nil {
                        if let errorCode = FAuthenticationError(rawValue: error.code) {
                            switch (errorCode) {
                            case .EmailTaken:
                                let alertController = UIAlertController(title: "", message: "The specified email address is already in use.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            case .InvalidEmail:
                                let alertController = UIAlertController(title: "", message: "The specified email address is invalid.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            default:
                                print("Error creating user:", error)
                            }
                        }
                    } else {
                        let uid = result["uid"] as? String
                        print("Successfully created user account with uid: \(uid)")
                        
                        let usersRef = self.ref.childByAppendingPath("users")
                        
                        let uidRef = usersRef.childByAppendingPath(uid)
                        
                        let newUser = ["first_name": self.firstName.text!, "last_name": self.lastName.text!, "mobile_number": self.mobileNumber.text!, "email_address": self.emailAddress.text!]
                        
                        uidRef.setValue(newUser)
                    }
            })

        }
        
    }
    
    
    @IBAction func cancelRegister(sender: UIBarButtonItem) {
        if firstName.text == "" && lastName.text == "" && emailAddress.text == "" && password.text == "" && mobileNumber.text == "" {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "", message: "Are you sure you want to cancel? Your information will not be saved", preferredStyle: .Alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
            
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
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
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
