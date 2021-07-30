//
//  ProductManager.swift
//  Card Note
//
//  Created by Wei Wei on 7/15/21.
//  Copyright © 2021 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyStoreKit



class ProductManager{
    static var one_month = "com.wei.cardnote.one_month"
    static var one_year = "com.wei.cardnote.one_year"
    static var for_ever = "com.wei.cardnote.forever"
    
    class func purchase(id:String){
        SwiftyStoreKit.purchaseProduct("id", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    class func purchaseForEver(){
        ProductManager.purchase(id: for_ever)
    }
    
    class func purchaseOneMonth(){
        ProductManager.purchase(id: one_month)
    }
    
    class func purchaseOneYear(){
        ProductManager.purchase(id: one_year)
    }
    
}
