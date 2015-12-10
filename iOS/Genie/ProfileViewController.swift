//
//  ProfileViewController.swift
//  Genie
//
//  Created by Vamsee Chamakura on 11/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImgTop: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeight.constant = 0.4 * UIScreen.mainScreen().bounds.height
        profileImgTop.constant = 0.3 * 0.4 * UIScreen.mainScreen().bounds.height

        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width / 2;
        self.profileImg.layer.borderWidth = 3.0
        self.profileImg.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImg.clipsToBounds = true;
        
        // Do any additional setup after loading the view.
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
