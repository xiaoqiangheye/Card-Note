//
//  AppDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/3/23.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import UIKit
import CoreData
import AMapFoundationKit
import QCloudCore
import QCloudCOSXML
import SwiftyStoreKit

var ifloggedin = false
var loggedusername = ""
var loggedemail = ""
var loggedID = ""
var emailVerification = ""
var signUpEmail = ""
var signUpPassword = ""
var signUpUsername = ""
var signUpAuthCode = ""
var isFirstLaunch = true
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, QCloudSignatureProvider,BMKGeneralDelegate,BMKLocationAuthDelegate{
    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        let credential = QCloudCredential()
        credential.secretID = Bundle.main.infoDictionary?["QCloudSecretID"] as! String
        credential.secretKey = Bundle.main.infoDictionary?["QCloudSecretKey"] as! String
        let creation = QCloudAuthentationV5Creator.init(credential: credential)
        let sig = creation?.signature(forData: urlRequst)
        continueBlock(sig,nil)
    }
    
    var window: UIWindow?
    func createDirectory(){
        let array = [Constant.Configuration.url.attributedText,Constant.Configuration.url.Audio,Constant.Configuration.url.Card,Constant.Configuration.url.Map,Constant.Configuration.url.Movie,Constant.Configuration.url.PicCard]
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
        
        /*方法1：
         if save_version == nil || !(app_version == save_version) {
         UserDefaults.standard.setValue(app_version, forKey: "isFirst")
         UserDefaults.standard.synchronize()
         return true
         } else {
         return false
         }*/
        
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Tencent Cloud
      let configuration = QCloudServiceConfiguration()
        configuration.appID = "1253464939"
       configuration.signatureProvider = self
        let endpoint = QCloudCOSXMLEndPoint()
        endpoint.regionName = "ap-chengdu"
        configuration.endpoint = endpoint
        QCloudCOSXMLService.registerDefaultCOSXML(with: configuration)
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: configuration)
        
        
        //called complete transactions
        SwiftyStoreKit.completeTransactions { (purchase) in
            
        }
        
        //map setting
        //gao de
        /* temporarily banned
        AMapServices.shared().apiKey = "cd1079b6f89a637f97e367d5b2baa101"
        let mapManager = BMKMapManager()
         BMKLocationAuth.sharedInstance()?.checkPermision(withKey: "gB7SGt9F65EgmkiWWcaHtLaxssYpyCLx", authDelegate: self)
        //Baidu
        let ret = mapManager.start("gB7SGt9F65EgmkiWWcaHtLaxssYpyCLx", generalDelegate: self)
        if ret == false {
            NSLog("manager start failed!")
        }
        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORD_TYPE.COORDTYPE_BD09LL) {
            NSLog("经纬度类型设置成功");
        } else {
            NSLog("经纬度类型设置失败");
        }
        */
        
        //directory setting
        createDirectory()
        
        //if lauchedsetting
        isFirstLaunch = UserDefaults.standard.bool(forKey: "ifLauched")
        let ifUpdateFirstLauch = isUpdateFirstLaunch()
        if ifUpdateFirstLauch{
            //add some settings
        }
        
        if !isFirstLaunch{
        UserDefaults.standard.set(true, forKey: Constant.Key.ifLauched)
            let tags = [String]()
        UserDefaults.standard.set(tags, forKey: Constant.Key.Tags)
            //other setting
            //auto sync opened
            UserDefaults.standard.set(true, forKey: Constant.Configuration.Cloud.AUTO_SYNC)
            //auto sync if Wifi presents
            UserDefaults.standard.set(true, forKey: Constant.Configuration.Cloud.SYNC_ONLY_WITH_WIFI)
            //account Plan
            UserDefaults.standard.set(Constant.AccountPlan.basic.rawValue,forKey: "accountPlan")
            //create a new clasic card
            
            let newOrientationCard = Card(title: "Your First Card", tag: nil, description: "", id: "first", definition: "Start your first trip", color: Constant.Color.blueLeft, cardType: Card.CardType.card.rawValue, modifytime: String(NSTimeIntervalSince1970))
           let exaCard = ExampleCard(key: "First Term", value: "This is an Key-Value card for you to take notes. In classes, you can write important terms into this card. The key is the term and the value is the definition of the term.")
            newOrientationCard.addChildNote(exaCard)
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent("card.txt")
            
            var cardList = [Card]()
            cardList.append(newOrientationCard)
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList as Any)
            do{
                try datawrite.write(to: url!)
            }catch{
                print("fail to add")
            }
           // PurchaseManager.restore()
        }else
        {
            let tags = UserDefaults.standard.array(forKey: Constant.Key.Tags)
            if tags == nil{
                let tags = [String]()
                UserDefaults.standard.set(tags, forKey: Constant.Key.Tags)
            }
           PurchaseManager.verifySubscriptions(types: PurchaseManager.products)
        }
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
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

