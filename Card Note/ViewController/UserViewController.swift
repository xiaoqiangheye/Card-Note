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
import MessageUI
class UserViewController:UIViewController,UIScrollViewDelegate{
    var nameCard:SettingCard!
    var scrollView:UIScrollView!
    var language:SettingCard!
    var sync:SettingCard!
    var account:SettingCard!
    var help:SettingCard!
    var aboutUs:SettingCard!
    var rateUs:SettingCard!
    var TermofUse:SettingCard!
    var backGround:UIView!
    var tag:SettingCard!
    var version:SettingCard!
    
    
    var mailController:MFMailComposeViewController?
    class SettingCard:UIView{
        var imageView:UIImageView!
        class func getSingleNameCard()->SettingCard{
            let view = SettingCard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.8))
            view.backgroundColor = UIColor.white
            
            let portrait = UIImageView(frame: CGRect(x: 0, y: view.bounds.height/4, width: 100, height: 100))
            portrait.setFAIconWithName(icon: .FAUserCircle, textColor: UIColor.lightGray)
            portrait.center.x = view.bounds.width/2
            view.addSubview(portrait)
            
            let username = UILabel(frame: CGRect(x: 0, y: view.bounds.height/4 + 100, width: view.bounds.width, height: 50))
            username.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
            username.center.x =  view.bounds.width/2
            view.addSubview(username)
            username.textColor = .black
            username.textAlignment = .center
            
            let userEmail = UILabel(frame: CGRect(x: 0, y: view.bounds.height/4*3, width: UIScreen.main.bounds.width, height: 50))
            userEmail.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
            userEmail.center.x = view.bounds.width/2
            userEmail.textColor = .black
            userEmail.textAlignment = .center
            view.addSubview(userEmail)
            
            
            
            
            return view
        }
        
        class func getSingleSettingCard(title:String, action: (SettingCard)->())->SettingCard{
            let view = SettingCard(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 50))
            view.backgroundColor = UIColor.randomFlat
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: view.backgroundColor!, isFlat: true)
            label.text = title
            label.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
            label.textAlignment = .center
            view.addSubview(label)
            
            action(view)
            return view
        }
        
        class func getSingleSettingCard(color:UIColor,title:String, icon:UIImage,action: (SettingCard)->())->SettingCard{
            let view = SettingCard(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            view.backgroundColor = color
            view.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            view.imageView.center.x = view.frame.width/2
            view.imageView.center.y = view.frame.height/2
            view.imageView.image = icon
            view.addSubview(view.imageView)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = UIColor.flatGray
            label.text = title
            label.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2 + 50)
            label.textAlignment = .center
            view.addSubview(label)
            
            view.layer.cornerRadius = 10
          //  view.backgroundColor = Constant.Color.darkWhite
            //view.addBottomLine()
            action(view)
            return view
        }
        
    }
    
   
    

    
    override func viewDidLoad() {
        self.view.backgroundColor = Constant.Color.blueWhite
        
        //layer
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:CGFloat(UIDevice.current.Xdistance()) + 60);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        
        //title
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: gl.frame.height/2))
        titleLabel.center.y = 50
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "Me"
        self.view.addSubview(titleLabel)
        /**
         scrollView
         */
        scrollView = UIScrollView(frame: CGRect(x: 0, y: gl.frame.height, width: UIScreen.main.bounds.width, height: self.view.bounds.height - gl.frame.height))
        scrollView.delegate = self
        scrollView.contentSize.width = UIScreen.main.bounds.width
        scrollView.contentSize.height = 100
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
        
        /**
         nameCard: username and email
         deprecated in 8.18
         */
        /*
        nameCard = SettingCard.getSingleNameCard()
        let tapGesture = UITapGestureRecognizer()
        if !ifloggedin{
            tapGesture.addTarget(self, action: #selector(login))
        }else{
            tapGesture.addTarget(self, action: #selector(accountSetting))
        }
        nameCard.addGestureRecognizer(tapGesture)
        self.scrollView.addSubview(nameCard)
        self.scrollView.contentSize.height += nameCard.frame.height
        */
        
        /*
        language: language Setting
        language = SettingCard.getSingleSettingCard(color: .white,title: "Language",icon:UIImage(named: "languages")!, action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(languageSetting))
            settingCard.addGestureRecognizer(tapGesture)
        })
        language.frame.origin.y = 30
        language.center.x = scrollView.bounds.width/4
        language.hero.id = "language"
        self.scrollView.addSubview(language)
        self.scrollView.contentSize.height += language.frame.height + 20
        
        */
        
        /**
         sync
         */
        sync = SettingCard.getSingleSettingCard(color:.white,title: "Sync",icon:UIImage(named: "sync")!,action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(syncSetting))
            settingCard.addGestureRecognizer(tapGesture)
    
        })
        sync.imageView.setFAIconWithName(icon: .FACog, textColor: .black)
        sync.frame.origin.y = 30
        sync.center.x = scrollView.bounds.width/4
        sync.hero.id = "sync"
        self.scrollView.addSubview(sync)
    
        
        /**
         account
        account = SettingCard.getSingleSettingCard(color: .white,title: "Account Plan", icon:UIImage(named: "accountPlan")!,action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(accountPlans))
            settingCard.addGestureRecognizer(tapGesture)
        })
        account.frame.origin.y = sync.frame.origin.y
        account.center.x = scrollView.bounds.width/4 * 3
        account.hero.id = "accountPlan"
        self.scrollView.addSubview(account)
        self.scrollView.contentSize.height += account.frame.height + 30
        */
        
        /**
        help
        */
        help = SettingCard.getSingleSettingCard(color: .white, title: "Help", icon:UIImage(named: "help")!,action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(helpSetting))
            settingCard.addGestureRecognizer(tapGesture)
        })
        help.imageView.setFAIconWithName(icon: .FAQuestion, textColor: .black)
        help.frame.origin.y = 30
        help.center.x = scrollView.bounds.width/4*3
        help.hero.id = "help"
        self.scrollView.addSubview(help)
        //self.scrollView.contentSize.height += help.frame.height + 20
        
        /**
        About us
        */
        aboutUs = SettingCard.getSingleSettingCard(color: .white, title: "About us", icon:UIImage(),action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(aboutUsSetting))
            settingCard.addGestureRecognizer(tapGesture)
        })
        aboutUs.imageView.setFAIconWithName(icon: .FAUsers, textColor: .black)
        aboutUs.frame.origin.y = sync.frame.origin.y + sync.frame.height + 30
        aboutUs.center.x = scrollView.bounds.width/4
        aboutUs.hero.id  = "aboutUs"
        self.scrollView.addSubview(aboutUs)
        self.scrollView.contentSize.height += aboutUs.frame.height + 30
        
        /**
        Rate us
        */
        rateUs = SettingCard.getSingleSettingCard(color: .white, title: "Rate us", icon:UIImage(named: "rateUs")!,action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(rateUsSetting))
            settingCard.addGestureRecognizer(tapGesture)
        })
        rateUs.imageView.setFAIconWithName(icon: .FAStar, textColor: .black)
        rateUs.frame.origin.y = sync.frame.origin.y + sync.frame.height + 30
        rateUs.center.x = scrollView.bounds.width/4*3
        rateUs.hero.id = "rateUs"
        self.scrollView.addSubview(rateUs)
        
        /**
        Version
        */
        version = SettingCard.getSingleSettingCard(color: .white, title: "Version", icon:UIImage.init(icon:.FAMars, size: CGSize(width: 30, height: 30)), action: {settingcard in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(versions))
            settingcard.addGestureRecognizer(tapGesture)
        })
        
        
        version.frame.origin.y = rateUs.frame.origin.y + rateUs.frame.height + 30
        version.center.x = scrollView.bounds.width/4
        version.hero.id = "version"
        self.scrollView.addSubview(version)
        
        /**
         tag
         */
        tag = SettingCard.getSingleSettingCard(color: .white, title: "Tag", icon: UIImage.init(icon: .FATags, size: CGSize(width: 30, height: 30)), action: { (settingCard) in
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(tags))
            settingCard.addGestureRecognizer(tapGesture)
        })
        
        tag.frame.origin.y = rateUs.frame.origin.y + rateUs.frame.height + 30
        tag.center.x = scrollView.bounds.width/4*3
        tag.hero.id = "tag"
        self.scrollView.addSubview(tag)
        
    }
    
    @objc func tags(){
        let tagVC = ClassController()
        self.present(tagVC, animated: true, completion: nil)
    }
    
    @objc func versions(){
        
    }
    
    @objc func rateUsSetting(){
        let urlString = NSString(format: "itms-apps://itunes.apple.com/app/id%@?action=write-review","1410342694")//替换为对应的APPID
       
        UIApplication.shared.open(URL(string:urlString as String)!, options: [:], completionHandler: nil)
    }
    
    @objc func aboutUsSetting()
    {
        let uv = AboutUsController()
        self.present(uv, animated: true, completion: nil)
    }
    
   
    
    @objc func helpSetting(){
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            //设置代理
            controller.mailComposeDelegate = self
            //设置主题
            controller.setSubject("Help")
            controller.setToRecipients(["support@cardnotebook.com"])
            //设置抄送人
            //设置邮件正文内容（支持html）
            let infoDictionary = Bundle.main.infoDictionary
            let appVersion = infoDictionary!["CFBundleShortVersionString"] as! String
            let iosVersion = UIDevice.current.systemVersion //iOS版本
            let string = "version:\(appVersion)\niOS version:\(iosVersion)"
            controller.setMessageBody(string, isHTML: false)
            
            //打开界面
            self.present(controller, animated: true, completion: nil)
        }else{
            AlertView.show(error: "The device is unable to send mail.")
            print("The mail can't not be sent in this device.")
        }
    }
    
    
    @objc func syncSetting(){
        let settingController = SettingController()
        settingController.view.backgroundColor = .white
        settingController.setTitle("Sync")
        let sync_under_wifi = SwitchSetting(title: "Sync only with Wifi", description: "Sync your notes to the cloud only if wifi presents.", tintColor:Constant.Color.themeColor, onSwitch: {
            UserDefaults.standard.set(true, forKey: Constant.Key.SyncWithWifi)
        }) {
            UserDefaults.standard.set(false, forKey: Constant.Key.SyncWithWifi)
        }
        sync_under_wifi.paperSwitch.isOn = UserDefaults.standard.bool(forKey: Constant.Key.SyncWithWifi)
        if sync_under_wifi.paperSwitch.isOn{
            sync_under_wifi.titleLabel.textColor = .white
            sync_under_wifi.descrptionLabel.textColor = .white
        }
        
        let auto_sync = SwitchSetting(title: "Auto-Sync", description: "Sync your notes to the cloud automatically.",tintColor: Constant.Color.themeColor, onSwitch: {
            UserDefaults.standard.set(true, forKey: Constant.Key.AutoSync)
        }, offSwitch: {
            UserDefaults.standard.set(false, forKey: Constant.Key.AutoSync)
            sync_under_wifi.paperSwitch.isOn = false
            sync_under_wifi.switchValueChanged()
        })
        
        auto_sync.paperSwitch.isOn = UserDefaults.standard.bool(forKey: Constant.Key.AutoSync)
        if auto_sync.paperSwitch.isOn{
            auto_sync.titleLabel.textColor = .white
            auto_sync.descrptionLabel.textColor = .white
        }
        
        
        settingController.addSettingView(view: auto_sync)
        settingController.addSettingView(view: sync_under_wifi)
        self.present(settingController, animated: true) {
        }
    }
    
    @objc func languageSetting(){
        
    }

    
    @objc func accountSetting(){
        self.performSegue(withIdentifier: "accountSetting", sender: "")
    }
    
    
}

extension UserViewController:UINavigationControllerDelegate,MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .cancelled{
            controller.dismiss(animated: true, completion: nil)
        }else if result == .failed{
            AlertView.show(error: "Mail sent failed-" + (error?.localizedDescription)!)
        }else if result == .sent{
            AlertView.show(success: "Sent")
            controller.dismiss(animated: true, completion: nil)
        }else if result == .saved{
            AlertView.show(success: "Saved to Mail")
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
