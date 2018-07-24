//
//  SignUpController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/19.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Font_Awesome_Swift
import Hero
class SignUpController:UIViewController,UITextFieldDelegate{
    var former = ""
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var authCode: UITextField!
    @IBOutlet weak var identifyPassword: UITextField!
    override func viewDidLoad() {
        addBottomLine(email)
        addBottomLine(password)
        addBottomLine(authCode)
        addBottomLine(identifyPassword)
        addBottomLine(username)
        
        //self gesture
        
        
        
        //resgister KeyBoard Notification
        let centerDefault = NotificationCenter.default
        centerDefault.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //decoration of button
        for view in self.view.subviews{
            if view.isKind(of: UIButton.self){
                view.frame.size = CGSize(width: UIScreen.main.bounds.width/2, height: 40)
               // addRadiusFrame(view)
                view.center.x = UIScreen.main.bounds.width/2
            }
        }
        
        //add exist view
        if former != "ad" && former != "login"{
        let existButton = UIButton()
        existButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        existButton.setTitleColor(.white, for: .normal)
        existButton.frame = CGRect(x: 50, y: UIDevice.current.Xdistance() + 10, width: 50, height: 50)
        existButton.addTarget(self, action: #selector(exit), for: .touchDown)
        self.view.addSubview(existButton)
        }
    }
    
    @objc func keyboardWillShow(aNotification: NSNotification){
        print("keyBoardShow")
        let userinfo: NSDictionary = aNotification.userInfo! as NSDictionary
        let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (nsValue as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        for view in self.view.subviews{
            if view.isKind(of: UIButton.self) && view.frame.origin.y + view.frame.height > self.view.frame.height - height!{
    UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
                UIView.animate(withDuration: 0.5) {
                    view.frame.origin.y = self.view.frame.height - height! - view.frame.height
                }
            }
        }
    }
    
    @objc func exit(){
        if former != "logout"{
        self.dismiss(animated: true, completion: nil)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "first") as! SignUpController
            vc.former = "login"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func addBottomLine(_ view:UIView?){
        if view != nil{
            let underLine:UIView = UIView(frame:CGRect(x:0,y:view!.frame.size.height-2,width:view!.frame.size.width,height:2))
            underLine.backgroundColor = .white
            view!.addSubview(underLine)
        }
    }
    
    func addRadiusFrame(_ view:UIView?){
        if view != nil{
            view?.layer.cornerRadius = 10
            view?.layer.borderColor = UIColor.white.cgColor
            view?.layer.borderWidth = 1
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        let regex = "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: email.text)
        if isValid && password.text != ""{
            print("Valid Email and Password")
            User.login(email: email.text!, password: password.text!, completionHandler: { (json:JSON?) in
                if json != nil{
                    let ifSuccess = json!["ifSuccess"].boolValue
                    if ifSuccess{
                        print("login successful")
                        UserDefaults.standard.set(json!["token"].stringValue, forKey: "userToken")
                        loggedID = (json!["userInfo"].dictionary!["id"]?.stringValue)!
                        loggedemail = (json!["userInfo"].dictionary!["email"]?.stringValue)!
                        loggedusername = (json!["userInfo"].dictionary!["username"]?.stringValue)!
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
                                    //update the internetCard if local is more recent
                                    //update the localCard if Internet is more recent
                                }
                            }
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "main", sender: nil)
                            }
                        })
                    }else{
                        AlertView.show(self.view, alert: json!["error"].stringValue)
                    }
                }
            })
        }else if password.text == ""{
             AlertView.show(self.view, alert: "Empty Password")
        }else{
             AlertView.show(self.view, alert: "Invalid Email")
        }
    }
    
    @IBAction func toLoginController(_ sender: UIButton) {
       let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "login")
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func toSignUpController(_ sender: Any) {
        performSegue(withIdentifier: "signUp", sender: "main")
    }
    
    @IBAction func verification(_ sender: Any) {
        let regex = "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: email.text)
        if isValid && username.text != nil{
            signUpEmail = email.text!
            signUpUsername = username.text!
            User.verification(email:signUpEmail, username: signUpUsername, completionhandler: {
                (json:JSON?)->Void in
                if json != nil{
                    let ifSuccess = json!["ifSuccess"].boolValue
                    if ifSuccess{
                    self.performSegue(withIdentifier: "verification", sender:"email")
                    }else{
                        AlertView.show(self.view, alert: json!["error"].stringValue)
                    }
                }else{
                    AlertView.show(self.view, alert: "Connection Error.")
                }
            })
            
        }else if !isValid{
            AlertView.show(self.view,alert: "Invalid email.")
        }else if username == nil{
            AlertView.show(self.view,alert: "Empty username.")
        }
    }
   
    @IBAction func toPassWord(_ sender: Any) {
        //VerificationOfAuthCode
        let auth = authCode.text
        if auth != nil{
            print(auth)
            signUpAuthCode = auth!
        User.verifyEmail(auth: auth!) { (json:JSON?) in
            if json != nil{
                let ifSuccess = json!["ifSuccess"].boolValue
                if ifSuccess{
                    self.performSegue(withIdentifier: "password", sender: "verification")
                }else{
                     AlertView.show(self.view, alert: "Invalid Verification Code.")
                }
            }else{
                 AlertView.show(self.view, alert: "Connection Error.")
            }
        }
        }else{
            AlertView.show(self.view, alert: "Empty Code")
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinitation = segue.destination
        if destinitation.isKind(of: SignUpController.self){
            (destinitation as! SignUpController).former = sender as! String
        }
    }
    
    @IBAction func toCompletion(_ sender: Any) {
        let password = self.password.text
        let identifyPassword = self.identifyPassword.text
        if password == identifyPassword{
            let reg = "^[0-9a-zA-Z!@#$%^&*]{8,20}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", reg)
            let isValid = predicate.evaluate(with: password)
            if isValid{
                User.signUp(email: signUpEmail, username: signUpUsername, password: password!, auth: signUpAuthCode, completionHandler: {
                    (json:JSON?)->Void in
                    if json != nil{
                    let ifSuccess = json!["ifSuccess"].boolValue
                        if ifSuccess{
                            User.login(email: signUpEmail, password: password!, completionHandler: { (json:JSON?) in
                                if json != nil{
                                    let ifSuccess = json!["ifSuccess"].boolValue
                                    if ifSuccess{
                                        print("login successful")
                                        UserDefaults.standard.set(json!["token"].stringValue, forKey: "userToken")
                                        loggedID = (json!["userInfo"].dictionary!["id"]?.stringValue)!
                                        loggedemail = (json!["userInfo"].dictionary!["email"]?.stringValue)!
                                        loggedusername = (json!["userInfo"].dictionary!["username"]?.stringValue)!
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
                                    }
                                }
                                })
                            self.performSegue(withIdentifier: "completion", sender: "password")
                        }else{
                            let error = json!["error"].stringValue
                            print(error)
                            AlertView.show(self.view, alert: error)
                        }
                    }else{
                    AlertView.show(self.view, alert: "Connection Error.")
                    }
                })
            }else{
                 AlertView.show(self.view, alert: "8-20位由数字字母或特殊字符组成的密码.")
            }
        }else{
            AlertView.show(self.view, alert: "Not consistent password.")
        }
    }
    
    
    @IBOutlet weak var signUpComplete: UIButton!
    
}
