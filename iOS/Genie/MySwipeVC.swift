import UIKit


class MySwipeVC: EZSwipeController {
    override func setupView() {
        datasource = self
        
        view.backgroundColor = UIColor.whiteColor()
    }
}

extension MySwipeVC: EZSwipeControllerDataSource {
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    func viewControllerData() -> [UIViewController] {
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("homeView")
        let ordersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ordersView")
        let discoverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("discoverView")
        
        return [ordersVC, homeVC, discoverVC]
    }
    
    func navigationBarDataForPageIndex(index: Int) -> UINavigationBar {
        var title = ""
        if index == 0 {
            title = "Orders"
        } else if index == 1 {
            title = ""
        } else if index == 2 {
            title = "Discover"
        }
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = UIBarStyle.Default
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        if let navFont = UIFont(name: "SFUIDisplay-Medium", size: 17.0) {
            let attributes: [String:AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: navFont
            ]
            navigationBar.titleTextAttributes = attributes
        }
        
        navigationBar.barTintColor = UIColor(red: (98/255.0), green: (90/255.0), blue: (151/255.0), alpha: 1.0)
        
        let menuImage = UIImage(named: "menu")
        let gridImage = UIImage(named: "grid")
        let genieImage = UIImage(named: "profile_genie")
        let rightImage = UIImage(named: "return_right")
        let leftImage = UIImage(named: "return_left")
        
        if index == 0 {
            let rightButtonItem = UIBarButtonItem(image: rightImage, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            rightButtonItem.tintColor = UIColor.whiteColor()
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 1 {
            let rightButtonItem = UIBarButtonItem(image: gridImage, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            (barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "a")
            rightButtonItem.tintColor = UIColor.whiteColor()
            
            let leftButtonItem = UIBarButtonItem(image: menuImage, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            leftButtonItem.tintColor = UIColor.whiteColor()
            
            let genieLogo = UIImageView(image: genieImage)
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("toProfileVC:"))
            genieLogo.userInteractionEnabled = true
            genieLogo.addGestureRecognizer(tapGestureRecognizer)
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.titleView = genieLogo
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 2 {
            let leftButtonItem = UIBarButtonItem(image: leftImage, style: UIBarButtonItemStyle.Plain, target: self, action: "a")
            leftButtonItem.tintColor = UIColor.whiteColor()
            
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