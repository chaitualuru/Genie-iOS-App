//
//  AppDelegate.swift
//  Genie
//
//  Created by Krishna Chaitanya Aluru on 8/23/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import VerifyIosSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let ref = Firebase(url: "https://getgenie.firebaseio.com")

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // setup Nexmo --------------------------------------------------------------------------

        NexmoClient.start(applicationId: "5b7f809d-393c-4afb-b105-436bf28a405b", sharedSecretKey: "addde0ffcbdd6be")
        
        // --------------------------------------------------------------------------------------
        
        // set initial view controller ----------------------------------------------------------
        if self.ref.authData != nil {
//            print("user authenticated: ", self.ref.authData, "loading home view")
            
            // setup remote notifications --------------------------------------------------------------
            switch(getMajorSystemVersion()) {
            case 7:
                application.registerForRemoteNotificationTypes([.Alert, .Sound])
                application.registerForRemoteNotifications()
            default:
                let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
                application.registerUserNotificationSettings(notificationSettings)
                application.registerForRemoteNotifications()
            }
            // --------------------------------------------------------------------------------------
        
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window!.rootViewController = MySwipeVC()
            window!.makeKeyAndVisible()
        }
        else {
//            print("No user signed in, loading intro view")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("entryView")
        }

        // --------------------------------------------------------------------------------------

        
        return true
    }
    
    // successfully registered for push
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let trimEnds = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        let cleanToken = trimEnds.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if self.ref.authData != nil {
            let userRef = self.ref.childByAppendingPath("users/" + self.ref.authData.uid)
            userRef.updateChildValues([
                "device_token": cleanToken
                ])
        }
    }
    
    // Failed to register for Push
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        NSLog("Failed to get token; error: %@", error) //Log an error for debugging purposes, user doesn't need to know
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        if self.ref.authData != nil {
            let userRef = self.ref.childByAppendingPath("users/" + self.ref.authData.uid)
            userRef.updateChildValues([
                "application_state": 0
                ])
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        if self.ref.authData != nil {
            let userRef = self.ref.childByAppendingPath("users/" + self.ref.authData.uid)
            userRef.updateChildValues([
                "application_state": -1
                ])
        }
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if self.ref.authData != nil {
            let userRef = self.ref.childByAppendingPath("users/" + self.ref.authData.uid)
            userRef.updateChildValues([
                "application_state": 0
                ])
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if self.ref.authData != nil {
            let userRef = self.ref.childByAppendingPath("users/" + self.ref.authData.uid)
            userRef.updateChildValues([
                "application_state": 1
            ])
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if self.ref.authData != nil {
            let userRef = self.ref.childByAppendingPath("users/" + self.ref.authData.uid)
            userRef.updateChildValues([
                "application_state": -2
                ])
        }
        
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func getMajorSystemVersion() -> Int {
        return Int(UIDevice.currentDevice().systemVersion.componentsSeparatedByString(".")[0])!
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.getgenie.Genie" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Genie", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

