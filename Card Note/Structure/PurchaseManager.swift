//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/11.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import SwiftMessages

class PurchaseManager{
    enum Product:String{
        case premium_one_month = "com.cardnote.premium_1_month"
        case premium_6_months = "com.cardnote.premium_six_months"
        case premium_12_months = "com.cardnote.premium_one_year"
    }
    
    
    
    static var products:Set<String> = [Product.premium_12_months.rawValue,Product.premium_6_months.rawValue,Product.premium_one_month.rawValue]
    
    class func purchase(type:Product){
        SwiftyStoreKit.purchaseProduct(type.rawValue, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from the server
                verifySubscription(type: type)
                if product.needsFinishTransaction{
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                break
            case .error(let error):
                print("Purchase Failed: \(error)")
                break
            }
        }
    }
    
    class func retriveInfo(type:Product, completionHandler:@escaping (SKProduct?)->()){
        SwiftyStoreKit.retrieveProductsInfo([type.rawValue]) { (result) in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                completionHandler(product)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
                  completionHandler(nil)
            }
            else {
                print("Error: \(result.error)")
                  completionHandler(nil)
            }
        }
    }
    
    class func verifySubscriptions(types:Set<String>){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constant.Configuration.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                var productIds = types
               
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productIds: productIds,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    UserDefaults.standard.set(Constant.AccountPlan.premium.rawValue, forKey: "accountPlan")
                    UserDefaults.standard.set(expiryDate, forKey: "expiryDate")
                    UserDefaults.standard.synchronize()
                    Constant.Configuration.AccountPlan = Constant.AccountPlan.premium.rawValue
                    print("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                    
                    if UserDefaults.standard.bool(forKey: "auto-sync") && isPremium(){
                        sync { (ifSuccess) in
                            if ifSuccess{
                                 AlertView.show(success: "Sync Success")
                            }else{
                                AlertView.show(error: "Sync Failed")
                            }
                        }
                    }
                case .expired(let expiryDate, let items):
                    UserDefaults.standard.set(Constant.AccountPlan.basic.rawValue, forKey: "accountPlan")
                    Constant.Configuration.AccountPlan = Constant.AccountPlan.basic.rawValue
                    UserDefaults.standard.synchronize()
                    print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productIds)")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    class func verifySubscription(type:Product){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constant.Configuration.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = type.rawValue
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    UserDefaults.standard.set(Constant.AccountPlan.premium.rawValue, forKey: "accountPlan")
                    UserDefaults.standard.set(expiryDate, forKey: "expiryDate")
                    UserDefaults.standard.synchronize()
                    Constant.Configuration.AccountPlan = Constant.AccountPlan.premium.rawValue
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    UserDefaults.standard.set(Constant.AccountPlan.basic.rawValue, forKey: "accountPlan")
                     Constant.Configuration.AccountPlan = Constant.AccountPlan.basic.rawValue
                    UserDefaults.standard.synchronize()
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    class func restore(){
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                for purchase in results.restoredPurchases{
                    verifySubscription(type: PurchaseManager.Product(rawValue: purchase.productId)!)
                }
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    
}
