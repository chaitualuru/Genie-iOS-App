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

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet weak var darkLoadingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var activeField: UITextField?
    var ref: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Firebase(url:"https://getgenie.firebaseio.com/")
        
        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHidden:"), name:UIKeyboardWillHideNotification, object: nil);
        
        // --------------------------------------------------------------------------------------
        
        
        // Set the textfield delegates ----------------------------------------------------------
        
        self.password.delegate = self
        self.emailAddress.delegate = self
        self.username.delegate = self
        
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
    
        
        // Handling Navigation Bar --------------------------------------------------------------
        
        let navItem = UINavigationItem(title: "Sign Up")
        self.navBar.pushNavigationItem(navItem, animated: true)
        if let navFont = UIFont(name: "SFUIDisplay-Medium", size: 17.0) {
            let attributes: [String:AnyObject]? = [
                // 18 146 216
                NSForegroundColorAttributeName: UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 1.0),
                NSFontAttributeName: navFont
            ]
            self.navBar.titleTextAttributes = attributes
        }
        
        navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel.png"), landscapeImagePhone: UIImage(named: "cancel.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "cancelRegister:")
        self.navBar.tintColor = UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 1.0)
        
        // --------------------------------------------------------------------------------------
    
    }
    
    @IBAction func register(sender: UIButton) {
        
        // form validation ----------------------------------------------------------------------
        
        if emailAddress.text == "" || password.text == "" || username.text == "" {
            let alertController = UIAlertController(title: "", message: "All fields are required.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
        else if password.text?.characters.count < 5 {
            let alertController = UIAlertController(title: "", message: "The password must be at least 5 characters long.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else if username.text?.characters.count < 4 {
            let alertController = UIAlertController(title: "", message: "The username must be at least 4 characters long.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
            
        // --------------------------------------------------------------------------------------
          
            
        // registering user ---------------------------------------------------------------------
            
        else {
            
            self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.darkLoadingView.hidden = false
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.activityIndicator.color = UIColor.whiteColor()
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()

            let usersRef = self.ref.childByAppendingPath("users")
            usersRef.queryOrderedByChild("username").queryEqualToValue(self.username.text).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                    self.ref.createUser(self.emailAddress.text!, password: self.password.text!,
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
                                let uid = result["uid"] as! String?
                                print("Successfully created user with uid:" + uid!)
                                // --------------------------------------------------------------------------------------
                                
                                
                                // signing in user ----------------------------------------------------------------------
                                
                                self.ref.authUser(self.emailAddress.text, password: self.password.text) {
                                    error, authData in
                                    if error != nil {
                                        print("Logging in failed after successfully registering")
                                    } else {
                                        print("Logged registered user in successfully:", authData.uid)
                                        
                                        // --------------------------------------------------------------------------------------
                                        
                                        
                                        // storing user details -----------------------------------------------------------------
                                        
                                        let uidRef = self.ref.childByAppendingPath("users/" + uid!)
                                        
                                        let newUser = ["first_name": "Name", "last_name": "", "mobile_number": "Mobile Number", "email_address": self.emailAddress.text!, "username": self.username.text!]
                                        
                                        uidRef.setValue(newUser)
                                        self.performSegueWithIdentifier("VERIFY", sender: result)
                                    }
                                }
                            }
                            
                            // --------------------------------------------------------------------------------------
                            
                            self.darkLoadingView.hidden = true
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    })
                }
                else {
                    let alertController = UIAlertController(title: "", message: "The specified username is already in use.", preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alertController.addAction(okAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    self.darkLoadingView.hidden = true
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
                
                }, withCancelBlock: { error in
                    print(error.description)
            })
        }
    }
    
    
    func cancelRegister(sender: UIBarButtonItem) {
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
    
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
        })
        
        if let activeField = self.activeField {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardFrame.size.height
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWasHidden(notification: NSNotification) {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
        
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
    }
    
    
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
