//
//  AppDelegate.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/1/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SpotSaver")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Could not load data store: \(error)")
            }
        })
        return container
    }()

    lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext


    // MARK: - UIApplicationDelegate
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Get reference to the Managed Object Context
        let tabVC = window?.rootViewController as! UITabBarController
        if let tabVCs = tabVC.viewControllers {
            // Tab #1
            var navVC = tabVCs[0] as! UINavigationController
            let vc1 = navVC.viewControllers.first as! CurrentLocationViewController
            vc1.managedObjectContext = managedObjectContext

            // Tab #2
            navVC = tabVCs[1] as! UINavigationController
            let vc2 = navVC.viewControllers.first as! DisplayLocationsTableViewController
            vc2.managedObjectContext = managedObjectContext
            let _ = vc2.view // Force vc to load view immediately when app starts instead of delaying until you switch tabs
            // The previous line fixes a huge bug.
            // Reproduce the bug -> 1) Quit App 2) Run app and tag a new location 3) Switch to locations tab 4) location doesnt appear 5) crash
            // Error message:  The persistent cache of section information does not match the current configuration.  You have illegally mutated the
            // NSFetchedResultsController's fetch request, its predicate, or its sort
            // descriptor without either disabling caching or using +deleteCacheWithName:

            // Tab #3
            navVC = tabVCs[2] as! UINavigationController
            let vc3 = navVC.viewControllers.first as! MapViewController
            vc3.managedObjectContext = managedObjectContext
        }

        print(applicationDocumentDirectory)
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }





    // MARK: - Helper
    func listenForFatalCoreDataNotifications() {
        // 1 Be notified whenever a CoreDataSaveFailedNotification is posted
        NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification, object: nil, queue: OperationQueue.main) { (notification) in

            let message =
            """
            There was a fatal error in the app and it cannot continue.
            Press OK to terminate the app. Sorry for the inconvenience.
            """

            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)

            // Terminate the app
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                exception.raise()
            })

            alert.addAction(action)

            // 5
            let tabVC = self.window!.rootViewController!
            tabVC.present(alert, animated: true)
        }
    }
}

