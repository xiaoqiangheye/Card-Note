//
//  AccountPlanController.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/10.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift


class AccountPlanController:UIViewController,UIScrollViewDelegate{
    var scrollView:UIScrollView!
    var titleLabel:UILabel!
    var backButton:UIButton!
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        //set up the scrollView
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: UIScreen.main.bounds.height)
        scrollView.delegate = self
         self.hero.isEnabled = true
        //set up the account plan page
        let basicView = AccountPlanView(plan: .basic)
        basicView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        scrollView.addSubview(basicView)
        
        let premiumView = AccountPlanView(plan: .premium)
        premiumView.hero.id = "premium"
        premiumView.center = CGPoint(x: UIScreen.main.bounds.width + UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(premiumTaped))
        premiumView.addGestureRecognizer(tapGesture)
        scrollView.addSubview(premiumView)
        
        //adjust scrollView width
        scrollView.contentSize.width = UIScreen.main.bounds.width * 2
        scrollView.contentSize.height = UIScreen.main.bounds.height
        
        switch Constant.Configuration.AccountPlan{
        case PurchaseManager.Product.premium_one_month.rawValue:
            scrollView.contentOffset.x = UIScreen.main.bounds.width
        case PurchaseManager.Product.premium_6_months.rawValue:
            scrollView.contentOffset.x = UIScreen.main.bounds.width
        case PurchaseManager.Product.premium_12_months.rawValue:
            scrollView.contentOffset.x = UIScreen.main.bounds.width
        case "basic": break
        default:
            break
        }
        self.view.addSubview(scrollView)
        
        //set up the decoration
        titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = "Account Plan"
        self.view.addSubview(titleLabel)
        
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func premiumTaped(){
        let premium = PremiumController()
        self.present(premium, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}
