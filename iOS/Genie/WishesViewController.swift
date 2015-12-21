//
//  WishesViewController.swift
//  Genie
//
//  Created by Vamsee Chamakura on 20/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class WishesViewController: UITableViewController {
    var categorySelected = ""
    var selectedDescription = []
    var selectedHeading = []
    
    
    let foodDescription = ["I would like to order a medium barbecue pizza from Dominos.", "Can you give the menu for Biryani House?", "Show me some reviews of Indigo Deli.", "I would like the recipe for homemade Gulab Jamun.", "Where can I find the best chinese food nearby?", "Ask us anything!"]
    let foodHeading = ["Order", "Menu", "Review/Ratings", "Recipes", "Recommendations", "Other"]
    
    let healthDescription = ["I would like my prescription delivered.", "I want the Gilette shaving cream + razor package.", "What treats should I buy my dog today?", "Make an appointment with an Orthopedic doctor near me.", "Can you send me medium size diapers for my daughter?", "Ask us anything!"]
    let healthHeading = ["Medicine", "Personal Care", "Pet Care", "Doctor Appointment", "Baby Care", "Other"]

    let homeDescription = ["I would like a plumber to fix the shower.", "Can you book a cleaner for later today?", "Find me an electrician to set up the wiring for me.", "I want to get my clothes picked up for dry cleaning.", "I need an exterminator for bed bugs.", "Ask us anything!"]
    let homeHeading = ["Plumber", "Cleaner", "Electrician", "Laundry", "Pest Control", "Other"]
    
    let bookingDescription = ["I want to buy 2 tickets for today's show of Dilwale.", "Can you book me a flight to Bengaluru on the 29th?", "I need a cab to pick me up in Cuffe Parade right now.", "Reserve a table for 4 at Peshawari for dinner tonight.", "Which bar can I go to with my friends later tonight?", "Ask us anything!"]
    let bookingHeading = ["Movie", "Travel", "Cab", "Food", "Nightlife", "Other"]
    
    let rechargeDescription = ["Can you recharge my Airtel plan with 300 rupees?", "Need to top-up my Tata Sky service.", "I want to recharge my Tata Photon plan.", "Pay my Reliance Energy bill that is due later today.", "My ICICI premium needs to be paid today.", "Ask us anything!"]
    let rechargeHeading = ["Phone", "Television", "DataCard and Landline", "Electricity and Gas", "Insurance", "Other"]
    
    let shoppingDescription = ["Can you send me some milk, cheese and eggs?", "I want a bouquet of Tulips delivered to my wife's office.", "Need some AA batteries picked up.", "Which TV would you recommend in my budget?", "Courier my package to Delhi tomorrow.", "Ask us anything!"]
    let shoppingHeading = ["Groceries", "Flowers", "General Store", "Electronics", "Parcel", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        switch categorySelected {
            case "food":
                selectedDescription = foodDescription
                selectedHeading = foodHeading
                break
            case "health":
                selectedHeading = healthHeading
                selectedDescription = healthDescription
                break
            case "home":
                selectedHeading = homeHeading
                selectedDescription = homeDescription
                break
            case "recharge":
                selectedHeading = rechargeHeading
                selectedDescription = rechargeDescription
                break
            case "booking":
                selectedHeading = bookingHeading
                selectedDescription = bookingDescription
                break
            case "shopping":
                selectedHeading = shoppingHeading
                selectedDescription = shoppingDescription
                break
            default:
                break
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBAction func goBackToDiscover(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
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
        return selectedDescription.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wishesCell", forIndexPath: indexPath) as! WishesCell

        cell.wishHeading.text = selectedHeading[indexPath.row] as? String
        cell.wishDescription.text = selectedDescription[indexPath.row] as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        homeVCwishSelected = true
        homeVCwishDescription = selectedDescription[indexPath.row] as! String
        self.presentViewController(MySwipeVC(), animated: true, completion: nil)
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
