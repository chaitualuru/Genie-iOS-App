//
//  MobileViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 9/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import VerifyIosSdk
import Firebase

class MobileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var verificationCode: UITextField!
    @IBOutlet var verifyNumber: UILabel!
    @IBOutlet var verify: UIButton!
    @IBOutlet var next: UIButton!
    @IBOutlet var verificationCodeSent: UILabel!
    @IBOutlet var resendVerificationCode: UIButton!
    @IBOutlet var cancelVerification: UIButton!
    @IBOutlet var darkLoadingView: UIView!
    var resendTimer: NSTimer?
    var loadOptionsTimer: NSTimer?
    var canResend = false
    var canCancel = false
    var uid = ""
    var emailAddress = ""
    var password = ""
    var username = ""
    
    var ref: Firebase!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var storedNumber: String!
    var user: FAuthData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        
        self.ref = Firebase(url: "https://getgenie.firebaseio.com/")

        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        

        // Set the textfield delegates ----------------------------------------------------------
        
        self.mobileNumber.delegate = self
        self.verificationCode.delegate = self
        
        // --------------------------------------------------------------------------------------

        
    }
    
    @IBAction func verifyCode(sender: AnyObject) {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        self.activityIndicator.color = UIColor.whiteColor()
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        self.darkLoadingView.hidden = false
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        VerifyClient.checkPinCode(self.verificationCode.text!)
    }
    
    func loadOptions() {
        self.canResend = true
        self.canCancel = true
    }
    
    @IBAction func sendCode(sender: AnyObject) {
        
        // Send sms nexmo -----------------------------------------------------------------------
        
        self.storedNumber = self.mobileNumber.text!
        
        if self.storedNumber.characters.count != 10 {
            let alertController = UIAlertController(title: "", message: "Mobile number must be 10 characters long.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            let usersRef = self.ref.childByAppendingPath("users")
            usersRef.queryOrderedByChild("mobile_number").queryEqualToValue(self.mobileNumber.text).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                    VerifyClient.getVerifiedUser(countryCode: "IN", phoneNumber: self.storedNumber,
                        onVerifyInProgress: {
                            print("Verify in Progress")
                            
                            self.canResend = false
                            self.canCancel = false
                            
                            self.loadOptionsTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "loadOptions", userInfo: nil, repeats: false)
                        },
                        onUserVerified: {
                            self.verifiedMobile()
                        },
                        onError: { (error: VerifyError) in
                            self.activityIndicator.stopAnimating()
                            self.darkLoadingView.hidden = true
                            self.canCancel = true
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            switch error {
                                /** Number is invalid. Either:
                                1. Number is missing or not a real number (in international or local format).
                                2. Cannot route any verification messages to this number.
                                */
                            case VerifyError.INVALID_NUMBER:
                                print("Please check the number and try again.")
                                let alertController = UIAlertController(title: "", message: "Invalid number. Please check the number and try again.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** User must be in pending status to be able to perform a PIN check. */
                            case VerifyError.CANNOT_PERFORM_CHECK:
                                print("Please go back and re-enter your number.")
                                let alertController = UIAlertController(title: "", message: "Cannot perform check. Please re-enter your number.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Missing or invalid PIN code supplied. */
                            case VerifyError.INVALID_PIN_CODE:
                                print("The code is invalid; try again or use resend.")
                                let alertController = UIAlertController(title: "", message: "Invalid code. Try again or use the resend button.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                /** Ongoing verification has failed. A wrong PIN code was provided too many times. */
                            case VerifyError.INVALID_CODE_TOO_MANY_TIMES:
                                print("wrong pin too many times")
                                let alertController = UIAlertController(title: "", message: "Entered the wrong code too many times. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Ongoing verification expired. Need to start verify again. */
                            case VerifyError.USER_EXPIRED:
                                print("Ongoing verification has expired")
                                let alertController = UIAlertController(title: "", message: "The verification has expired. Please enter your number again.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                
                                self.cancel(self)
                                
                                /** Ongoing verification rejected. User blacklisted for verification. */
                            case VerifyError.USER_BLACKLISTED:
                                print("you have been blacklisted, contact customer support")
                                let alertController = UIAlertController(title: "", message: "You have been blacklisted. Please contact customer support.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Throttled. Too many failed requests. */
                            case VerifyError.THROTTLED:
                                print("too many failed requests")
                                let alertController = UIAlertController(title: "", message: "Too many failed requests. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Your account does not have sufficient credit to process this request. */
                            case VerifyError.QUOTA_EXCEEDED:
                                print("quota exceeded")
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /**
                                Invalid Credentials. Either:
                                1. Supplied Application ID may not be listed under your accepted application list.
                                2. Shared secret key is invalid.
                                */
                            case VerifyError.INVALID_CREDENTIALS:
                                print("app id or secret key is invalid")
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** The SDK revision is not supported anymore. */
                            case VerifyError.SDK_REVISION_NOT_SUPPORTED:
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Current iOS OS version is not supported. */
                            case VerifyError.OS_NOT_SUPPORTED:
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Generic internal error, the service might be down for the moment. Please try again later. */
                            case VerifyError.INTERNAL_ERROR:
                                let alertController = UIAlertController(title: "", message: "Service is down. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** This Nexmo Account has been barred from sending messages */
                            case VerifyError.ACCOUNT_BARRED:
                                let alertController = UIAlertController(title: "", message: "Your account is barred. Please contact customer support.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                            default:
                                print("Unknown error. Please contact customer support.")
                            }
                        }
                    )
                    
                    // --------------------------------------------------------------------------------------
                    
                    
                    UIView.transitionWithView(self.next, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                    self.next.hidden = true
                    
                    UIView.transitionWithView(self.verificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                    self.verificationCode.hidden = false
                    
                    UIView.transitionWithView(self.verify, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                    self.verify.hidden = false
                    
                    UIView.transitionWithView(self.mobileNumber, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                    self.mobileNumber.hidden = true
                    
                    UIView.transitionWithView(self.verifyNumber, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                    self.verifyNumber.hidden = true
                    
                    if (self.isViewLoaded() && self.view.window != nil) {
                        UIView.transitionWithView(self.resendVerificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                        self.resendVerificationCode.hidden = false
                        
                        UIView.transitionWithView(self.cancelVerification, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                        self.cancelVerification.hidden = false
                    }
                }
                else {
                    let alertController = UIAlertController(title: "", message: "The specified mobile number is already in use.", preferredStyle: .Alert)
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
            
//            VerifyClient.getUserStatus(countryCode: "IN", number: self.mobileNumber.text!) { status, error in
//                print("Reached here")
//                if let error = error {
//                    print(error)
//                    return
//                }
//                
//                print(status!)
//            }
            
        }
    }
    
    func verifiedMobile() {
        // signing in user ----------------------------------------------------------------------
        
        self.ref.authUser(self.emailAddress, password: self.password) {
            error, authData in
            if error != nil {
                print("Logging in failed after successfully verifying mobile number")
            } else {
                print("Logged verified user in successfully:", authData.uid)
                
                // --------------------------------------------------------------------------------------
                
                
                // storing user details -----------------------------------------------------------------
                
                let uidRef = self.ref.childByAppendingPath("users/" + self.uid)
                
                let newUser = ["first_name": "Name", "last_name": "", "mobile_number": self.mobileNumber.text!, "email_address": self.emailAddress, "username": self.username]
                
                uidRef.setValue(newUser)
                
                self.activityIndicator.stopAnimating()
                self.darkLoadingView.hidden = true
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.presentViewController(MySwipeVC(), animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if self.canCancel {
            self.canCancel = false
            VerifyClient.cancelVerification({error in
                if let error = error {
                    print("could not cancel verificaton request : ", error)
                }
                
                print("cancelled verification request")
                
                UIView.transitionWithView(self.next, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
                self.next.hidden = false
                self.resent()
                
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
                
                if ((self.resendTimer) != nil) {
                    self.resendTimer!.invalidate()
                }
                if ((self.loadOptionsTimer) != nil) {
                    self.loadOptionsTimer!.invalidate()
                }
            })
        } else {
            let alertController = UIAlertController(title: "", message: "Please wait 30 seconds before cancelling.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func resend(sender: AnyObject) {
        if self.canResend {
            self.canResend = false
            self.canCancel = false
            VerifyClient.cancelVerification({error in
                if let error = error {
                    print("could not cancel verificaton request in resend : ", error)
                } else {
                    print("cancelled verification request")
                    VerifyClient.getVerifiedUser(countryCode: "IN", phoneNumber: self.storedNumber,
                        onVerifyInProgress: {
                            print("Verify in Progress")
                        },
                        onUserVerified: {
                            self.verifiedMobile()
                        },
                        onError: { (error: VerifyError) in
                            self.activityIndicator.stopAnimating()
                            self.darkLoadingView.hidden = true
                            self.canCancel = true
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            switch error {
                                /** Number is invalid. Either:
                                1. Number is missing or not a real number (in international or local format).
                                2. Cannot route any verification messages to this number.
                                */
                            case VerifyError.INVALID_NUMBER:
                                print("Please check the number and try again.")
                                let alertController = UIAlertController(title: "", message: "Invalid number. Please check the number and try again.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** User must be in pending status to be able to perform a PIN check. */
                            case VerifyError.CANNOT_PERFORM_CHECK:
                                print("Please go back and re-enter your number.")
                                let alertController = UIAlertController(title: "", message: "Cannot perform check. Please re-enter your number.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Missing or invalid PIN code supplied. */
                            case VerifyError.INVALID_PIN_CODE:
                                print("The code is invalid; try again or use resend.")
                                let alertController = UIAlertController(title: "", message: "Invalid code. Try again or use the resend button.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                /** Ongoing verification has failed. A wrong PIN code was provided too many times. */
                            case VerifyError.INVALID_CODE_TOO_MANY_TIMES:
                                print("wrong pin too many times")
                                let alertController = UIAlertController(title: "", message: "Entered the wrong code too many times. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Ongoing verification expired. Need to start verify again. */
                            case VerifyError.USER_EXPIRED:
                                print("Ongoing verification has expired")
                                let alertController = UIAlertController(title: "", message: "The verification has expired. Please enter your number again.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                
                                self.cancel(self)
                                
                                /** Ongoing verification rejected. User blacklisted for verification. */
                            case VerifyError.USER_BLACKLISTED:
                                print("you have been blacklisted, contact customer support")
                                let alertController = UIAlertController(title: "", message: "You have been blacklisted. Please contact customer support.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Throttled. Too many failed requests. */
                            case VerifyError.THROTTLED:
                                print("too many failed requests")
                                let alertController = UIAlertController(title: "", message: "Too many failed requests. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Your account does not have sufficient credit to process this request. */
                            case VerifyError.QUOTA_EXCEEDED:
                                print("quota exceeded")
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /**
                                Invalid Credentials. Either:
                                1. Supplied Application ID may not be listed under your accepted application list.
                                2. Shared secret key is invalid.
                                */
                            case VerifyError.INVALID_CREDENTIALS:
                                print("app id or secret key is invalid")
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** The SDK revision is not supported anymore. */
                            case VerifyError.SDK_REVISION_NOT_SUPPORTED:
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Current iOS OS version is not supported. */
                            case VerifyError.OS_NOT_SUPPORTED:
                                let alertController = UIAlertController(title: "", message: "Something went wrong. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** Generic internal error, the service might be down for the moment. Please try again later. */
                            case VerifyError.INTERNAL_ERROR:
                                let alertController = UIAlertController(title: "", message: "Service is down. Please try again later.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                                
                                /** This Nexmo Account has been barred from sending messages */
                            case VerifyError.ACCOUNT_BARRED:
                                let alertController = UIAlertController(title: "", message: "Your account is barred. Please contact customer support.", preferredStyle: .Alert)
                                
                                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                
                                alertController.addAction(okAction)
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                self.cancel(self)
                            default:
                                print("Unknown error. Please contact customer support.")
                            }
                        }
                    )
                }
            })
            
            
            UIView.transitionWithView(self.resendVerificationCode, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.resendVerificationCode.hidden = true
            
            UIView.transitionWithView(self.verificationCodeSent, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.verificationCodeSent.hidden = false
            
            resendTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "resent", userInfo: nil, repeats: false)
        } else {
            let alertController = UIAlertController(title: "", message: "Please wait 30 seconds before requesting a resend.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func resent() {
    
        if (self.isViewLoaded() && self.view.window != nil) {
            UIView.transitionWithView(self.resendVerificationCode, duration: 1.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            self.resendVerificationCode.hidden = false
            self.canCancel = true
        }
        
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
