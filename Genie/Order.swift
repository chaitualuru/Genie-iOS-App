//
//  Order.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 12/13/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class Order : NSObject {
    var status_: String
    var description_: String
    var timestamp_: NSTimeInterval
    var category_: String
    var company_: String?
    
    
    init(status: String?, description: String?, company: String?, category: String?, timestamp: NSTimeInterval?) {
        self.timestamp_ = timestamp!
        self.status_ = status!
        self.description_ = description!
        self.company_ = company
        self.category_ = category!
    }
    
    func setStatus(status: String) {
        self.status_ = status
    }
    
    func status() -> String! {
        return self.status_
    }
    
    func date() -> NSDate! {
        return NSDate(timeIntervalSince1970: self.timestamp_)
    }
    
    func timestamp() -> NSTimeInterval! {
        return self.timestamp_
    }
    
    func orderDescription() -> String! {
        return self.description_
    }
    
    func category() -> String! {
        return self.category_
    }
    
    func company() -> String? {
        return self.company_
    }
    
}