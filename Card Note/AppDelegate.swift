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
import GoogleMobileAds


var isFirstLaunch = true
var app_version = ""
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate{
    var window: UIWindow?
    var ad: GADAppOpenAd?
    var loadtime: Date?
    
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
        
     
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        // Unlock content
                        Constant.purchased = true
                    case .failed, .purchasing, .deferred:
                        break
                    }
                }
            }
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "714c8f5be61e48c3994b8480fe1f6f8c")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = Constant.Configuration.for_ever
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                    
                switch purchaseResult {
                case .purchased(let receiptItem):
                    print("\(productId) is purchased: \(receiptItem)")
                    UserDefaults.standard.set(true, forKey: "VIP")
                    
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
        
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
                case .success(let receipt):
                    var set = Set<String>()
                    set.insert(Constant.Configuration.one_month)
                    set.insert(Constant.Configuration.one_year)
                    let purchaseResult1 = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: set, inReceipt: receipt)
                   
                    let productId = Constant.Configuration.for_ever
                    // Verify the purchase of Consumable or NonConsumable
                    let purchaseResult2 = SwiftyStoreKit.verifyPurchase(
                        productId: productId,
                        inReceipt: receipt)
                        
                    switch purchaseResult1 {
                    case .purchased(let expiryDate, let items):
                        UserDefaults.standard.set(true, forKey: "VIP")
                    case .expired(let expiryDate, let items):
                        UserDefaults.standard.set(false, forKey: "VIP")
                    case .notPurchased:
                        break
                    }
                    
                    switch purchaseResult2 {
                    case .purchased:
                        UserDefaults.standard.set(true, forKey: "VIP")
                    case .notPurchased:
                       break
                    }

                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
        }
        
        
        //directory setting
        createDirectory()
        
        //if lauchedsetting
        isFirstLaunch = UserDefaults.standard.bool(forKey: "ifLauched")
        //let ifUpdateFirstLauch = isUpdateFirstLaunch()

        
        //setup ads
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "a5f3c997bb11c3f04951753dae5850f3" ]
        
        //set rest recognition
        let date = Date()
        let lastdate = UserDefaults.standard.object(forKey: "date") as? Date
        if(lastdate != nil){
            let day1 = date.get(.day)
            let day2 = lastdate!.get(.day)
            if(day1 > day2) {
                UserDefaults.standard.set(10, forKey: "num")
                UserDefaults.standard.set(Date(), forKey: "date")
            }
        } else {
            UserDefaults.standard.set(10, forKey: "num")
            UserDefaults.standard.set(Date(), forKey: "date")
        }
        
        
        if !isFirstLaunch{
        UserDefaults.standard.set(false, forKey: "VIP")
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
        if(!UserDefaults.standard.bool(forKey: "VIP")){
            trytoPresentAd()
        }
    }
    
    func requestOpenAd(){
        self.ad = nil
        GADAppOpenAd.load(withAdUnitID: "ca-app-pub-3940256099942544/5662855259", request: GADRequest.init(), orientation: .portrait) { ad, error in
            if(error != nil){
                print("failed to load the ad" + error!.localizedDescription)
                return
            }
            print("request ad success")
            self.ad = ad
            self.ad?.fullScreenContentDelegate = self
            self.loadtime = Date()
        }
    }
    
    func trytoPresentAd(){
        if(self.ad != nil && self.wasLoadTimeLessThanNHoursAgo(n: 4)){
            let root = topViewControllerWithRootViewController(rootViewController: window?.rootViewController)
            self.ad?.present(fromRootViewController: root!)
        } else {
            requestOpenAd()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("didFailToPresentFullScreenContentWithError" + error.localizedDescription)
        self.requestOpenAd()
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("presnet ad success")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("DidDismissFullScreenContent")
        self.requestOpenAd()
    }
    
    func wasLoadTimeLessThanNHoursAgo(n: Int) -> Bool{
        let now = Date()
        let time = now.timeIntervalSince(loadtime!)
        let second = 3600.0
        let intervalInhours = time / second
        return intervalInhours < Double(n)
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

