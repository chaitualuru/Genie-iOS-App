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
    var date_: NSDate
//    var icon_: UIImage
    var company_: String?
    
    init(status: String?, description: String?, date: NSDate?, company: String?) {
        self.date_ = date!
        self.status_ = status!
        self.description_ = description!
        self.company_ = company
    }
    
    func status() -> String! {
        return self.status_
    }
    
    func date() -> NSDate! {
        return self.date_
    }
    
    func orderDescription() -> String! {
        return self.description_
    }
    
//    func icon() -> UIImage! {
//        return self.icon_
//    }
    
    func company() -> String? {
        return self.company_
    }
    
}