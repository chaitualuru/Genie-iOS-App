//
//  EntryViewController.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 12/11/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUp(sender: AnyObject) {
    
        self.performSegueWithIdentifier("SIGNUP", sender: self)
        
    }
    
    @IBAction func signIn(sender: AnyObject) {
    
        self.performSegueWithIdentifier("SIGNIN", sender: self)
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
