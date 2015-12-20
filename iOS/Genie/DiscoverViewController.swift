//
//  DiscoverViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 12/13/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    var category = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func foodSelected(sender: UIButton) {
        category = "food"
        performSegueWithIdentifier("WISHES", sender: nil)
    }

    @IBAction func healthSelected(sender: UIButton) {
        category = "health"
        performSegueWithIdentifier("WISHES", sender: nil)
    }

    @IBAction func rechargeSelected(sender: UIButton) {
        category = "recharge"
        performSegueWithIdentifier("WISHES", sender: nil)
    }
    
    @IBAction func bookingSelected(sender: UIButton) {
        category = "booking"
        performSegueWithIdentifier("WISHES", sender: nil)
    }
   
    @IBAction func shoppingSelected(sender: UIButton) {
        category = "shopping"
        performSegueWithIdentifier("WISHES", sender: nil)
    }
    
    @IBAction func homeSelected(sender: UIButton) {
        category = "home"
        performSegueWithIdentifier("WISHES", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WISHES" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let wishesVC = (navigationController.viewControllers.first as! WishesViewController)
            wishesVC.categorySelected = category
        }
    }


}
