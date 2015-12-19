//
//  OrdersViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 12/13/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import Firebase

class OrdersViewController: UITableViewController {
    
    var user: FAuthData?
    var ref: Firebase!
    var ordersRef: Firebase!
    var senderId: String!
    var getOrdersHandle: UInt!
    var noOrdersLabel: UILabel!
    
    var orders = [Order]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove extra lines below filled rows
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);

        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        self.user = self.ref.authData
        self.senderId = self.user?.uid
        
        self.noOrdersLabel = UILabel()
        self.noOrdersLabel.translatesAutoresizingMaskIntoConstraints = false
        self.noOrdersLabel.text = "You have not placed any orders yet.\nAsk us for anything!"
        self.noOrdersLabel.lineBreakMode = .ByWordWrapping
        self.noOrdersLabel.numberOfLines = 0
        self.noOrdersLabel.font = UIFont(name: "SFUIText-Regular", size: 15.5)
        self.noOrdersLabel.textAlignment = NSTextAlignment.Center
        self.noOrdersLabel.textColor = UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0)
        self.noOrdersLabel.sizeToFit()
        self.view.addSubview(self.noOrdersLabel)
        let noOrdersxCenterConstraint = NSLayoutConstraint(item: self.noOrdersLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let noOrdersyCenterConstraint = NSLayoutConstraint(item: self.noOrdersLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: -50)
        let noOrdersWidthConstraint = NSLayoutConstraint(item: self.noOrdersLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 300)
        self.view.addConstraints([noOrdersxCenterConstraint, noOrdersWidthConstraint, noOrdersyCenterConstraint])
        self.noOrdersLabel.hidden = true
        
        setupOrders()
        checkStatus()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func setupOrders() {
        if self.orders.count == 0 {
            self.noOrdersLabel.hidden = false
        }
        self.ordersRef = ref.childByAppendingPath("orders/" + self.senderId)
        
        self.getOrdersHandle = self.ordersRef.queryLimitedToLast(50).observeEventType(FEventType.ChildAdded, withBlock: {
            (snapshot) in
            
            let description = snapshot.value["description"] as! String
            let company = snapshot.value["company"] as? String
            let timestamp = snapshot.value["timestamp"] as! NSTimeInterval
            let status = snapshot.value["status"] as! String
            let category = snapshot.value["category"] as! String

            let order = Order(status: status, description: description, company: company, category: category, timestamp: timestamp)
            
            self.orders.insert(order, atIndex: 0)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            
            if self.orders.count > 0 {
                self.noOrdersLabel.hidden = true
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.orders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("orderCell", forIndexPath: indexPath) as! OrderCell
        
        let order = self.orders[indexPath.row]
        
        if order.company() != nil {
            cell.orderDescription.text = order.orderDescription() + " | " + order.company()!
        }
        else {
            cell.orderDescription.text = order.orderDescription()
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "MMM d, y | h:mm a"
        let formattedDateTime = dateFormatter.stringFromDate(order.date())
        cell.dateAndTimeOfOrder.text = formattedDateTime
        var statusString = order.status()
        statusString.replaceRange(statusString.startIndex...statusString.startIndex, with: String(statusString[statusString.startIndex]).capitalizedString)
        cell.statusOfOrder.text = statusString
        cell.categoryImageOfOrder.image = UIImage(named: order.category().lowercaseString)

        return cell
    }
    
    func checkStatus() {
        self.ordersRef = ref.childByAppendingPath("orders/" + self.senderId)
        
        self.ordersRef.observeEventType(FEventType.ChildChanged, withBlock: {
            (snapshot) in
            let timestamp = snapshot.value["timestamp"] as! NSTimeInterval
            let status = snapshot.value["status"] as! String
            
            for order in self.orders {
                if order.timestamp() == timestamp {
                    order.setStatus(status)
                    self.tableView.reloadData()
                    break
                }
            }
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
