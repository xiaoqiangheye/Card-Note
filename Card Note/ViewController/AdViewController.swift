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
import GoogleMobileAds
class AdViewController:UIViewController{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                    manager.createFile(atPath: (url?.path)!, contents: nil, attributes: nil)
                    let cardList = [Card]()
                    let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
                    do{
                        try datawrite.write(to: url!)
                    }catch{
                        print("fail to add")
                    }
                    }
                    User.getUserCards(email: loggedemail, completionHandler: { (json:JSON?) in
                        if json != nil{
                            let carddata = json!["card"].arrayValue
                            //get cards from the dataBase
                            var cardArray:[Card] = [Card]()
                            for cardJSON in carddata{
                                print("card" + cardJSON.rawString()!)
                                let card = CardParser.JSONToCard(cardJSON.rawString()!)
                                if card != nil{
                                cardArray.append(card!)
                                }
                                }
                            var cardCopiedArray = cardArray
                            //get local cards
                            let manager = FileManager.default
                            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                            url?.appendPathComponent(loggedID)
                            url?.appendPathComponent("card.txt")
                            let data = try! Data(contentsOf: url!)
                            if let dateRead = try? Data.init(contentsOf: url!){
                                var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                                var cardCopiedList = cardList
                                if cardList == nil{
                                    cardList = [Card]()
                                }
                                for interNetCard in cardArray{
                                    var i = 0
                                    for localCard in cardList!{
                                        var j = 0
                                        if interNetCard.getId() == localCard.getId(){
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                            let dateIn = formatter.date(from: interNetCard.getTime())
                                            let datelo = formatter.date(from: localCard.getTime())
                                            var result:ComparisonResult = (dateIn?.compare(datelo!))!
                                            if result == ComparisonResult.orderedDescending{
                                                //update the localCard if Internet is more recent
                                                cardCopiedList![j] = interNetCard
                                            }else if result == ComparisonResult.orderedAscending{
                                                //update the internetCard if local is more recent
                                                User.updateCard(card: localCard, email: loggedemail, completionHandler: { (json:JSON?) in
                                                    if json != nil{
                                                        let ifSuccess = json!["ifSuccess"].boolValue
                                                        if ifSuccess{
                                                            print("Success to update card")
                                                        }
                                                    }
                                                    
                                                })
                                            }
                                            cardArray.remove(at: i)
                                            cardList?.remove(at: j)
                                        }
                                        j+=1
                                    }
                                    i+=1
                                }
                                //add rest InterNetCard to local
                                cardCopiedList?.append(contentsOf:cardArray)
                                
                                let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardCopiedList)
                                do{
                                    try datawrite.write(to: url!)
                                }catch{
                                    print("fail to add")
                                }
                                //add local Card to InterNet
                                for card in cardList!{
                                    User.addCard(email: loggedemail, card: card, completionHandler: { (json:JSON?) in
                                        if json != nil{
                                            let ifSuccess = json!["ifSuccess"].boolValue
                                            if ifSuccess{
                                                print("Sync Success")
                                            }
                                        }
                                    })
                                }
                            }
                    }
                        DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "main", sender: nil)
                        }
                    })
                    
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: SignUpController.self){
            (segue.destination as! SignUpController).former = "ad"
        }
    }
}
