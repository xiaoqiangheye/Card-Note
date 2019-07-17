//
//  AppDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/3/23.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import UIKit
import CoreData
import SwiftyStoreKit

var isFirstLaunch = true
var app_version = ""
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    var window: UIWindow?
    func createDirectory(){
        let array = [Constant.Configuration.url.attributedText,Constant.Configuration.url.Audio,Constant.Configuration.url.Card,Constant.Configuration.url.Movie,Constant.Configuration.url.PicCard]
        for url in array{
            if !FileManager.default.fileExists(atPath: url.path){
                do{
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                }catch let error{
                 print(error.localizedDescription)
                }
            }
        }
    }
    
    func isUpdateFirstLaunch() -> Bool {
        //获取版本号
        let app_version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        //上次存储的版本号
        let save_version = UserDefaults.standard.object(forKey: "isFirstIntobs") as? String
        
        //方法2：
        if app_version == save_version {
            return false
        } else if save_version != nil{
            UserDefaults.standard.setValue(app_version, forKey: "isFirstIntobs")
            UserDefaults.standard.synchronize()
            return true
        } else{
            UserDefaults.standard.setValue(app_version, forKey: "isFirstIntobs")
            UserDefaults.standard.synchronize()
            return false
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Override point for customization after application launch.
        
        
        print("Start Initialization")
        //version
        app_version = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
        print("Version: " + app_version)
        
     
        
        
        //directory setting
        createDirectory()
        
        //if lauchedsetting
        isFirstLaunch = UserDefaults.standard.bool(forKey: "ifLauched")
        //let ifUpdateFirstLauch = isUpdateFirstLaunch()

        
        if !isFirstLaunch{
        UserDefaults.standard.set(true, forKey: Constant.Key.ifLauched)
        let tags = [String]()
        UserDefaults.standard.set(tags, forKey: Constant.Key.Tags)
            //other setting
            //auto sync closed
            UserDefaults.standard.set(false, forKey: Constant.Key.AutoSync)
            //auto sync if Wifi presents closed
            UserDefaults.standard.set(false, forKey: Constant.Key.SyncWithWifi)
           
            
            let manager = FileManager.default
            var url = Constant.Configuration.url.Card
            url.appendPathComponent("first.card")
            let orientation = orientationCard()
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:orientation as Any)
            do{
                try datawrite.write(to: url)
            }catch{
                print("fail to add")
            }
         
        }else{
            let tags = UserDefaults.standard.array(forKey: Constant.Key.Tags)
            if tags == nil{
                let tags = [String]()
                UserDefaults.standard.set(tags, forKey: Constant.Key.Tags)
            }
        }
        
        return true
    }
    
    private func orientationCard()->Card{
        let newOrientationCard = Card(title: "Your First Card", tag: nil, description: "", id: "first", definition: "Welcome to Canote!", color: Constant.Color.blueLeft, cardType: Card.CardType.card.rawValue, modifytime: String(NSTimeIntervalSince1970))
        
        let textCard = TextCard(id: UUID().uuidString)
        textCard.setText(attr: NSAttributedString(string: "Now Let's get started! In this Card, you can add many forms of subcards you like, which includes Photos, Voices, Videos, Text, and Key Term. Those multimedia helps you record anything wherever you are.\n\n Click the float \"+\" Button on the right, and you can select the types of media you want to add."))
        newOrientationCard.addChildNote(textCard)
        
        let exaCard = ExampleCard(key: "First Term", value: "This is an Key-Value card for you to take notes. In classes, you can write important terms into this card. The key is the term and the value is the definition of the term.")
        newOrientationCard.addChildNote(exaCard)
        
        return newOrientationCard
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: Selector(("canRotate")))) {
                // Unlock landscape view orientations for this view controller if it is not currently being dismissed
                if !rootViewController.isBeingDismissed{
                    return .landscape
                }
            }
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: (UITabBarController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of:(UINavigationController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Card_Note")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

