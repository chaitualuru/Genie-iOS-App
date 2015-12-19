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
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var darkLoadingView: UIView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var ref: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Firebase(url:"https://getgenie.firebaseio.com/")
        
        // Handling Navigation Bar --------------------------------------------------------------
        
        let navItem = UINavigationItem(title: "Sign In")
        self.navBar.pushNavigationItem(navItem, animated: true)
        if let navFont = UIFont(name: "SFUIDisplay-Medium", size: 17.0) {
            let attributes: [String:AnyObject]? = [
                // 18 146 216
                NSForegroundColorAttributeName: UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 1.0),
                NSFontAttributeName: navFont
            ]
            self.navBar.titleTextAttributes = attributes
        }
        
        navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel.png"), landscapeImagePhone: UIImage(named: "cancel.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "cancelSignIn:")
        self.navBar.tintColor = UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 1.0)
        
        // --------------------------------------------------------------------------------------
        

        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasHidden:"), name:UIKeyboardWillHideNotification, object: nil);
        
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
            
            self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.darkLoadingView.hidden = false
            self.view.addSubview(activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
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
                    self.presentViewController(MySwipeVC(), animated: true, completion: nil)
                }
                
                self.darkLoadingView.hidden = true
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
            
            // --------------------------------------------------------------------------------------
            
        }
    }

    func cancelSignIn(sender: UIBarButtonItem) {
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
    }
    
    func keyboardWasHidden(notification: NSNotification) {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.bottomConstraint.constant = 0
        })
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
