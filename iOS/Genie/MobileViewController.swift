//
//  MobileViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 9/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class MobileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var verificationCode: UITextField!
    @IBOutlet var verifyNumber: UILabel!
    @IBOutlet var enterVerificationCode: UILabel!
    @IBOutlet var verify: UIButton!
    @IBOutlet var next: UIButton!
    @IBOutlet var verificationCodeSent: UILabel!
    @IBOutlet var resendVerificationCode: UIButton!
    
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
