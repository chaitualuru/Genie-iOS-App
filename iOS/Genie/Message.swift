//
//  Message.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/25/15.
//  Copyright © 2015 genie. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData {
    var messageId_: String
    var text_: String
    var senderId_: String
    var senderDisplayName_: String
    var date_: NSDate
    var isMediaMessage_: Bool
    var sentByUser_: Bool
    
    init(messageId: String?, text: String?, sentByUser: Bool?, senderId: String?, senderDisplayName: String?) {
        self.messageId_ = messageId!
        self.text_ = text!
        self.senderId_ = senderId!
        self.senderDisplayName_ = senderDisplayName!
        self.date_ = NSDate()
        self.isMediaMessage_ = false
        self.sentByUser_ = sentByUser!
    }
    
    func messageId() -> String! {
        return self.messageId_
    }
    
    func text() -> String! {
        return self.text_
    }
    
    func sentByUser() -> Bool! {
        return self.sentByUser_
    }
    
    func senderId() -> String! {
        return self.senderId_
    }
    
    func senderDisplayName() -> String! {
        return self.senderDisplayName_
    }
    
    func date() -> NSDate! {
        return self.date_
    }
    
    func isMediaMessage() -> Bool {
        return self.isMediaMessage_
    }
 
    func messageHash() -> UInt {
        return UInt(self.hash)
    }
    
}