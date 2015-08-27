//
//  Message.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/25/15.
//  Copyright © 2015 genie. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData {
    var text_: String
    var senderId_: String
    var senderDisplayName_: String
    var date_: NSDate
    var isMediaMessage_: Bool
    var sentByUser_: Bool
    
    init(text: String?, sentByUser: Bool?, senderId: String?, senderDisplayName: String?) {
        self.text_ = text!
        self.senderId_ = senderId!
        self.senderDisplayName_ = senderDisplayName!
        self.date_ = NSDate()
        self.isMediaMessage_ = false
        self.sentByUser_ = sentByUser!
    }
    
    func text() -> String! {
        return text_
    }
    
    func sentByUser() -> Bool! {
        return sentByUser_
    }
    
    func senderId() -> String! {
        return senderId_
    }
    
    func senderDisplayName() -> String! {
        return senderDisplayName_
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func isMediaMessage() -> Bool {
        return isMediaMessage_
    }
 
    func messageHash() -> UInt {
        return UInt(self.hash)
    }
    
}