//
//  AppDelegate.swift
//  cocktail-assassin
//
//  Created by Sambya Aryasa on 20/1/15.
//  Copyright (c) 2015 tw. All rights reserved.
//

import UIKit
import CoreData
import iOSSharedViewTransition

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        let navigationController = self.window!.rootViewController as! UINavigationController
        
        ASFSharedViewTransition.addTransitionWithFromViewControllerClass(
            DrinksViewController.self,
            toViewControllerClass: DrinkDetailsViewController.self,
            withNavigationController: navigationController,
            withDuration: 0.5
        )

        ASFSharedViewTransition.addTransitionWithFromViewControllerClass(
            DrinkDetailsViewController.self,
            toViewControllerClass: PouringViewController.self,
            withNavigationController: navigationController,
            withDuration: 0.8
        )

        ASFSharedViewTransition.addTransitionWithFromViewControllerClass(
            PouringViewController.self,
            toViewControllerClass: DrinksViewController.self,
            withNavigationController: navigationController,
            withDuration: 0.5
        )

            
        return true
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.colharris.CocktailData" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("CocktailAssassin", withExtension: "momd")!
        NSLog("%@", modelURL)
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CocktailAssassin.sqlite")
        NSLog("%@", url)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error as NSError {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error")
                    abort()
                }
            }
        }
    }

    func supportedInterfaceOrientationsForWindow(window: UIWindow) -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
}

