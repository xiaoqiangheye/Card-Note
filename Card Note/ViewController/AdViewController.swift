//
//  AddViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/19.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class AdViewController:UIViewController{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent("card.txt")
        if !manager.fileExists(atPath: (url?.path)!){
            try? manager.createDirectory(atPath: (url?.deletingLastPathComponent().path)!, withIntermediateDirectories: true, attributes: nil)
            if !manager.createFile(atPath: (url?.path)!, contents: nil, attributes: nil){print("false to create Directory")}
            let cardList = [Card]()
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
            do{
                try datawrite.write(to: url!)
            }catch{
                print("fail to add")
            }
        }
        /*
        let token = UserDefaults.standard.string(forKey: Constant.Key.Token)
        if token != nil && token != ""{
            User.loginWithToken(completionHandler: {
                (json:JSON?)->Void in
                if json != nil{
                let ifSuccess = json!["ifSuccess"].boolValue
                if !ifSuccess{
                    self.performSegue(withIdentifier: "login", sender: nil)
                }else{
                    
                    ifloggedin = true
                    loggedID = (json!["userInfo"].dictionary!["id"]?.stringValue)!
                    loggedemail = (json!["userInfo"].dictionary!["email"]?.stringValue)!
                    loggedusername = (json!["userInfo"].dictionary!["username"]?.stringValue)!
                    UserDefaults.standard.set(loggedemail, forKey: Constant.Key.loggedEmail)
                    UserDefaults.standard.set(loggedusername, forKey: Constant.Key.loggedUsername)
                    UserDefaults.standard.set(loggedID, forKey: Constant.Key.loggedID)
                    let manager = FileManager.default
                    var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                    url?.appendPathComponent(loggedID)
                    url?.appendPathComponent("card.txt")
                    if !manager.fileExists(atPath: (url?.path)!){
                        try? manager.createDirectory(atPath: (url?.deletingLastPathComponent().path)!, withIntermediateDirectories: true, attributes: nil)
                        if !manager.createFile(atPath: (url?.path)!, contents: nil, attributes: nil){print("false to create Directory")}
                        let cardList = [Card]()
                        let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
                        do{
                            try datawrite.write(to: url!)
                        }catch{
                            print("fail to add")
                        }
                    }
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "main", sender: nil)
                    }
                }
                }else{
                    if UserDefaults.standard.string(forKey: Constant.Key.loggedEmail) != ""{
                        loggedemail = UserDefaults.standard.string(forKey: Constant.Key.loggedEmail)!
                        loggedID = UserDefaults.standard.string(forKey: Constant.Key.loggedID)!
                        loggedusername = UserDefaults.standard.string(forKey: Constant.Key.loggedUsername)!
                        self.performSegue(withIdentifier: "main", sender: nil)
                    }else{
                        self.performSegue(withIdentifier: "login", sender: nil)
                    }
                }
            })
        }else if token == "" || token == nil{
            performSegue(withIdentifier: "login", sender: nil)
        }
        */
        performSegue(withIdentifier: "main", sender: nil)
    }
    
   
}
