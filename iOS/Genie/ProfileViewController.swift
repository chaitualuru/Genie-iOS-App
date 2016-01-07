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

    @IBOutlet weak var whiteViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImg: UIImageView!

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fullName: UILabel!

    @IBOutlet weak var userMobile: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet var navBar: UINavigationBar!

    @IBOutlet weak var profileImgTop: NSLayoutConstraint!
    
    var user: FAuthData?
    var ref: Firebase!
    var mobileNumber: String!
    var senderDisplayName: String!
    var emailAddress: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.whiteViewHeightConstraint.constant = UIScreen.mainScreen().bounds.height * 0.6
        
        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        
        self.user = self.ref.authData
        
        let firstNameRef = ref.childByAppendingPath("users/" + (self.user?.uid)!)
        firstNameRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.senderDisplayName = (snapshot.value.objectForKey("first_name") as! String) + " " + (snapshot.value.objectForKey("last_name") as! String)
            self.mobileNumber = snapshot.value.objectForKey("mobile_number") as! String
            self.emailAddress = snapshot.value.objectForKey("email_address") as! String
            self.fullName.text = self.senderDisplayName
            self.username.text = snapshot.value.objectForKey("username") as? String
            self.userMobile.text = self.mobileNumber
            self.userEmail.text = self.emailAddress
            if snapshot.value["first_name"] as! String != "~|~" {
                self.fullName.hidden = false
            }
            else {
                self.fullName.hidden = true
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        // Handling Navigation Bar --------------------------------------------------------------
        
        let navItem = UINavigationItem(title: "")
        self.navBar.pushNavigationItem(navItem, animated: true)
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navBar.shadowImage = UIImage()


        navItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel.png"), landscapeImagePhone: UIImage(named: "cancel.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "closeProfileVC:")
        self.navBar.barTintColor = UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 1.0)
        
        // --------------------------------------------------------------------------------------

        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
            
        self.profileImgTop.constant = 0.3 * 0.3 * UIScreen.mainScreen().bounds.height
       
        let lineColor = UIColor.lightGrayColor()
        
        userMobile.layer.addBorder(UIRectEdge.Bottom, color: lineColor, thickness: 0.5)
        userEmail.layer.addBorder(UIRectEdge.Bottom, color: lineColor, thickness: 0.5)
        
    }
    @IBAction func signOut(sender: UIButton) {
        self.ref.unauth()
        performSegueWithIdentifier("SIGN_OUT", sender: nil)
        VerifyClient.logoutUser(countryCode: "US", number: self.mobileNumber, completionBlock: { error in
            if let error = error {
                // unable to logout user
                print("could not logout nexmo : ", error)
            }
            
            print("logged out nexmo user")
        })
    }
    
    func closeProfileVC(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
