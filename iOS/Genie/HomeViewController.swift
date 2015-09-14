//
//  HomeViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/25/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import Firebase
import VerifyIosSdk

class HomeViewController: JSQMessagesViewController {
    
    var user: FAuthData?
    var ref: Firebase!
    var mobileNumber: String!
    var messagesRef: Firebase!
    var getMessagesHandle: UInt!
    var messages = [Message]()
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0))
    
    var pizzaThing: UILabel!
    var twoThing: UILabel!
    var threeThing: UILabel!
    var helperFoot: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        self.user = self.ref.authData
        self.senderId = self.user?.uid
        self.senderDisplayName = "NotSet"
        let firstNameRef = ref.childByAppendingPath("users/" + senderId + "/first_name")
        firstNameRef.observeEventType(.Value, withBlock: { snapshot in
            self.senderDisplayName = snapshot.value as! String
            }, withCancelBlock: { error in
                print(error.description)
        })
        let mobileNumberRef = ref.childByAppendingPath("users/" + senderId + "/mobile_number")
        mobileNumberRef.observeEventType(.Value, withBlock: { snapshot in
            self.mobileNumber = snapshot.value as! String
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        
        // Setting up Input Bar -----------------------------------------------------------------
        
        inputToolbar!.contentView!.leftBarButtonItem = nil
        inputToolbar?.contentView?.backgroundColor = UIColor.whiteColor()
        inputToolbar!.contentView?.textView?.layer.borderWidth = 0
        inputToolbar!.contentView?.textView?.placeHolder = "Type a message"
        inputToolbar!.contentView?.textView?.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        inputToolbar!.contentView?.rightBarButtonItem?.setTitle("", forState: UIControlState.Normal)
        let sendImage = UIImage(named: "lamp.png")
        let sendButton: UIButton = UIButton(type: UIButtonType.Custom)
        sendButton.setImage(sendImage, forState: UIControlState.Normal)
        inputToolbar!.contentView?.rightBarButtonItem? = sendButton
        automaticallyScrollsToMostRecentMessage = true
        
        // --------------------------------------------------------------------------------------
        
        
        // Helper Labels ------------------------------------------------------------------------
        
        self.pizzaThing = UILabel()
        self.pizzaThing.translatesAutoresizingMaskIntoConstraints = false
        self.pizzaThing.numberOfLines = 0
        self.pizzaThing.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.pizzaThing.textAlignment = NSTextAlignment.Center
        self.pizzaThing.textColor = UIColor.lightGrayColor()
        self.pizzaThing.text = "Can you order me some pizza?"
        self.pizzaThing.sizeToFit()
        self.view.addSubview(pizzaThing)
        let pizzaThingxCenterConstraint = NSLayoutConstraint(item: self.pizzaThing, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let pizzaThingyCenterConstraint = NSLayoutConstraint(item: self.pizzaThing, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
        let pizzaThingWidthConstraint = NSLayoutConstraint(item: self.pizzaThing, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.pizzaThing.frame.width)
        let pizzaThingHeightConstraint = NSLayoutConstraint(item: self.pizzaThing, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.pizzaThing.frame.height)
        self.view.addConstraints([pizzaThingHeightConstraint, pizzaThingWidthConstraint, pizzaThingxCenterConstraint, pizzaThingyCenterConstraint])
        self.view.insertSubview(self.pizzaThing, belowSubview: (inputToolbar)!)
        
        self.twoThing = UILabel()
        self.twoThing.translatesAutoresizingMaskIntoConstraints = false
        self.twoThing.numberOfLines = 0
        self.twoThing.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.twoThing.textAlignment = NSTextAlignment.Center
        self.twoThing.textColor = UIColor.lightGrayColor()
        self.twoThing.text = "Two thing"
        self.twoThing.sizeToFit()
        self.view.addSubview(self.twoThing)
        let twoThingxCenterConstraint = NSLayoutConstraint(item: self.twoThing, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let twoThingWidthConstraint = NSLayoutConstraint(item: self.twoThing, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.twoThing.frame.width)
        let twoThingHeightConstraint = NSLayoutConstraint(item: self.twoThing, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.twoThing.frame.height)
        let twoThingyConstraint = NSLayoutConstraint(item: self.twoThing, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.pizzaThing, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -10)
        self.view.addConstraints([twoThingxCenterConstraint, twoThingyConstraint, twoThingHeightConstraint, twoThingWidthConstraint])
        self.view.insertSubview(self.twoThing, belowSubview: (inputToolbar)!)
        
        self.threeThing = UILabel()
        self.threeThing.translatesAutoresizingMaskIntoConstraints = false
        self.threeThing.numberOfLines = 0
        self.threeThing.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.threeThing.textAlignment = NSTextAlignment.Center
        self.threeThing.textColor = UIColor.lightGrayColor()
        self.threeThing.text = "Three thing"
        self.threeThing.sizeToFit()
        self.view.addSubview(self.threeThing)
        let threeThingxCenterConstraint = NSLayoutConstraint(item: self.threeThing, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let threeThingWidthConstraint = NSLayoutConstraint(item: self.threeThing, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.threeThing.frame.width)
        let threeThingHeightConstraint = NSLayoutConstraint(item: self.threeThing, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.threeThing.frame.height)
        let threeThingyConstraint = NSLayoutConstraint(item: self.threeThing, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.pizzaThing, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10)
        self.view.addConstraints([threeThingxCenterConstraint, threeThingyConstraint, threeThingHeightConstraint, threeThingWidthConstraint])
        self.view.insertSubview(self.threeThing, belowSubview: (inputToolbar)!)
        
        self.helperFoot = UILabel()
        self.helperFoot.translatesAutoresizingMaskIntoConstraints = false
        self.helperFoot.numberOfLines = 0
        self.helperFoot.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.helperFoot.font = UIFont(name: "SFUIText-Medium", size: 15.5)
        self.helperFoot.textAlignment = NSTextAlignment.Center
        let mainString = "Find more here!"
        let stringHighlight = "here"
        let stringNormal = "Find more "
        let stringExc = "!"
        let rangeHighlight = (mainString as NSString).rangeOfString(stringHighlight)
        let rangeNormal = (mainString as NSString).rangeOfString(stringNormal)
        let rangeExc = (mainString as NSString).rangeOfString(stringExc)
        let attributedString = NSMutableAttributedString(string:mainString)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0), range: rangeNormal)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0), range: rangeExc)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 27/255.0, green: 165/255.0, blue: 221/255.0, alpha: 1.0), range: rangeHighlight)
        self.helperFoot.attributedText = attributedString
        self.helperFoot.sizeToFit()
        self.helperFoot.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.view.addSubview(self.helperFoot)
        let helperFootxCenterConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let helperFootWidthConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:250)
        let helperFootyConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.pizzaThing, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 40)
        self.view.addConstraints([helperFootxCenterConstraint, helperFootWidthConstraint, helperFootyConstraint])
        self.view.insertSubview(self.helperFoot, belowSubview: (inputToolbar)!)

        helperFoot.hidden = true
        pizzaThing.hidden = true
        twoThing.hidden = true
        threeThing.hidden = true
        
        // --------------------------------------------------------------------------------------
        

        // Handling Navigation Bar --------------------------------------------------------------
        
        self.title = "Genie"
        if let navFont = UIFont(name: "SFUIDisplay-Regular", size: 20.0) {
            let attributes: [String:AnyObject]? = [
                NSForegroundColorAttributeName: UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0),
                NSFontAttributeName: navFont
            ]
            self.navigationController?.navigationBar.titleTextAttributes = attributes
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), landscapeImagePhone: UIImage(named: "menu.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0)
        
        // --------------------------------------------------------------------------------------
        
        
        // Removing avatars ---------------------------------------------------------------------
        
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        // --------------------------------------------------------------------------------------
        
        
        // Adding delete action -----------------------------------------------------------------
        
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem(title: "Delete", action: "deleteMessage:")]
        JSQMessagesCollectionViewCell.registerMenuAction("deleteMessage:")
        
        // --------------------------------------------------------------------------------------
        
        
        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        
        setupFirebase()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Bubble springiness factor ------------------------------------------------------------
        
        collectionView!.collectionViewLayout.springinessEnabled = true
        collectionView!.collectionViewLayout.springResistanceFactor = 1000
        
        // --------------------------------------------------------------------------------------
    }


    func setupFirebase() {
        self.messagesRef = ref.childByAppendingPath("messages/" + self.senderId)
        
        if self.messages.count == 0 {
            self.pizzaThing.hidden = false
            self.twoThing.hidden = false
            self.threeThing.hidden = false
            self.helperFoot.hidden = false
        }

        self.getMessagesHandle = self.messagesRef.queryLimitedToLast(50).observeEventType(FEventType.ChildAdded, withBlock: {
            (snapshot) in
            let messageId = snapshot.key
            let text = snapshot.value["text"] as? String
            let timestamp = snapshot.value["timestamp"] as? NSTimeInterval
            let date = NSDate(timeIntervalSince1970: timestamp!/1000)
            let sentByUser = snapshot.value["sentByUser"] as? Bool
            var sender = "notUser"
            if sentByUser != true {
                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
            }
            else {
                sender = self.senderId
            }
            let message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date)
            
            self.messages.append(message)
            
            self.pizzaThing.hidden = true
            self.twoThing.hidden = true
            self.threeThing.hidden = true
            self.helperFoot.hidden = true
            
            self.finishReceivingMessage()
        })
    }

    func sendMessage(text: String!) {
        self.messagesRef.childByAutoId().setValue([
            "text": text,
            "timestamp": FirebaseServerValue.timestamp(),
            "sentByUser": true
            ])
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text)
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        
        if message.sentByUser() == true {
            return self.outgoingBubble
        }
        
        return self.incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return 20.0
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 5.0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sentByUser() == true {
            cell.textView!.textColor = UIColor.whiteColor()
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        } else {
            cell.textView!.textColor = UIColor.blackColor()
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        }

        return cell
    }
    
    // Delete action ----------------------------------------------------------------------
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "deleteMessage:" {
            return true
        }
        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == "deleteMessage:" {
            deleteMessage(collectionView, indexPath: indexPath)
        }
        super.collectionView(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    func deleteMessage(collectionView: UICollectionView, indexPath: NSIndexPath) {
        let messageKey = self.messages[indexPath.item].messageId()
        let removeMessageRef = self.messagesRef.childByAppendingPath("/" + messageKey)
        removeMessageRef.removeValue()
        self.messages.removeAtIndex(indexPath.item)
        collectionView.deleteItemsAtIndexPaths([indexPath])
        if self.messages.count == 0 {
            self.pizzaThing.hidden = false
            self.twoThing.hidden = false
            self.threeThing.hidden = false
            self.helperFoot.hidden = false
        }
    }
    
    // --------------------------------------------------------------------------------------
    
    func logout(sender: UIBarButtonItem) {
        ref.removeObserverWithHandle(getMessagesHandle)
        ref.unauth()
        print("logged out user:", ref.authData)
        performSegueWithIdentifier("LOGOUT", sender: self)
        
        VerifyClient.logoutUser(countryCode: "US", number: self.mobileNumber, completionBlock: { error in
            if let error = error {
                // unable to logout user
                print("could not logout nexmo : ", error)
            }
            
            print("logged out nexmo user")
        })
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
