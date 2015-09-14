//
//  MobileViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 9/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import VerifyIosSdk

class MobileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var verificationCode: UITextField!
    @IBOutlet var verifyNumber: UILabel!
    @IBOutlet var enterVerificationCode: UILabel!
    @IBOutlet var verify: UIButton!
    @IBOutlet var next: UIButton!
    @IBOutlet var verificationCodeSent: UILabel!
    @IBOutlet var resendVerificationCode: UIButton!
    @IBOutlet var cancelVerification: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var storedNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        

        // Set the textfield delegates ----------------------------------------------------------
        
        self.mobileNumber.delegate = self
        self.verificationCode.delegate = self
        
        // --------------------------------------------------------------------------------------

        
    }
    
    @IBAction func sendCode(sender: AnyObject) {
        
        // Send sms nexmo -----------------------------------------------------------------------
        
        self.storedNumber = self.mobileNumber.text!
        
        VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: self.storedNumber,
            onVerifyInProgress: {
                print("Verify in Progress")
            },
            onUserVerified: {
                self.verifiedMobile()
            },
            onError: { (error: VerifyError) in
                print("there was an error verifying user")
            }
        )

        // --------------------------------------------------------------------------------------
        
        
        UIView.transitionWithView(self.next, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.next.hidden = true
        
        UIView.transitionWithView(self.cancelVerification, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.cancelVerification.hidden = false
        
        UIView.transitionWithView(self.verificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.verificationCode.hidden = false
        
        UIView.transitionWithView(self.verify, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.verify.hidden = false
        
        UIView.transitionWithView(self.resendVerificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.resendVerificationCode.hidden = false
        
        UIView.transitionWithView(self.mobileNumber, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.mobileNumber.hidden = true
        
        UIView.transitionWithView(self.verifyNumber, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.verifyNumber.hidden = true
        
        UIView.transitionWithView(self.enterVerificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.enterVerificationCode.hidden = false
        
    }
    
    func verifiedMobile() {
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        performSegueWithIdentifier("VERIFIED", sender: self)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        VerifyClient.cancelVerification({error in
            if let error = error {
                print("could not cancel verificaton request : ", error)
            }
            
            print("cancelled verification request")
            
            UIView.transitionWithView(self.next, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.next.hidden = false
            
            UIView.transitionWithView(self.cancelVerification, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.cancelVerification.hidden = true
            
            UIView.transitionWithView(self.verificationCode, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.verificationCode.hidden = true
            
            UIView.transitionWithView(self.verify, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.verify.hidden = true
            
            UIView.transitionWithView(self.resendVerificationCode, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.resendVerificationCode.hidden = true
            
            UIView.transitionWithView(self.mobileNumber, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.mobileNumber.hidden = false
            
            UIView.transitionWithView(self.verifyNumber, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.verifyNumber.hidden = false
            
            UIView.transitionWithView(self.enterVerificationCode, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.enterVerificationCode.hidden = true
        })
    }
    
    @IBAction func verify(sender: AnyObject) {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        VerifyClient.checkPinCode(self.verificationCode.text!)
    }
    
    @IBAction func resend(sender: AnyObject) {
        
        VerifyClient.cancelVerification({error in
            if let error = error {
                print("could not cancel verificaton request in resend : ", error)
            }
            
            print("cancelled verification request")
        })
        
        VerifyClient.getVerifiedUser(countryCode: "US", phoneNumber: self.storedNumber,
            onVerifyInProgress: {
                print("Verify in Progress")
            },
            onUserVerified: {
                self.verifiedMobile()
            },
            onError: { (error: VerifyError) in
                print("there was an error verifying user")
            }
        )
        
        UIView.transitionWithView(self.resendVerificationCode, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.resendVerificationCode.hidden = true
        
        UIView.transitionWithView(self.verificationCodeSent, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.verificationCodeSent.hidden = false
        
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "resent", userInfo: nil, repeats: false)
        
    }
    
    func resent() {
    
        UIView.transitionWithView(self.resendVerificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.resendVerificationCode.hidden = false
        
        UIView.transitionWithView(self.verificationCodeSent, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        self.verificationCodeSent.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}
