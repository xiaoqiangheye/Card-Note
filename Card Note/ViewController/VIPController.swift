//
//  VIPController.swift
//  Card Note
//
//  Created by Wei Wei on 7/16/21.
//  Copyright © 2021 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

class PricePresenterView:UIView{
    private var label:UILabel!
    private var price:UILabel!
    
    init(title:String, price: String){
        super.init(frame: CGRect(x: 0, y: 0, width: 125, height: 125))
        self.backgroundColor = .white
        self.layer.borderColor = CGColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        label.text = title
        label.textColor = .black
        label.textAlignment = .center
        self.price = UILabel(frame: CGRect(x:0, y: 50, width: self.frame.width, height: 50))
        self.price.text = price
        self.price.font = UIFont.boldSystemFont(ofSize: 20)
        self.price.textColor = Constant.Color.themeColor
        self.price.textAlignment = .center
        self.addSubview(label)
        self.addSubview(self.price)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}

class VIPController:UIViewController{
    private var label:UILabel!
    private let one_month = "com.wei.cardnote.one_month"
    private let one_year = "com.wei.cardnote.one_year"
    private let forever = "com.wei.cardnote.forever"
    private var one_month_label:PricePresenterView!
    private var one_year_label:PricePresenterView!
    private var forever_label:PricePresenterView!
    private var privilege:UITextView!
    private var purchaseButton:UIButton!
    private var selecteed: Purchased = .one_year
    private var restorePurchase:UIButton!
    enum Purchased:String{
        case one_month = "com.wei.cardnote.one_month"
        case one_year = "com.wei.cardnote.one_year"
        case forever = "com.wei.cardnote.forever"
    }
    
    
    @objc func purchase(){
            let vc = LoadingViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false) {
            
        }
            SwiftyStoreKit.purchaseProduct(selecteed.rawValue) { result in
            switch result{
            case .success(purchase: let product):
                //purchase success
                UserDefaults.standard.set(true, forKey: "VIP")
                vc.dismiss(animated: false) {
                }
            case .error(error: let error):
                vc.dismiss(animated: false) {
                }
                print("purchase failed")
            }
        }
    }
    
    @objc func restore(){
        let vc = LoadingViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false) {}
        SwiftyStoreKit.restorePurchases { results in
            if results.restoreFailedPurchases.count > 0 {
                    print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                UserDefaults.standard.set(true, forKey: "VIP")
                    print("Restore Success: \(results.restoredPurchases)")
                
            } else {
                    print("Nothing to Restore")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        //self setting
        self.view.backgroundColor = .white
        
        
        
        //a title
        label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        label.center.x = self.view.center.x
        label.textColor = .black
        label.text = NSLocalizedString("VIP", comment: "")
        label.textAlignment = .center
        label.backgroundColor = .white
        self.view.addSubview(label)
        
        //UITextView
        privilege = UITextView(frame: CGRect(x: 0, y: 250, width: self.view.frame.width * 0.8, height: 200))
        privilege.text = NSLocalizedString("privilege", comment: "")
        privilege.backgroundColor = .white
        privilege.textAlignment = .center
        privilege.textColor = .gray
        privilege.center.x = self.view.frame.width/2
        
        self.view.addSubview(privilege)
        
        //purchase
        purchaseButton = UIButton(frame: CGRect(x: 0, y: 500, width: 100, height: 50))
        purchaseButton.setTitle(NSLocalizedString("purchase", comment: ""), for: .normal)
        purchaseButton.addTarget(self, action: #selector(purchase), for: .touchDown)
        purchaseButton.center.x = self.view.frame.width/2
        purchaseButton.backgroundColor = Constant.Color.themeColor
        purchaseButton.layer.cornerRadius = 20
        
        
        //purchase
        restorePurchase = UIButton(frame: CGRect(x: 0, y: 570, width: 100, height: 50))
        restorePurchase.setTitle(NSLocalizedString("restore", comment: ""), for: .normal)
        restorePurchase.addTarget(self, action: #selector(restore), for: .touchDown)
        restorePurchase.center.x = self.view.frame.width/2
        restorePurchase.backgroundColor = Constant.Color.themeColor
        restorePurchase.layer.cornerRadius = 20
        
        
        
        self.view.addSubview(purchaseButton)
        self.view.addSubview(restorePurchase)
        let gap = (self.view.frame.width - 125*3)/2
        
        SwiftyStoreKit.retrieveProductsInfo([one_month, one_year, forever]) {[self] results in
            let products = results.retrievedProducts
            for product in products{
                if(product.productIdentifier == Purchased.one_month.rawValue){
                    self.one_month_label = PricePresenterView(title: NSLocalizedString("one_month", comment: ""), price: product.localizedPrice! + "/" + NSLocalizedString("month", comment: ""))
                    let one_month_gesture = UITapGestureRecognizer(target: self, action: #selector(self.select_one_month))
                    self.one_month_label.frame.origin = CGPoint(x: 0, y: 100)
                    self.one_month_label.addGestureRecognizer(one_month_gesture)
                    self.view.addSubview(self.one_month_label)
                } else if(product.productIdentifier == Purchased.one_year.rawValue){
                    let string = product.localizedPrice! + "/" + NSLocalizedString("year", comment: "")
                    self.one_year_label = PricePresenterView(title: NSLocalizedString("one_year", comment: ""), price:string)
                    let one_year_gesture = UITapGestureRecognizer(target: self, action: #selector(self.select_one_year))
                    self.one_year_label.frame.origin = CGPoint(x: gap + 125, y: 100)
                    self.one_year_label.addGestureRecognizer(one_year_gesture)
                    self.view.addSubview(self.one_year_label)
                } else if(product.productIdentifier == Purchased.forever.rawValue){
                    self.forever_label = PricePresenterView(title: NSLocalizedString("forever", comment: ""), price: product.localizedPrice!)
                    self.forever_label.frame.origin = CGPoint(x: gap*2 + 125*2, y: 100)
                    let forever_gesture = UITapGestureRecognizer(target: self, action: #selector(self.select_forever))
                    self.forever_label.addGestureRecognizer(forever_gesture)
                    self.view.addSubview(self.forever_label)
                }
            }
            self.select_one_year()
        }
    }
    
    @objc private func select_one_month(){
        selecteed = .one_month
        one_month_label.backgroundColor = UIColor(red: 100, green: 100, blue: 100, alpha: 0.3)
        one_year_label.backgroundColor = .white
        forever_label.backgroundColor = .white
    }
    
    @objc private func select_one_year(){
        selecteed = .one_year
        one_year_label.backgroundColor = UIColor(red: 100, green: 100, blue: 100, alpha: 0.3)
        one_month_label.backgroundColor = .white
        forever_label.backgroundColor = .white
    }
    
    @objc private func select_forever(){
        selecteed = .forever
        forever_label.backgroundColor = UIColor(red: 100, green: 100, blue: 100, alpha: 0.3)
        one_month_label.backgroundColor = .white
        one_year_label.backgroundColor = .white
    }
}
