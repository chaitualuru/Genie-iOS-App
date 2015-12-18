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
    
    var orders = [Order]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove extra lines below filled rows
        self.tableView.tableFooterView = UIView()

        self.ref = Firebase(url:"https://getgenie.firebaseio.com/")
        self.user = self.ref.authData
        self.senderId = self.user?.uid
        
        setupOrders()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func setupOrders() {
        self.ordersRef = ref.childByAppendingPath("orders/" + self.senderId)
        
        self.getOrdersHandle = self.ordersRef.queryLimitedToLast(50).observeEventType(FEventType.ChildAdded, withBlock: {
            (snapshot) in
            
            print(snapshot.key)
            let description = snapshot.value["description"] as! String
            let company = snapshot.value["company"] as? String
            let timestamp = snapshot.value["timestamp"] as! NSTimeInterval
            let date = NSDate(timeIntervalSince1970: timestamp/1000)
            let status = snapshot.value["status"] as! String

            let order = Order(status: status, description: description, date: date, company: company)
            
            self.orders.append(order)
        })
        
        if self.orders.count == 0 {
            // show "You have not placed any orders yet."
        }
        else {
            // hide it
        }
        
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
        
        let order = self.orders[indexPath.item]
        
        if order.company() != nil {
            cell.orderDescription.text = order.orderDescription() + "|" + order.company()!
        }
        else {
            cell.orderDescription.text = order.orderDescription()
        }
        cell.dateAndTimeOfOrder.text = order.date().description
        cell.statusOfOrder.text = order.status()

        return cell
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
