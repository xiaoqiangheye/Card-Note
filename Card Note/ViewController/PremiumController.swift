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
    var one_month_price:String = "¥12.00"
    var six_month_price:String = "¥60.00"
    var year_price:String = "¥108.00"
    private var logo:UIImageView!
    private var termOfServiecTextView:UITextView!
    private let TERM_OF_SERVICE = "* Please note that The Premium Plan is a subscription that will be renewed automatically unless you turn off auto-renew 24 hours before the end of the period. If you want to cancel the subscription, please turn off subscription 24 hours before the period ends, or the period will be renewed and you will be charged. If you cancel the current period, the period will automatically ends on the end date, and the period will not be renewed."
    private let ADVANTAGE_PREMIUM = ["Limitless Notes", "Limitless Time for voice record", "Cloud Storage", "Auto-Sync", "Limitless Devices", "Translation across different languages", "Voice, Photo, Video Record" ,"Voice to Text Conversion"]
    override func viewDidLoad() {
        //backButton
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FATimes, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
        
        
        //logo
        logo = UIImageView(frame: CGRect(x: 0, y: 50, width: 30, height: 30))
        logo.image = UIImage(named: "white_version_logo")
        logo.center.x = self.view.frame.width/2
        self.view.addSubview(logo)
        
        //titleLabel
        titleLabel = UILabel(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 30))
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.text = "Go Premium!"
        advantageView = UIView(frame: CGRect(x: 0, y: 120, width: UIScreen.main.bounds.width, height: 160))
        advantageView.backgroundColor = .clear
        
        
        self.hero.isEnabled = true
        self.view.hero.id = "premium"
        self.view.addSubview(titleLabel)
        self.view.addSubview(advantageView)
        self.view.backgroundColor = UIColor.flatPurple
        
        var cumulatedHeight = 0
        for advantage in ADVANTAGE_PREMIUM{
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont(name: "ChalkboardSE-Light", size: 15)
            label.text = advantage
            label.numberOfLines = 3
            label.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.2)
            label.lineBreakMode = .byWordWrapping
            label.frame.size.height = UILabel.heightWithConstrainedWidth(width: UIScreen.main.bounds.width * 0.8, font: label.font, str: label.text! as NSString) + 20
            label.frame.origin.y = CGFloat(cumulatedHeight)
            cumulatedHeight += Int(label.frame.height)
            advantageView.frame.size.height = CGFloat(cumulatedHeight)
            advantageView.addSubview(label)
        }
        
        termOfServiecTextView = UITextView(frame: CGRect(x: 0, y: advantageView.frame.height + advantageView.frame.origin.y, width: UIScreen.main.bounds.width * 0.8, height: 150))
        termOfServiecTextView.font = UIFont.systemFont(ofSize: 10)
        termOfServiecTextView.textColor = Constant.Color.darkWhite
        termOfServiecTextView.text = TERM_OF_SERVICE
        termOfServiecTextView.backgroundColor = .clear
        termOfServiecTextView.center.x = self.view.frame.width/2
        termOfServiecTextView.frame.size.height = termOfServiecTextView.contentSize.height
         self.view.addSubview(termOfServiecTextView)
        
        
        
        //purchase Button
         let One_month_button = UIButton(frame: CGRect(x: 0, y:termOfServiecTextView.frame.origin.y + termOfServiecTextView.frame.height + 20, width: 100, height: 100))
        One_month_button.titleLabel?.numberOfLines = 2
        One_month_button.titleLabel?.textAlignment = .center
        One_month_button.backgroundColor = .white
        One_month_button.addTarget(self, action: #selector(self.purchaseOneMonth), for: .touchDown)
        One_month_button.center.x = UIScreen.main.bounds.width/6*1
        One_month_button.setTitle(self.one_month_price + "/MONTH", for: .normal)
        One_month_button.layer.cornerRadius = 15
        One_month_button.setTitleColor(.black, for: .normal)
         let six_months_button = UIButton(frame: CGRect(x: 0, y:termOfServiecTextView.frame.origin.y + termOfServiecTextView.frame.height + 20, width: 100, height: 100))
        six_months_button.titleLabel?.numberOfLines = 2
        six_months_button.titleLabel?.textAlignment = .center
        six_months_button.backgroundColor = .white
        six_months_button.addTarget(self, action: #selector(self.purchaseSixMonths), for: .touchDown)
        six_months_button.center.x = UIScreen.main.bounds.width/6*3
        six_months_button.setTitle(self.six_month_price + "/HALF YEAR", for: .normal)
        six_months_button.layer.cornerRadius = 15
        six_months_button.setTitleColor(.black, for: .normal)
        let year_button = UIButton(frame: CGRect(x: 0, y: termOfServiecTextView.frame.origin.y + termOfServiecTextView.frame.height + 20, width: 100, height: 100))
        year_button.addTarget(self, action: #selector(self.purchaseYear), for: .touchDown)
        year_button.titleLabel?.numberOfLines = 2
        year_button.titleLabel?.textAlignment = .center
        year_button.backgroundColor = .white
        year_button.center.x = UIScreen.main.bounds.width/6*5
        year_button.setTitle(self.year_price + "/YEAR", for: .normal)
        year_button.setTitleColor(.black, for: .normal)
        year_button.layer.cornerRadius = 15
        
        PurchaseManager.retriveInfo(type:PurchaseManager.Product.premium_one_month) { (product) in
            if product != nil{
                self.one_month_price = (product?.localizedPrice)!
                One_month_button.setTitle(self.one_month_price + "/MOHTH", for: .normal)
               
            }
        }
        PurchaseManager.retriveInfo(type:PurchaseManager.Product.premium_6_months) { (product) in
            if product != nil{
                self.six_month_price = (product?.localizedPrice)!
               
                six_months_button.setTitle(self.six_month_price + "/HALF YEAR", for: .normal)
               
            }
        }
        PurchaseManager.retriveInfo(type:PurchaseManager.Product.premium_12_months) { (product) in
            if product != nil{
                self.year_price = (product?.localizedPrice)!
                
                year_button.setTitle(self.year_price + "/YEAR", for: .normal)
               
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
