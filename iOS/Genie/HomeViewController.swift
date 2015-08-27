//
//  HomeViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/25/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: JSQMessagesViewController {
    
    var user: FAuthData?
    var ref: Firebase!
    var messagesRef: Firebase!
    var profileRef: Firebase!
    var messages = [Message]()
    var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 27, green: 165, blue: 221, alpha: 1.0))
    var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var batchMessages = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        self.user = ref.authData
        self.senderId = user?.uid
        self.senderDisplayName = "NotSet"
        self.profileRef = Firebase(url: "https://getgenie.firebaseio.com/users/" + senderId + "/first_name")
        self.profileRef.observeEventType(.Value, withBlock: { snapshot in
            self.senderDisplayName = snapshot.value as! String
            }, withCancelBlock: { error in
                print(error.description)
        })

        // Handling Navigation Bar --------------------------------------------------------------
        
        self.title = "Genie"
        if let navFont = UIFont(name: "SFUIDisplay-Regular", size: 20.0) {
            let attributes: [String:AnyObject]? = [
                // 18 146 216
                NSForegroundColorAttributeName: UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0),
                NSFontAttributeName: navFont
            ]
            self.navigationController?.navigationBar.titleTextAttributes = attributes
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), landscapeImagePhone: UIImage(named: "menu.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0)
        
        // --------------------------------------------------------------------------------------
        
        
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
        
        
        // Removing avatars ---------------------------------------------------------------------
        
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        // --------------------------------------------------------------------------------------
        
//        self.showLoadEarlierMessagesHeader = true
        
        JSQMessagesCollectionViewCell.registerMenuAction("delete:")
        
        // Dismiss keyboard on tap --------------------------------------------------------------
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // --------------------------------------------------------------------------------------
        
        setupFirebase()
        print(messages)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = true
    }


    func setupFirebase() {
        self.messagesRef = Firebase(url: "https://getgenie.firebaseio.com/messages/" + senderId)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        messagesRef.queryLimitedToLast(25).observeEventType(FEventType.ChildAdded, withBlock: {
            (snapshot) in
            let text = snapshot.value["text"] as? String
            let message = Message(text: text, senderId: self.senderId, senderDisplayName: self.senderDisplayName)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
    }

    func sendMessage(text: String!) {
        // *** STEP 3: ADD A MESpSAGE TO FIREBASE
        messagesRef.childByAutoId().setValue([
            "text": text
            ])
    }
    
    func tempSendMessage(text: String!, uid: String!, displayName: String!) {
        let message = Message(text: text, senderId: uid, senderDisplayName: displayName)
        messages.append(message)
    }
    
//     ACTIONS

    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        sendMessage(text)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId() == senderId {
            return self.outgoingBubble
        }
        
        return self.incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId() == senderId {
            cell.textView!.textColor = UIColor.blackColor()
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        } else {
            cell.textView!.textColor = UIColor.whiteColor()
            cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        }
        
//        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName: cell.textView!.textColor, NSUnderlineStyleAttributeName:1]
//        cell.textView.linkTextAttributes = attributes

        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.senderId() == senderId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId() == message.senderId() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.senderId())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId() == senderId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId() == message.senderId() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    func logout(sender:UIBarButtonItem) {
        ref.unauth()
        print("logged out user:", ref.authData)
        performSegueWithIdentifier("LOGOUT", sender: self)
    }
    
//    @IBAction func logout(sender: UIBarButtonItem) {
//        ref.unauth()
//        print("logged out user:", ref.authData)
//        performSegueWithIdentifier("LOGOUT", sender: self)
//    }
    
    
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
