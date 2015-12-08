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
    var messagesRef: Firebase!
    
    var messages = [Message]()
    var mobileNumber: String!
    
    var getMessagesHandle: UInt!
    
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0))
    
    var pizzaHelp: UILabel!
    var furnitureHelp: UILabel!
    var ticketHelp: UILabel!
    var helperFoot: UILabel!
    var firstMessageRead: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstMessageRead = true
        
        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        
        self.user = self.ref.authData
        self.senderId = self.user?.uid
        self.senderDisplayName = "not_set"
        
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
        
        if let toolbar = inputToolbar {
            if let conview = toolbar.contentView {
//                conview.leftBarButtonItem = nil
                conview.backgroundColor = UIColor.whiteColor()
                if let texview = conview.textView {
                    texview.layer.borderWidth = 0
                    texview.placeHolder = "Type a message"
                    texview.font = UIFont(name: "SFUIText-Regular", size: 15.0)
                }
                if let rightbarbutton = conview.rightBarButtonItem {
                    rightbarbutton.setTitle("", forState: UIControlState.Normal)
                }
                let sendImage = UIImage(named: "lamp.png")
                let sendButton: UIButton = UIButton(type: UIButtonType.Custom)
                sendButton.setImage(sendImage, forState: UIControlState.Normal)
                conview.rightBarButtonItem = sendButton
            }
        }
        
//        inputToolbar!.contentView!.leftBarButtonItem = nil
//        inputToolbar?.contentView?.backgroundColor = UIColor.whiteColor()
//        inputToolbar!.contentView?.textView?.layer.borderWidth = 0
//        inputToolbar!.contentView?.textView?.placeHolder = "Type a message"
//        inputToolbar!.contentView?.textView?.font = UIFont(name: "SFUIText-Regular", size: 15.0)
//        inputToolbar!.contentView?.rightBarButtonItem?.setTitle("", forState: UIControlState.Normal)
//        let sendImage = UIImage(named: "lamp.png")
//        let sendButton: UIButton = UIButton(type: UIButtonType.Custom)
//        sendButton.setImage(sendImage, forState: UIControlState.Normal)
//        inputToolbar!.contentView?.rightBarButtonItem? = sendButton
        
        automaticallyScrollsToMostRecentMessage = true
        
        // --------------------------------------------------------------------------------------
        
        
        // Helper Labels ------------------------------------------------------------------------
        
        self.pizzaHelp = UILabel()
        self.pizzaHelp.translatesAutoresizingMaskIntoConstraints = false
        self.pizzaHelp.numberOfLines = 0
        self.pizzaHelp.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.pizzaHelp.textAlignment = NSTextAlignment.Center
        self.pizzaHelp.textColor = UIColor.lightGrayColor()
        self.pizzaHelp.text = "Can you order me some pizza?"
        self.pizzaHelp.sizeToFit()
        self.view.addSubview(pizzaHelp)
        let pizzaHelpxCenterConstraint = NSLayoutConstraint(item: self.pizzaHelp, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let pizzaHelpyCenterConstraint = NSLayoutConstraint(item: self.pizzaHelp, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
        let pizzaHelpWidthConstraint = NSLayoutConstraint(item: self.pizzaHelp, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.pizzaHelp.frame.width)
        let pizzaHelpHeightConstraint = NSLayoutConstraint(item: self.pizzaHelp, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.pizzaHelp.frame.height)
        self.view.addConstraints([pizzaHelpHeightConstraint, pizzaHelpWidthConstraint, pizzaHelpxCenterConstraint, pizzaHelpyCenterConstraint])
        self.view.insertSubview(self.pizzaHelp, belowSubview: (inputToolbar)!)
        
        self.furnitureHelp = UILabel()
        self.furnitureHelp.translatesAutoresizingMaskIntoConstraints = false
        self.furnitureHelp.numberOfLines = 0
        self.furnitureHelp.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.furnitureHelp.textAlignment = NSTextAlignment.Center
        self.furnitureHelp.textColor = UIColor.lightGrayColor()
        self.furnitureHelp.text = "Where can I find furniture for my house?"
        self.furnitureHelp.sizeToFit()
        self.view.addSubview(self.furnitureHelp)
        let furnitureHelpxCenterConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let furnitureHelpWidthConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.furnitureHelp.frame.width)
        let furnitureHelpHeightConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.furnitureHelp.frame.height)
        let furnitureHelpyConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.pizzaHelp, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -10)
        self.view.addConstraints([furnitureHelpxCenterConstraint, furnitureHelpyConstraint, furnitureHelpHeightConstraint, furnitureHelpWidthConstraint])
        self.view.insertSubview(self.furnitureHelp, belowSubview: (inputToolbar)!)
        
        self.ticketHelp = UILabel()
        self.ticketHelp.translatesAutoresizingMaskIntoConstraints = false
        self.ticketHelp.numberOfLines = 0
        self.ticketHelp.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.ticketHelp.textAlignment = NSTextAlignment.Center
        self.ticketHelp.textColor = UIColor.lightGrayColor()
        self.ticketHelp.text = "I would like to book movie tickets!"
        self.ticketHelp.sizeToFit()
        self.view.addSubview(self.ticketHelp)
        let ticketHelpxCenterConstraint = NSLayoutConstraint(item: self.ticketHelp, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let ticketHelpWidthConstraint = NSLayoutConstraint(item: self.ticketHelp, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.ticketHelp.frame.width)
        let ticketHelpHeightConstraint = NSLayoutConstraint(item: self.ticketHelp, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.ticketHelp.frame.height)
        let ticketHelpyConstraint = NSLayoutConstraint(item: self.ticketHelp, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.pizzaHelp, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10)
        self.view.addConstraints([ticketHelpxCenterConstraint, ticketHelpyConstraint, ticketHelpHeightConstraint, ticketHelpWidthConstraint])
        self.view.insertSubview(self.ticketHelp, belowSubview: (inputToolbar)!)
        
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
        let helperFootyConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.pizzaHelp, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 40)
        self.view.addConstraints([helperFootxCenterConstraint, helperFootWidthConstraint, helperFootyConstraint])
        self.view.insertSubview(self.helperFoot, belowSubview: (inputToolbar)!)

        helperFoot.hidden = true
        pizzaHelp.hidden = true
        furnitureHelp.hidden = true
        ticketHelp.hidden = true
        
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
            self.pizzaHelp.hidden = false
            self.furnitureHelp.hidden = false
            self.ticketHelp.hidden = false
            self.helperFoot.hidden = false
        }

        self.getMessagesHandle = self.messagesRef.queryLimitedToLast(50).observeEventType(FEventType.ChildAdded, withBlock: {
            (snapshot) in
            if snapshot.key != "serviced" {
                let messageId = snapshot.key
                let text = snapshot.value["text"] as! String
                let timestamp = snapshot.value["timestamp"] as! NSTimeInterval
                let date = NSDate(timeIntervalSince1970: timestamp/1000)
                let sentByUser = snapshot.value["sent_by_user"] as! Bool
                let deletedByUser = snapshot.value["deleted_by_user"] as! Bool
                var sender = "not_user"
                if !sentByUser && !self.firstMessageRead! {
                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    self.firstMessageRead = false
                }
                else {
                    sender = self.senderId
                }
                let message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date)
                
                if !deletedByUser {
                    self.messages.append(message)
                }
                
                if self.messages.count > 0 {
                    self.pizzaHelp.hidden = true
                    self.furnitureHelp.hidden = true
                    self.ticketHelp.hidden = true
                    self.helperFoot.hidden = true
                }
                
                self.finishReceivingMessage()
            }
        })
    }

    func sendMessage(text: String!) {
        self.messagesRef.childByAutoId().setValue([
            "text": text,
            "timestamp": FirebaseServerValue.timestamp(),
            "sent_by_user": true,
            "deleted_by_user": false
            ])
        var isServiced: UInt!
        self.messagesRef.observeEventType(.Value, withBlock: { snapshot in
             isServiced = snapshot.value["serviced"] as! UInt
            }, withCancelBlock: { error in
                print(error.description)
        })
        if isServiced != nil {
            if isServiced == 1 {
                self.messagesRef.updateChildValues([
                    "serviced": 0
                    ])
            }
        }
        else {
            self.messagesRef.updateChildValues([
                    "serviced": 0
                ])
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("attacment pressed")
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
        let updateMessageRef = self.messagesRef.childByAppendingPath("/" + messageKey)
        updateMessageRef.updateChildValues([
            "deleted_by_user": true
            ])
        
        self.messages.removeAtIndex(indexPath.item)
        collectionView.deleteItemsAtIndexPaths([indexPath])

        if self.messages.count == 0 {
            self.pizzaHelp.hidden = false
            self.furnitureHelp.hidden = false
            self.ticketHelp.hidden = false
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
