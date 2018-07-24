//
//  PremiumController.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/11.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
class PremiumController:UIViewController{
    var titleLabel:UILabel!
    var backButton:UIButton!
    var advantageView:UIView!
    var one_month_price:String = "¥12"
    var six_month_price:String = "¥60"
    var year_price:String = "¥108"
    private let ADVANTAGE_PREMIUM = ["Limitless Notes", "Limitless Time for voice record", "Cloud Storage", "Auto-Sync", "Limitless Devices", "Translation across different languages", "Voice, Photo, Video Record" ,"Voice to Text Conversion","Map Record"]
    override func viewDidLoad() {
        //backButton
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
        
        //titleLabel
        titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 30))
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.text = "Professional"
        advantageView = UIView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 400))
        advantageView.backgroundColor = .flatWhite
        self.hero.isEnabled = true
        self.view.hero.id = "premium"
        self.view.addSubview(titleLabel)
        self.view.addSubview(advantageView)
        self.view.backgroundColor = UIColor.flatPurple
        titleLabel.text = "Professional"
        var cumulatedHeight = 0
        for advantage in ADVANTAGE_PREMIUM{
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont(name: "ChalkboardSE-Light", size: 15)
            label.text = advantage
            label.numberOfLines = 3
            label.backgroundColor = UIColor.flatWhite
            label.lineBreakMode = .byWordWrapping
            label.frame.size.height = UILabel.heightWithConstrainedWidth(width: UIScreen.main.bounds.width * 0.8, font: label.font, str: label.text as! NSString) + 20
            label.frame.origin.y = CGFloat(cumulatedHeight)
            cumulatedHeight += Int(label.frame.height)
            advantageView.addSubview(label)
        }
        
        
        //purchase Button
         let One_month_button = UIButton(frame: CGRect(x: 0, y: advantageView.frame.origin.y + advantageView.frame.height + 20, width: UIScreen.main.bounds.width * 0.8, height: 50))
        One_month_button.backgroundColor = UIColor.purple
        One_month_button.addTarget(self, action: #selector(self.purchaseOneMonth), for: .touchDown)
        One_month_button.center.x = UIScreen.main.bounds.width/2
        One_month_button.setTitle(self.one_month_price + "/month", for: .normal)
         let six_months_button = UIButton(frame: CGRect(x: 0, y: One_month_button.frame.origin.y + One_month_button.frame.height + 20, width: UIScreen.main.bounds.width * 0.8, height: 50))
        six_months_button.backgroundColor = UIColor.purple
        six_months_button.addTarget(self, action: #selector(self.purchaseSixMonths), for: .touchDown)
        six_months_button.center.x = UIScreen.main.bounds.width/2
            six_months_button.setTitle(self.six_month_price + "/6 months", for: .normal)
        let year_button = UIButton(frame: CGRect(x: 0, y: six_months_button.frame.origin.y + six_months_button.frame.height + 20, width: UIScreen.main.bounds.width * 0.8, height: 50))
        year_button.addTarget(self, action: #selector(self.purchaseYear), for: .touchDown)
        year_button.backgroundColor = UIColor.purple
        year_button.center.x = UIScreen.main.bounds.width/2
          year_button.setTitle(self.year_price + "/year" as String, for: .normal)
        PurchaseManager.retriveInfo(type:PurchaseManager.Product.premium_one_month) { (product) in
            if product != nil{
                self.one_month_price = (product?.localizedPrice)!
                One_month_button.setTitle(self.one_month_price + "/month", for: .normal)
               
            }
        }
        PurchaseManager.retriveInfo(type:PurchaseManager.Product.premium_6_months) { (product) in
            if product != nil{
                self.six_month_price = (product?.localizedPrice)!
               
                six_months_button.setTitle(self.six_month_price + "/6 months", for: .normal)
               
            }
        }
        PurchaseManager.retriveInfo(type:PurchaseManager.Product.premium_12_months) { (product) in
            if product != nil{
                self.year_price = (product?.localizedPrice)!
                
                year_button.setTitle(self.year_price + "/year" as String, for: .normal)
               
            }
        }
        
        self.view.addSubview(One_month_button)
        self.view.addSubview(six_months_button)
        self.view.addSubview(year_button)
    }
    
    @objc private func purchaseOneMonth(){
        PurchaseManager.purchase(type: .premium_one_month)
    }
    
    @objc private func purchaseSixMonths(){
        PurchaseManager.purchase(type: .premium_6_months)
    }
    
    @objc private func purchaseYear(){
        PurchaseManager.purchase(type: .premium_12_months)
    }
    
    @objc private func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
}
