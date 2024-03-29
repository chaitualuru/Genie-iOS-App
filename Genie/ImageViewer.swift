//
//  ImageViewer.swift
//  Genie
//
//  Created by Vamsee Chamakura on 19/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageData: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageData
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
