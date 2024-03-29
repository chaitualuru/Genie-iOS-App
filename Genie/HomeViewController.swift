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
import SVPullToRefresh
import SVProgressHUD
import Haneke

var homeVCwishSelected = false
var homeVCwishDescription = ""

class HomeViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: FAuthData?
    var ref: Firebase!
    var messagesRef: Firebase!
    
    var messages = [Message]()
    var mobileNumber: String!
    
    var getMessagesHandle: UInt!
    
    let imagePicker = UIImagePickerController()
    var currentAttachment: UIImage?
    var defaultLeftButton: UIButton!
    var tappedImageData: UIImage!
    
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 0.8))
    
    var appointmentHelp: UILabel!
    var furnitureHelp: UILabel!
    var reminderHelp: UILabel!
    var helperFoot: UILabel!
    var firstMessageRead: Bool!
    let imageCache = Shared.imageCache
    let textCache = Shared.stringCache
    
    
    func cacheMessages() {
        var allMessageIds = ""
        var counter = 0
        for var index = messages.count - 1; index >= 0; index-- {
            if (counter > 20) {
                break;
            }
            let message = messages[index]
            if (message.isMediaMessage()) {
                let media = message.media() as! JSQPhotoMediaItem
                imageCache.set(value: media.image, key: message.messageId())
            }
            let timestamp = message.date().timeIntervalSince1970
            
            textCache.set(value: message.text() + " ~|~ " + String(message.isMediaMessage()) + " ~|~ " + String(message.sentByUser()!) + " ~|~ " + String(timestamp), key: message.messageId())
            
            allMessageIds = allMessageIds + "," + message.messageId()
            counter++
        }
        textCache.set(value: allMessageIds, key: "allMessageIds")
        textCache.set(value: self.senderId, key: "uid")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.cacheMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 130, 0);
        
        self.view.layer.borderWidth = 0.3
        self.view.layer.borderColor = UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 0.8).CGColor
        
        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        self.user = self.ref.authData
        self.senderId = self.user?.uid
        self.senderDisplayName = "not_set"
        
        let firstNameRef = ref.childByAppendingPath("users/" + senderId + "/first_name")
        firstNameRef.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                print("could not get first name")
            }
            else {
                self.senderDisplayName = snapshot.value as! String
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        let mobileNumberRef = ref.childByAppendingPath("users/" + senderId + "/mobile_number")
        mobileNumberRef.observeEventType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                print("could not get mobile number")
            }
            else {
                self.mobileNumber = snapshot.value as! String
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        imagePicker.delegate = self
        self.firstMessageRead = true
        
        // setup remote notifications --------------------------------------------------------------
        switch(getMajorSystemVersion()) {
        case 7:
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Alert, .Sound])
            UIApplication.sharedApplication().registerForRemoteNotifications()
        default:
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
        // --------------------------------------------------------------------------------------
        
        // Setting up Input Bar -----------------------------------------------------------------
        
        if let toolbar = inputToolbar {
            if let conview = toolbar.contentView {
                conview.backgroundColor = UIColor.whiteColor()
                if let texview = conview.textView {
                    texview.layer.borderWidth = 0
                    texview.placeHolder = "Type a message..."
                    texview.placeHolderTextColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                    texview.font = UIFont(name: "SFUIText-Regular", size: 15.0)
                }
                if let rightbarbutton = conview.rightBarButtonItem {
                    rightbarbutton.setTitle("", forState: UIControlState.Normal)
                }
                self.defaultLeftButton = conview.leftBarButtonItem
                let sendImage = UIImage(named: "lamp.png")
                let sendButton: UIButton = UIButton(type: UIButtonType.Custom)
                sendButton.setImage(sendImage, forState: UIControlState.Normal)
                conview.rightBarButtonItem = sendButton
            }
        }
        
        automaticallyScrollsToMostRecentMessage = true
        
        // --------------------------------------------------------------------------------------
        
        if homeVCwishSelected {
            
            if let toolbar = inputToolbar {
                if let conview = toolbar.contentView {
                    conview.backgroundColor = UIColor.whiteColor()
                    if let textView = conview.textView {
                        if homeVCwishDescription == "" {
                            textView.placeHolder = "Ask us for anything!"
                            textView.becomeFirstResponder()
                        }
                        textView.text = homeVCwishDescription
                        textView.becomeFirstResponder()
                    }
                    conview.rightBarButtonItem?.enabled = true
                }
            }
            
            homeVCwishSelected = false
            homeVCwishDescription = ""
        }
        
        // Helper Labels ------------------------------------------------------------------------
        
        self.appointmentHelp = UILabel()
        self.appointmentHelp.translatesAutoresizingMaskIntoConstraints = false
        self.appointmentHelp.numberOfLines = 0
        self.appointmentHelp.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.appointmentHelp.textAlignment = NSTextAlignment.Center
        self.appointmentHelp.textColor = UIColor.lightGrayColor()
        self.appointmentHelp.text = "Book me an appointment with a Dentist."
        self.appointmentHelp.sizeToFit()
        self.view.addSubview(appointmentHelp)
        let appointmentHelpxCenterConstraint = NSLayoutConstraint(item: self.appointmentHelp, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let appointmentHelpyCenterConstraint = NSLayoutConstraint(item: self.appointmentHelp, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: -44)
        let appointmentHelpWidthConstraint = NSLayoutConstraint(item: self.appointmentHelp, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.appointmentHelp.frame.width)
        let appointmentHelpHeightConstraint = NSLayoutConstraint(item: self.appointmentHelp, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.appointmentHelp.frame.height)
        self.view.addConstraints([appointmentHelpHeightConstraint, appointmentHelpWidthConstraint, appointmentHelpxCenterConstraint, appointmentHelpyCenterConstraint])
        self.view.insertSubview(self.appointmentHelp, belowSubview: (inputToolbar)!)
        
        self.furnitureHelp = UILabel()
        self.furnitureHelp.translatesAutoresizingMaskIntoConstraints = false
        self.furnitureHelp.numberOfLines = 0
        self.furnitureHelp.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.furnitureHelp.textAlignment = NSTextAlignment.Center
        self.furnitureHelp.textColor = UIColor.lightGrayColor()
        self.furnitureHelp.text = "I need a side table for my new apartment."
        self.furnitureHelp.sizeToFit()
        self.view.addSubview(self.furnitureHelp)
        let furnitureHelpxCenterConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let furnitureHelpWidthConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.furnitureHelp.frame.width)
        let furnitureHelpHeightConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.furnitureHelp.frame.height)
        let furnitureHelpyConstraint = NSLayoutConstraint(item: self.furnitureHelp, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.appointmentHelp, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -10)
        self.view.addConstraints([furnitureHelpxCenterConstraint, furnitureHelpyConstraint, furnitureHelpHeightConstraint, furnitureHelpWidthConstraint])
        self.view.insertSubview(self.furnitureHelp, belowSubview: (inputToolbar)!)
        
        self.reminderHelp = UILabel()
        self.reminderHelp.translatesAutoresizingMaskIntoConstraints = false
        self.reminderHelp.numberOfLines = 0
        self.reminderHelp.font = UIFont(name: "SFUIText-Regular", size: 15.0)
        self.reminderHelp.textAlignment = NSTextAlignment.Center
        self.reminderHelp.textColor = UIColor.lightGrayColor()
        self.reminderHelp.text = "Remind me to pay my credit card bill."
        self.reminderHelp.sizeToFit()
        self.view.addSubview(self.reminderHelp)
        let reminderHelpxCenterConstraint = NSLayoutConstraint(item: self.reminderHelp, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let reminderHelpWidthConstraint = NSLayoutConstraint(item: self.reminderHelp, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.reminderHelp.frame.width)
        let reminderHelpHeightConstraint = NSLayoutConstraint(item: self.reminderHelp, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:self.reminderHelp.frame.height)
        let reminderHelpyConstraint = NSLayoutConstraint(item: self.reminderHelp, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.appointmentHelp, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 10)
        self.view.addConstraints([reminderHelpxCenterConstraint, reminderHelpyConstraint, reminderHelpHeightConstraint, reminderHelpWidthConstraint])
        self.view.insertSubview(self.reminderHelp, belowSubview: (inputToolbar)!)
        
        self.helperFoot = UILabel()
        self.helperFoot.translatesAutoresizingMaskIntoConstraints = false
        self.helperFoot.numberOfLines = 0
        self.helperFoot.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.helperFoot.font = UIFont(name: "SFUIText-Medium", size: 15.5)
        self.helperFoot.textAlignment = NSTextAlignment.Center
        let mainString = "Swipe left for more!"
        let range = (mainString as NSString).rangeOfString("Swipe left for more!")
        let attributedString = NSMutableAttributedString(string:mainString)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0), range: range)
        self.helperFoot.attributedText = attributedString
        self.helperFoot.sizeToFit()
        self.helperFoot.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.view.addSubview(self.helperFoot)
        let helperFootxCenterConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let helperFootWidthConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant:250)
        let helperFootyConstraint = NSLayoutConstraint(item: self.helperFoot, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.appointmentHelp, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 40)
        self.view.addConstraints([helperFootxCenterConstraint, helperFootWidthConstraint, helperFootyConstraint])
        self.view.insertSubview(self.helperFoot, belowSubview: (inputToolbar)!)

        helperFoot.hidden = false
        appointmentHelp.hidden = false
        furnitureHelp.hidden = false
        reminderHelp.hidden = false
        
        // --------------------------------------------------------------------------------------
        

        // Handling Navigation Bar --------------------------------------------------------------
        
        self.navigationController?.navigationBar.hidden = true        
        
        // --------------------------------------------------------------------------------------
        
        
        // Removing avatars ---------------------------------------------------------------------
        
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        // --------------------------------------------------------------------------------------
        
        
        // Adding delete action -----------------------------------------------------------------
        
        UIMenuController.sharedMenuController().menuItems = [UIMenuItem(title: "Remove", action: "removeMessage:")]

        JSQMessagesCollectionViewCell.registerMenuAction("removeMessage:")
        
        // --------------------------------------------------------------------------------------
        
        // Scroll to top to get Earlier Messages ------------------------------------------------

        
        self.collectionView!.addPullToRefreshWithActionHandler({ () -> Void in
            self.loadMore()
        }, position: UInt(SVPullToRefreshPositionTop))
        
        
            
        // --------------------------------------------------------------------------------------
        
        
        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        
        textCache.fetch(key: "uid").onSuccess { uid in
            if uid == self.senderId {
                self.textCache.fetch(key: "allMessageIds").onSuccess { data in
                    if data == "" {
                        self.setupMessages()
                    } else {
                        let allMessageIds = data.componentsSeparatedByString(",")
                        for var index = 0; index < allMessageIds.count; ++index  {
                            let id = allMessageIds[index]
                            self.textCache.fetch(key: id).onSuccess { data in
                                let messageComponents = data.componentsSeparatedByString(" ~|~ ")
                                let messageId = id
                                var message: Message!
                                let text = messageComponents[0]
                                let timestamp : NSTimeInterval = (messageComponents[3] as NSString).doubleValue
                                let date = NSDate(timeIntervalSince1970: timestamp)
                                let sentByUser = NSString(string: messageComponents[2]).boolValue
                                let isMediaMessage = NSString(string: messageComponents[1]).boolValue
                                var sender = "notUser"
                                
                                if sentByUser {
                                    sender = self.senderId
                                }
                                if isMediaMessage {
                                    self.imageCache.fetch(key: id).onSuccess { image in
                                        let photoItem = JSQPhotoMediaItem(image: image)
                                        message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: photoItem)
                                        self.messages.insert(message, atIndex: 0)

                                        if (self.messages.count == allMessageIds.count - 1) {
                                            self.messages.sortInPlace({ $0.date().timeIntervalSince1970 < $1.date().timeIntervalSince1970 })
                                            self.finishReceivingMessage()
//                                            print("Cache Fetched")
                                            self.appointmentHelp.hidden = true
                                            self.furnitureHelp.hidden = true
                                            self.reminderHelp.hidden = true
                                            self.helperFoot.hidden = true
                                            self.setupMessages()
                                        }
                                    }
                                } else {
                                    message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: nil)
                                    self.messages.insert(message, atIndex: 0)
                                    if (self.messages.count == allMessageIds.count - 1) {
//                                        print("Cache Fetched")
                                        self.messages.sortInPlace({ $0.date().timeIntervalSince1970 < $1.date().timeIntervalSince1970 })
                                        self.appointmentHelp.hidden = true
                                        self.furnitureHelp.hidden = true
                                        self.reminderHelp.hidden = true
                                        self.helperFoot.hidden = true
                                        self.finishReceivingMessage()
                                        self.setupMessages()
                                    }
                                }
                            }
                        }
                    }
                }.onFailure { error in
                    print("messages")
                    self.setupMessages()
                }
            } else {
                print("messages")
                self.setupMessages()
            }
        }.onFailure { error in
            print("messages")
            self.setupMessages()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: Selector("cacheMessages"), userInfo: nil, repeats: true)
    }
    
    func getMajorSystemVersion() -> Int {
        return Int(UIDevice.currentDevice().systemVersion.componentsSeparatedByString(".")[0])!
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        dismissKeyboard()
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let tappedMessage = self.messages[indexPath.row]
        if tappedMessage.isMediaMessage() {
            let mediaItem = tappedMessage.media() as! JSQPhotoMediaItem!
            tappedImageData = mediaItem.image
            performSegueWithIdentifier("SHOW_IMAGE", sender: nil)
        }
        dismissKeyboard()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_IMAGE" {
            let imageViewerController = (segue.destinationViewController as! ImageViewer)
            imageViewerController.imageData = tappedImageData
        }
    }
    
    // Load Earlier Messages --------------------------------------------------------------------
    func loadMore() {
        if self.messages.count > 0 {
//            print("Loading earlier messages")
            
            self.collectionView!.collectionViewLayout.springinessEnabled = false
            self.collectionView!.pullToRefreshView.startAnimating()
            var counter = 0
            
            let lastMsg = messages[0]
            
            //Disable Automatic Scrolling -----------------------------------------------------------
            self.automaticallyScrollsToMostRecentMessage = false
            self.messagesRef.queryOrderedByChild("timestamp").queryEndingAtValue(lastMsg.date().timeIntervalSince1970).queryLimitedToLast(20).observeEventType(.ChildAdded, withBlock: {
                (snapshot) in
                if snapshot != nil {
                    let messageId = snapshot.key
                    let text = snapshot.value["text"] as? String
                    let timestamp = snapshot.value["timestamp"] as? NSTimeInterval
                    let date = NSDate(timeIntervalSince1970: timestamp!)
                    let sentByUser = snapshot.value["sent_by_user"] as! Bool
                    let deletedByUser = snapshot.value["deleted_by_user"] as! Bool
                    let isMediaMessage = snapshot.value["is_media_message"] as! Bool
                    var sender = "notUser"
                    
                    if sentByUser {
                        sender = self.senderId
                    }
                    
                    if !deletedByUser {
                        var message: Message!
                        if isMediaMessage {
                            let encodedString = snapshot.value["media"] as? String
                            if let encoding = encodedString {
                                let imageData = NSData(base64EncodedString: encoding, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                                let photoItem = JSQPhotoMediaItem(image: UIImage(data: imageData!))
                                if !sentByUser {
                                    photoItem.appliesMediaViewMaskAsOutgoing = false
                                }
                                message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: photoItem)
                            }
                            else {
                                print("Could not attach photo")
                                message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: nil)
                            }
                        }
                        else {
                            message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: nil)
                        }
                        
                        if message.messageId() == lastMsg.messageId() {
                            self.collectionView!.pullToRefreshView.stopAnimating()
                        } else {
                            self.messages.insert(message, atIndex: counter)
                            counter = counter + 1
                        }
                    }
                }
                else {
                    print("snapshot nil")
                    self.collectionView!.pullToRefreshView.stopAnimating()
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.automaticallyScrollsToMostRecentMessage = true
                    if counter == 0 {
                        let alertController = UIAlertController(title: "", message: "No more messages.", preferredStyle: .Alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        
                        alertController.addAction(okAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        self.collectionView!.pullToRefreshView.stopAnimating()
                    }
                })
                self.finishReceivingMessageAnimated(false)
            }, withCancelBlock: {error in
                print(error)
            })
        } else {
            let alertController = UIAlertController(title: "", message: "No messages.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            self.collectionView!.pullToRefreshView.stopAnimating()
        }
    }
    // ------------------------------------------------------------------------------------------
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Bubble springiness factor ------------------------------------------------------------
        
        collectionView!.collectionViewLayout.springinessEnabled = false
        
        // --------------------------------------------------------------------------------------
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let pickedImage = image as? UIImage {
            self.currentAttachment = pickedImage
            if let toolbar = inputToolbar {
                if let conview = toolbar.contentView {
                    conview.leftBarButtonItem?.contentMode = .ScaleAspectFit
                    let attachButton: UIButton = UIButton(type: UIButtonType.Custom)
                    attachButton.setImage(pickedImage, forState: UIControlState.Normal)
                    conview.leftBarButtonItem = attachButton
                    conview.rightBarButtonItem!.enabled = true
                }
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func setupMessages() {
//        print("Setting up messages")
        self.messagesRef = ref.childByAppendingPath("messages/" + self.senderId)
        
        if self.messages.count == 0 {
            self.appointmentHelp.hidden = false
            self.furnitureHelp.hidden = false
            self.reminderHelp.hidden = false
            self.helperFoot.hidden = false
        }
        
        self.collectionView!.collectionViewLayout.springinessEnabled = false

        self.getMessagesHandle = self.messagesRef.queryLimitedToLast(20).observeEventType(FEventType.ChildAdded, withBlock: {
            (snapshot) in
            let messageId = snapshot.key
            var messageExists = false
            for msg in self.messages {
                if msg.messageId() == messageId {
                    messageExists = true
                    break
                }
            }
            if (messageExists == false) {
                let text = snapshot.value["text"] as! String
                let timestamp = snapshot.value["timestamp"] as! NSTimeInterval
                let date = NSDate(timeIntervalSince1970: timestamp)
                let sentByUser = snapshot.value["sent_by_user"] as! Bool
                let deletedByUser = snapshot.value["deleted_by_user"] as! Bool
                let isMediaMessage = snapshot.value["is_media_message"] as! Bool
                
                var sender = "not_user"
                
                if sentByUser {
                    sender = self.senderId
                } else {
                    if !self.firstMessageRead {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                        self.firstMessageRead = false
                    }
                }
                
                
                if !deletedByUser {
                    var message: Message!
                    if isMediaMessage {
                        let encodedString = snapshot.value["media"] as? String
                        if let encoding = encodedString {
                            let imageData = NSData(base64EncodedString: encoding, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                            let photoItem = JSQPhotoMediaItem(image: UIImage(data: imageData!))
                            if !sentByUser {
                                photoItem.appliesMediaViewMaskAsOutgoing = false
                            }
                            message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: photoItem)
                        }
                        else {
                            print("Could not attach photo")
                            message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: nil)
                        }
                    }
                    else {
                        message = Message(messageId: messageId, text: text, sentByUser: sentByUser, senderId: sender, senderDisplayName: self.senderDisplayName, date: date, isMediaMessage: isMediaMessage, media: nil)
                    }
                    self.messages.append(message)
                }
            }
            if self.messages.count > 0 {
                self.appointmentHelp.hidden = true
                self.furnitureHelp.hidden = true
                self.reminderHelp.hidden = true
                self.helperFoot.hidden = true
            }
            self.finishReceivingMessage()
        })
    }
    
    func getJSON(urlToRequest: String) -> NSData {
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func parseJSON(inputData: NSData) -> Int {
        let timestampDictionary: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        return timestampDictionary["timestamp"] as! Int
    }

    func sendMessage(text: String!) {
        let tstamp = Int(NSDate().timeIntervalSince1970)
        if let attachment = self.currentAttachment {
            let imageData = UIImageJPEGRepresentation(attachment, 0.5)
            let imageString = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            self.messagesRef.childByAutoId().setValue([
                "text": text,
                "timestamp": tstamp,
                "sent_by_user": true,
                "deleted_by_user": false,
                "is_media_message": true,
                "media": imageString
                ])
        }
        else {
            self.messagesRef.childByAutoId().setValue([
                "text": text,
                "timestamp": tstamp,
                "sent_by_user": true,
                "deleted_by_user": false,
                "is_media_message": false
                ])
        }
        
        
        var isServiced: UInt!
        let userRef = self.ref.childByAppendingPath("users/" + self.senderId)
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            isServiced = snapshot.value["serviced"] as! UInt
            if isServiced != nil {
                if isServiced == 1 {
                    userRef.updateChildValues([
                        "serviced": 0
                        ])
                }
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        if self.currentAttachment != nil {
            if text.isEmpty {
                sendMessage(text)
                self.finishSendingMessage()
                self.currentAttachment = nil
                if let toolbar = inputToolbar {
                    if let conview = toolbar.contentView {
                        conview.leftBarButtonItem = self.defaultLeftButton
                    }
                }
            }
            else {
                sendMessage("")
                self.finishSendingMessage()
                self.currentAttachment = nil
                if let toolbar = inputToolbar {
                    if let conview = toolbar.contentView {
                        conview.leftBarButtonItem = self.defaultLeftButton
                    }
                }
                sendMessage(text)
                self.finishSendingMessage()
            }
        }
        else {
            self.sendMessage(text)
            self.finishSendingMessage()
        }
//        showCheckout()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
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
            cell.textView?.textColor = UIColor.whiteColor()
            cell.textView?.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        } else {
            cell.textView?.textColor = UIColor.blackColor()
            cell.textView?.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        }

        return cell
    }
    
    // Delete action ----------------------------------------------------------------------
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "removeMessage:" {
            return true
        }
        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == "removeMessage:" {
            removeMessage(collectionView, indexPath: indexPath)
        }
        super.collectionView(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    func removeMessage(collectionView: UICollectionView, indexPath: NSIndexPath) {
        let messageKey = self.messages[indexPath.item].messageId()
        let updateMessageRef = self.messagesRef.childByAppendingPath("/" + messageKey)
        updateMessageRef.updateChildValues([
            "deleted_by_user": true
            ])
        
        self.messages.removeAtIndex(indexPath.item)
        collectionView.deleteItemsAtIndexPaths([indexPath])

        if self.messages.count == 0 {
            self.appointmentHelp.hidden = false
            self.furnitureHelp.hidden = false
            self.reminderHelp.hidden = false
            self.helperFoot.hidden = false
        }
    }
    
    // --------------------------------------------------------------------------------------
    
    
    // Razorpay -----------------------------------------------------------------------------
    
    func showCheckout(){
        let checkout:RazorpayCheckout = RazorpayCheckout(key: "rzp_test_V3WnFxfPzRcrW9");
        checkout.setDelegate(self);
        let options = [
            "amount" : "200",
            "image": "",
            "name": "business or product name",
            "description": "purchase description",
            "prefill" : [
                "email": "pranav@razorpay.com",
                "contact": "8879524924"
            ],
            "theme": [
//                "color": "#F37254"
//                "color": "#625A97"
                "color": "#3A365A"
            ]
        ]
        checkout.open(options);
    }
    
    // implement in delegate set through "checkout.setDelegate" above.
    func onPaymentSuccess(payment_id: String){
        print(payment_id);
    }
    
    func onPaymentError(code: NSNumber, description: String){
        print(description);
    }
    
    // --------------------------------------------------------------------------------------
    
    
    // Dismissing Keyboard ------------------------------------------------------------------
    
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
