//
//  UserViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/14.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
class UserViewController:UIViewController,UIScrollViewDelegate{
    var nameCard:SettingCard!
    var scrollView:UIScrollView!
    var language:SettingCard!
    var sync:SettingCard!
    var account:SettingCard!
    class SettingCard:UIView{
        class func getSingleNameCard()->SettingCard{
            let view = SettingCard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.8))
            view.backgroundColor = UIColor.flatBlue
            
            let portrait = UIImageView(frame: CGRect(x: 0, y: view.bounds.height/4, width: 100, height: 100))
            portrait.setFAIconWithName(icon: .FAUserCircle, textColor: UIColor.lightGray)
            portrait.center.x = view.bounds.width/2
            view.addSubview(portrait)
            
            let username = UILabel(frame: CGRect(x: 0, y: view.bounds.height/4 + 100, width: view.bounds.width, height: 50))
            username.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
            username.center.x =  view.bounds.width/2
            view.addSubview(username)
            username.textColor = .white
            username.textAlignment = .center
            
            let userEmail = UILabel(frame: CGRect(x: 0, y: view.bounds.height/4*3, width: UIScreen.main.bounds.width, height: 50))
            userEmail.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
            userEmail.center.x = view.bounds.width/2
            userEmail.textColor = .white
            userEmail.textAlignment = .center
            view.addSubview(userEmail)
            
            if ifloggedin{
                username.text = loggedusername
                userEmail.text = loggedemail
                portrait.setFAIconWithName(icon: .FAUserCircle, textColor: UIColor.black)
                
            }else{
                username.text = ""
                userEmail.text = "Log in"
            }
            
            
            return view
        }
        
        class func getSingleSettingCard(title:String, action: (SettingCard)->())->SettingCard{
            let view = SettingCard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.48))
            view.backgroundColor = UIColor.flatWhite
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
            label.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
            label.textColor = .black
            label.text = title
            label.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
            label.textAlignment = .center
            view.addSubview(label)
            action(view)
            return view
        }
        
    }
    
   func logout(_ sender: Any) {
        ifloggedin = false
        UserDefaults.standard.set("", forKey: Constant.Key.Token)
        loggedusername = ""
        loggedID = ""
        loggedemail = ""
        performSegue(withIdentifier: "login", sender: "logout")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as! String == "logout"{
            (segue.destination as! SignUpController).former = "logout"
        }
    }
    
    override func viewDidLoad() {
      
        
        /**
         scrollView
         */
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.bounds.height))
        scrollView.delegate = self
        scrollView.contentSize.width = UIScreen.main.bounds.width
        scrollView.contentSize.height = 0
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = UIColor.flatBlue
        self.view.addSubview(scrollView)
        
        /**
         nameCard: username and email
         */
        nameCard = SettingCard.getSingleNameCard()
        let tapGesture = UITapGestureRecognizer()
        if !ifloggedin{
            tapGesture.addTarget(self, action: #selector(login))
        }else{
            tapGesture.addTarget(self, action: #selector(accountSetting))
        }
        nameCard.addGestureRecognizer(tapGesture)
        self.scrollView.addSubview(nameCard)
        self.scrollView.contentSize.height += nameCard.frame.height + 20
        
        /**
         language: language Setting
         */
        language = SettingCard.getSingleSettingCard(title: "Language", action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(languageSetting))
        })
        language.frame.origin.y = nameCard.frame.height + 20
        language.center.x = scrollView.bounds.width/2
        self.scrollView.addSubview(language)
        self.scrollView.contentSize.height += language.frame.height + 20
        
        
        /**
         sync
         */
        sync = SettingCard.getSingleSettingCard(title: "Sync", action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(syncSetting))
        })
        sync.frame.origin.y = language.frame.origin.y + language.frame.height + 20
        sync.center.x = scrollView.bounds.width/2
        self.scrollView.addSubview(sync)
        self.scrollView.contentSize.height += sync.frame.height + 20
        
        /**
         account
         */
        account = SettingCard.getSingleSettingCard(title: "Account Plan", action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(accountPlans))
        })
        account.frame.origin.y = sync.frame.origin.y + sync.frame.height + 20
        account.center.x = scrollView.bounds.width/2
        self.scrollView.addSubview(account)
        self.scrollView.contentSize.height += account.frame.height + 20
        
        
        
        
    }
    
    @objc func accountPlans(){
        
    }
    
    @objc func syncSetting(){
        
    }
    
    @objc func languageSetting(){
        
    }
    
    @objc func login(){
        self.performSegue(withIdentifier: "login", sender: "")
    }
    
    @objc func accountSetting(){
        self.performSegue(withIdentifier: "accountSetting", sender: "")
    }
    
    
}
