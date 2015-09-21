//
//  SwipeViewController.swift
//  Genie
//
//  Created by Vamsee Chamakura on 21/09/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the View Controllers -------------------------------------------------------------
        
        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("homeVC") as! HomeViewController
        let vc0 = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("historyVC") as! HistoryViewController
        let vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("wishesVC") as! WishesViewController
        // --------------------------------------------------------------------------------------
      
        
        
        // Adding them to the Scroll View -------------------------------------------------------
        
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMoveToParentViewController(self)

        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        vc1.view.frame = frame1
        
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMoveToParentViewController(self)

        var frame2 = vc2.view.frame
        frame2.origin.x = self.view.frame.size.width * 2
        vc2.view.frame = frame2
        
        self.addChildViewController(vc2)
        self.scrollView.addSubview(vc2.view)
        
        vc2.didMoveToParentViewController(self)
        
        // --------------------------------------------------------------------------------------
      
        
        
        // Set size of Scroll View --------------------------------------------------------------
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height);
        
        // --------------------------------------------------------------------------------------
        
        
        
        // Center Home View Controller ----------------------------------------------------------
        
        scrollView.contentOffset = CGPoint(x: frame1.origin.x, y: frame1.origin.y)
        
        // --------------------------------------------------------------------------------------
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
