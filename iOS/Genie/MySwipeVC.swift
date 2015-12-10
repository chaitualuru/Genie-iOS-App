import UIKit


class MySwipeVC: EZSwipeController {
    override func setupView() {
        datasource = self
        //        navigationBarShouldNotExist = true
        
        
        // Change the top bar tint
        view.backgroundColor = UIColor.whiteColor()
    }
}

extension MySwipeVC: EZSwipeControllerDataSource {
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    func viewControllerData() -> [UIViewController] {
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("homeView")
        let historyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("historyView") as! HistoryViewController
        let wishesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("wishesView") as! WishesViewController
        
        return [historyVC, homeVC, wishesVC]
    }
    
    func navigationBarDataForPageIndex(index: Int) -> UINavigationBar {
        var title = ""
        if index == 0 {
            title = "History"
        } else if index == 1 {
            title = ""
        } else if index == 2 {
            title = "Wishes"
        }
    
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = UIBarStyle.Default
        //        navigationBar.barTintColor = QorumColors.WhiteLight
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        if let navFont = UIFont(name: "SFUIDisplay-Regular", size: 20.0) {
            let attributes: [String:AnyObject]? = [
                NSForegroundColorAttributeName: UIColor(red: (27/255.0), green: (165/255.0), blue: (221/255.0), alpha: 1.0),
                NSFontAttributeName: navFont
            ]
            navigationBar.titleTextAttributes = attributes
        }
        
        navigationBar.barTintColor = UIColor.whiteColor()

        
        var menuImg = UIImage(named: "menu")!
        menuImg = scaleTo(image: menuImg, w: 22, h: 18)
        
        
        if index == 0 {
            let rightButtonItem = UIBarButtonItem(image: menuImg, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            rightButtonItem.tintColor = UIColor.blackColor()
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 1 {
            var genie = UIImage(named: "genie")!
            genie = scaleTo(image: genie, w: 25, h: 30)
            let rightButtonItem = UIBarButtonItem(image: menuImg, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            (barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "a")
            rightButtonItem.tintColor = UIColor.blackColor()
            
            let leftButtonItem = UIBarButtonItem(image: menuImg, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            leftButtonItem.tintColor = UIColor.blackColor()
            
            let genieLogo = UIImageView(image: genie)
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("toProfileVC:"))
            genieLogo.userInteractionEnabled = true
            genieLogo.addGestureRecognizer(tapGestureRecognizer)
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.titleView = genieLogo
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 2 {
            let leftButtonItem = UIBarButtonItem(image: menuImg, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            leftButtonItem.tintColor = UIColor.blackColor()
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = nil
        }
        navigationBar.pushNavigationItem(navigationItem, animated: false)
        return navigationBar
    }
    
    private func scaleTo(image image: UIImage, w: CGFloat, h: CGFloat) -> UIImage {
        let newSize = CGSize(width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func toProfileVC(img: AnyObject) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("profileVC") as! ProfileViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}