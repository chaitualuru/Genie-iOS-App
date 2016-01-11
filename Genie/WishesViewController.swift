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
    var selectedFiller = []
    var selectedHeading = []
    
    
    let foodDescription = ["I would like to order a medium barbecue pizza from Dominos.", "Can you give me the menu for Biryani House?", "Show me some reviews of Indigo Deli.", "I would like the recipe for homemade Gulab Jamun", "Where can I find the best chinese food nearby?", "Ask us anything!"]
    let foodFiller = ["I want to order ", "I want the menu for ", "Show me reviews of ", "I want the recipe for ", "Where can I find ", ""]
    let foodHeading = ["Order", "Menu", "Reviews/Ratings", "Recipes", "Recommendations", "Other"]
    
    let healthDescription = ["I would like my prescription delivered.", "I want an anti-perspirant deodorant.", "What treats should I buy my dog today?", "Make an appointment with an Orthopedic doctor near me.", "Can you send me medium size diapers for my daughter?", "Ask us anything!"]
    let healthFiller = ["I want ", "I want ", "What should I buy for ", "Make an appointment for ", "Can you send me ", ""]
    let healthHeading = ["Medicine", "Personal Care", "Pet Care", "Doctor Appointment", "Baby Care", "Other"]

    let homeDescription = ["I would like a plumber to fix the shower.", "Can you book a cleaner for later today?", "Find me an electrician to set up the wiring for my house.", "I want to get my clothes picked up for dry cleaning.", "I need an exterminator for bed bugs.", "Ask us anything!"]
    let homeFiller = ["I want a plumber ", "I want a cleaner ", "I want an electrician ", "I want ", "I want an extreminator ", ""]
    let homeHeading = ["Plumber", "Cleaner", "Electrician", "Laundry", "Pest Control", "Other"]
    
    let bookingDescription = ["I need a cab to pick me up in Cuffe Parade right now.", "Can you book me a flight to Bengaluru on the 29th?", "I want to buy 2 tickets for today's show of Dilwale.", "Find a hotel near BKC for next week.", "Reserve a table for 4 at Peshawari for dinner tonight.", "Ask us anything!"]
    let bookingFiller = ["I want a cab to ", "Can you book ", "I want to buy ", "Recommend a ", "Reserve ", ""]
    let bookingHeading = ["Cab", "Travel", "Movie", "Hotel", "Food and Nightlife", "Other"]
    
    let financeDescription = ["Can you recharge my Airtel plan with 300 rupees?", "Need to top-up my Dish TV service.", "I want to recharge my Tata Photon plan.", "Pay my Reliance Energy bill that is due later today.", "My ICICI premium needs to be paid today.", "Ask us anything!"]
    let financeFiller = ["Recharge ", "Top-Up ", "Recharge ", "Pay ", "Pay ", ""]
    let financeHeading = ["Phone", "Television", "Internet and Landline", "Electricity and Gas", "Insurance", "Other"]
    
    let shoppingDescription = ["Can you send me some milk, cheese and eggs?", "I want a bouquet of Tulips delivered to my wife's office.", "Need some AA batteries picked up.", "I need to buy a new television. Any recommendations?", "I would like a package couriered to Delhi tomorrow.", "Ask us anything!"]
    let shoppingFiller = ["I want to buy ", " I want to buy ", "I want to buy ", "I want to buy ", "I want to ship ", ""]
    let shoppingHeading = ["Groceries", "Flowers", "General Store", "Electronics", "Parcel", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // remove extra lines below filled rows
        self.tableView.tableFooterView = UIView()
        
        switch categorySelected {
            case "food":
                selectedDescription = foodDescription
                selectedHeading = foodHeading
                selectedFiller = foodFiller
                self.navigationItem.title = "Food"
                break
            case "health":
                selectedHeading = healthHeading
                selectedDescription = healthDescription
                selectedFiller = healthFiller
                self.navigationItem.title = "Health"
                break
            case "home":
                selectedHeading = homeHeading
                selectedDescription = homeDescription
                selectedFiller = homeFiller
                self.navigationItem.title = "Home"
                break
            case "finance":
                selectedHeading = financeHeading
                selectedDescription = financeDescription
                selectedFiller = financeFiller
                self.navigationItem.title = "Finance"
                break
            case "booking":
                selectedHeading = bookingHeading
                selectedDescription = bookingDescription
                selectedFiller = bookingFiller
                self.navigationItem.title = "Booking"
                break
            case "shopping":
                selectedHeading = shoppingHeading
                selectedDescription = shoppingDescription
                selectedFiller = shoppingFiller
                self.navigationItem.title = "Shopping"
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
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 0.2)
        
        cell.selectedBackgroundView = bgColorView

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        homeVCwishSelected = true
        homeVCwishDescription = selectedFiller[indexPath.row] as! String
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
