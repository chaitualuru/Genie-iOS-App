//
//  ProfileViewController.swift
//  Genie
//
//  Created by Vamsee Chamakura on 11/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImgTop: NSLayoutConstraint!
    
    var user: FAuthData?
    var ref: Firebase!
    var mobileNumber: String!
    var senderDisplayName: String!
    var emailAddress: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        
        self.user = self.ref.authData
        
        let firstNameRef = ref.childByAppendingPath("users/" + (self.user?.uid)!)
        firstNameRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.senderDisplayName = (snapshot.value.objectForKey("first_name") as! String) + " " + (snapshot.value.objectForKey("last_name") as! String)
            self.mobileNumber = snapshot.value.objectForKey("mobile_number") as! String
            self.emailAddress = snapshot.value.objectForKey("email_address") as! String
            self.userName.text = self.senderDisplayName
            self.userMobile.text = "   " + self.mobileNumber
            self.userEmail.text = "   " + self.emailAddress
            }, withCancelBlock: { error in
                print(error.description)
        })

        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // --------------------------------------------------------------------------------------
        
        topViewHeight.constant = 0.4 * UIScreen.mainScreen().bounds.height
        profileImgTop.constant = 0.3 * 0.4 * UIScreen.mainScreen().bounds.height

        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width / 2;
        self.profileImg.layer.borderWidth = 3.0
        self.profileImg.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImg.clipsToBounds = true;
        
        let purple = UIColor(red: 79/255, green: 67/255, blue: 135/255, alpha: 1)
        
        userMobile.layer.addBorder(UIRectEdge.Bottom, color: purple, thickness: 0.5)
        userEmail.layer.addBorder(UIRectEdge.Bottom, color: purple, thickness: 0.5)
        
    }
    @IBAction func closeProfileVC(sender: UIButton) {
        let new_number = self.userMobile.text
        let new_email = self.userEmail.text
        
        let full_name = self.userName.text!.componentsSeparatedByString(" ")
        
        let userRef = ref.childByAppendingPath("users/" + (self.user?.uid)!)

        userRef.updateChildValues([
            "email_address": new_email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
            "mobile_number": new_number!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
            "first_name": full_name[0],
            "last_name": full_name[1]
            ])
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, CGRectGetHeight(self.frame), thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, UIScreen.mainScreen().bounds.width, thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        border.backgroundColor = color.CGColor;
        
        self.addSublayer(border)
    }
    
}
