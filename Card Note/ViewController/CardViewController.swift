//
//  CardViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/5.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Spring
import SCLAlertView
import SwiftyJSON
import SwiftMessages
import Font_Awesome_Swift
class CardViewController:UIViewController,UIScrollViewDelegate,UITextFieldDelegate,CardViewPanelDelegate,UIDocumentInteractionControllerDelegate{
    @IBOutlet weak var addCardButton: UIButton!
    var scrollView:UIScrollView!
    var searchTextView:SearchBar = SearchBar()
    var slideView:UIView!
    var docController:UIDocumentInteractionController!
    @IBAction func addNewCard(_ sender:UIButton){
    self.performSegue(withIdentifier: "cardEditor", sender: CardEditor.type.add)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cardEditor"{
            let editor = segue.destination as! CardEditor
            if (sender as? CardEditor.type) == CardEditor.type.add{
                editor.type = CardEditor.type.add}
            else if ((sender as? Card)?.isKind(of: Card.self))!{
                editor.type = CardEditor.type.save
                editor.card =  (sender as! Card)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCard()
        
    }
    
    override func viewDidLoad() {
        addCardButton.setFAIcon(icon: .FAPlusCircle, iconSize: 50, forState: .normal)
        addCardButton.setTitleColor(.black, for: .normal)
        if UserDefaults.standard.bool(forKey: "auto-sync") && isPremium(){
            sync { (ifSuccess, error) in
                if ifSuccess{
                   
                }else{
                    let view = MessageView.viewFromNib(layout: .cardView)
                    // Theme message elements with the warning style.
                    view.configureTheme(.error)
                    
                    // Add a drop shadow.
                    view.configureDropShadow()
                    
                    view.button?.removeFromSuperview()
                    // Set message title, body, and icon. Here, we're overriding the default warning
                    // image with an emoji character.
                    
                    view.configureContent(title: "Error", body: "Sync failed.", iconText: "")
                    
                    // Show the message.
                    SwiftMessages.show(view: view)
                }
            }
        }
        //adjust distance
        let y:Int = UIDevice.current.Xdistance()
        //addCardButton.frame.origin.y = CGFloat(y)
        self.view.bringSubview(toFront: addCardButton)
        
        //search Bar
        searchTextView.frame = CGRect(x: 40, y: y, width: Int(UIScreen.main.bounds.width-80), height: 40)
        self.view.addSubview(searchTextView)
        self.view.bringSubview(toFront: searchTextView)
        searchTextView.searchTextView.addTarget(self, action: #selector(textViewChange), for: .allEditingEvents)
        searchTextView.searchTextView.delegate = self
        //slideView
        slideView = UIView(frame: CGRect(x: 0, y: searchTextView.frame.height + searchTextView.frame.origin.y, width: UIScreen.main.bounds.width, height: 50))
        slideView.backgroundColor = .white
        
       // slideView.layer.shadowRadius = 1
        //slideView.layer.shadowColor = UIColor.black.cgColor
        //slideView.layer.shadowOpacity = 0.5
       
        //filter Button
        let filterButton = UIButton()
        filterButton.frame = CGRect(x: 40, y: 10, width: 60, height: 30)
        slideView.addSubview(filterButton)
        self.view.addSubview(slideView)
        let string = NSAttributedString(string: "Filter", attributes: [NSAttributedStringKey.font:UIFont(name: "AmericanTypewriter", size: 14)])
        print(string)
        filterButton.setAttributedTitle(string, for: .normal)
        filterButton.setTitleColor(.black, for: .normal)
        filterButton.layer.cornerRadius = 2
        filterButton.backgroundColor = .white
        filterButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        filterButton.layer.shadowColor = UIColor.black.cgColor
        filterButton.layer.shadowOpacity = 0.5
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.frame = CGRect(x: 0, y: searchTextView.frame.origin.y + searchTextView.frame.height + 20, width: self.view.bounds.width, height: self.view.bounds.height-(slideView.frame.origin.y + slideView.frame.height + 10))
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:10)
        self.view.addSubview(scrollView)
        self.view.bringSubview(toFront: addCardButton)
        self.view.bringSubview(toFront: slideView)
        self.view.bringSubview(toFront: searchTextView)
    }
    
    @objc func slide(gesture: UIPanGestureRecognizer){
    let translation = gesture.translation(in: self.view)
        if (slideView.center.y + translation.y) >= searchTextView.frame.height + searchTextView.frame.origin.y - 50 && (slideView.center.y + translation.y) <= searchTextView.frame.origin.y + searchTextView.frame.height{
   // gesture.view?.center.x += translation.x
          slideView.center.y += translation.y
        }
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }
    
    var lastScrollViewContentOffY:CGFloat = 0
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollViewContentOffY = scrollView.contentOffset.y
    
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if lastScrollViewContentOffY - scrollView.contentOffset.y > -50 && lastScrollViewContentOffY - scrollView.contentOffset.y < 0{
            UIView.animate(withDuration: 0.5) {
                self.slideView.frame.origin.y = self.searchTextView.frame.height + self.searchTextView.frame.origin.y - 50
            }
        }else if lastScrollViewContentOffY - scrollView.contentOffset.y > 50{
            UIView.animate(withDuration: 0.5) {
                self.slideView.frame.origin.y = self.searchTextView.frame.height + self.searchTextView.frame.origin.y
            }
        }else if lastScrollViewContentOffY - scrollView.contentOffset.y < -50{
            UIView.animate(withDuration: 0.5) {
                self.slideView.frame.origin.y = self.searchTextView.frame.height + self.searchTextView.frame.origin.y - 50
            }
        }else if lastScrollViewContentOffY - scrollView.contentOffset.y < 50  && lastScrollViewContentOffY - scrollView.contentOffset.y > 0{
            UIView.animate(withDuration: 0.5) {
                self.slideView.frame.origin.y = self.searchTextView.frame.height + self.searchTextView.frame.origin.y
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let manager = FileManager.default
        var cardList:[Card]!
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
         url?.appendPathComponent(loggedID)
        url?.appendPathComponent("card.txt")
        if let dateRead = try? Data.init(contentsOf: url!){
            cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
            if cardList == nil{
                cardList = [Card]()
            }
        }
        let string = NSString(string: textField.text!.lowercased())
        if string.contains(" ") && String(string)[textField.text!.startIndex] != " " && String(string)[textField.text!.index(textField.text!.endIndex, offsetBy: -1)] != " "{
            let components = string.components(separatedBy: " ")
            let parsedCardList = SearchEngine.loadCards(cards: cardList, keyWords: components)
            loadCardWithConstaints(parsedCardList, [Constraint]())
        }else if string != ""{
            var keyword = [String]()
            keyword.append(textField.text!)
            let parsedCardList = SearchEngine.loadCards(cards: cardList, keyWords: keyword)
            loadCardWithConstaints(parsedCardList, [Constraint]())
        }else if string == ""{
            loadCard()
        }
       
    }
    
    @objc func textViewChange(_ sender:UITextView){
        /*
        let manager = FileManager.default
        var cardList:[Card]!
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent("card.txt")
        if let dateRead = try? Data.init(contentsOf: url!){
            cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
            if cardList == nil{
                cardList = [Card]()
            }
        }
        let string = NSString(string: sender.text)
        if string.contains(" ") && String(string)[sender.text.startIndex] != " " && String(string)[sender.text.index(sender.text.endIndex, offsetBy: -1)] != " "{
            let components = string.components(separatedBy: " ")
            let parsedCardList = SearchEngine.loadCards(cards: cardList, keyWords: components)
        }
 */
    }
    
    func loadCard(){
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:50)
        for subview in scrollView.subviews{
            subview.removeFromSuperview()
        }
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
         url?.appendPathComponent(loggedID)
        url?.appendPathComponent("card.txt")
        
        if let dateRead = try? Data.init(contentsOf: url!){
            var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
            if cardList == nil{
                cardList = [Card]()
            }
            
            var cumulatedY = 50
            for card in cardList!{
                var cardView:CardView = CardView.getSingleCardView(card:card)
                cardView.frame.origin.y = CGFloat(cumulatedY)
                cumulatedY += Int(cardView.bounds.height
                + 10)
                let tapGesture = UITapGestureRecognizer()
                tapGesture.addTarget(self, action: #selector(tapped))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardView.addGestureRecognizer(tapGesture)
                let gesture = UISwipeGestureRecognizer()
                gesture.direction = .left
                gesture.addTarget(self, action: #selector(controllPanel))
                cardView.addGestureRecognizer(gesture)
                scrollView.addSubview(cardView)
                scrollView.contentSize = CGSize(width: self.view.bounds.width, height: scrollView.contentSize.height + cardView.bounds.height + 10)
            }
            
        }
    }
    
    func sync(completionHandler:@escaping (Bool,String?)->()){
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
        
        var ifSuccessArray = [Bool]()
        User.getUserCards(email: loggedemail, completionHandler: { (json:JSON?) in
            if json != nil{
                if !json!["ifSuccess"].boolValue{
                    ifSuccessArray.append(false)
                }else{
                    ifSuccessArray.append(true)
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
                    //get local cards
                    let manager = FileManager.default
                    var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                    url?.appendPathComponent(loggedID)
                    url?.appendPathComponent("card.txt")
                    if let dateRead = try? Data.init(contentsOf: url!){
                        var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                        var cardCopiedList = cardList
                        if cardList == nil{
                            cardList = [Card]()
                        }
                        var i = 0
                        for interNetCard in cardArray{
                            var j = 0
                            var removed:Bool = false
                            for localCard in cardList!{
                                
                                if interNetCard.getId() == localCard.getId(){
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    let dateIn = formatter.date(from: interNetCard.getTime())
                                    let datelo = formatter.date(from: localCard.getTime())
                                    let result:ComparisonResult = (dateIn?.compare(datelo!))!
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
                                                    ifSuccessArray.append(true)
                                                }else{
                                                    ifSuccessArray.append(false)
                                                }
                                            }
                                            
                                        })
                                    }
                                    cardArray.remove(at: i)
                                    cardList?.remove(at: j)
                                    removed = true
                                }
                                if !removed{
                                    j+=1
                                }
                            }
                            if !removed{
                                i+=1
                            }
                        }
                        
                        //add rest InterNetCard to local
                        cardCopiedList?.append(contentsOf:cardArray)
                        let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardCopiedList!)
                        do{
                            try datawrite.write(to: url!)
                        }catch{
                            print("fail to add")
                             ifSuccessArray.append(false)
                        }
                        //add local Card to InterNet
                        for card in cardList!{
                            User.addCard(email: loggedemail, card: card, completionHandler: { (json:JSON?) in
                                if json != nil{
                                    let ifSuccess = json!["ifSuccess"].boolValue
                                    if ifSuccess{
                                        print("Sync Success")
                                         ifSuccessArray.append(true)
                                    }else{
                                        let error = json!["error"].stringValue
                                        ifSuccessArray.append(false)
                                  }
                                }
                            })
                        }
                    }
                }
            }
        })
        if ifSuccessArray.contains(false){
            completionHandler(false, "")
        }else{
             completionHandler(true, "")
        }
    }
    
    func loadCardWithConstaints(_ cardList:[Card],_ constaints:[Constraint]){
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:10)
        for subview in scrollView.subviews{
            subview.removeFromSuperview()
        }
        
        var colorConstaints:[UIColor] = [UIColor]()
        var tagConstaints:[String] = [String]()
       
        for constaint in constaints{
            switch (constaint.type)!
            {
            case .color:
                colorConstaints.append(constaint.value as! UIColor)
            case  .tag:
                 tagConstaints.append(constaint.value as! String)
            }
        }
        
            var filterdCardList = [Card]()
            for card in cardList{
                if colorConstaints.contains(card.color!) && tagConstaints.contains(card.getTag()){
                    filterdCardList.append(card)
                }else if colorConstaints.isEmpty && tagConstaints.isEmpty{
                    filterdCardList.append(card)
                }
            }
            
            var cumulatedY = 10
            for card in filterdCardList{
                let cardView:CardView = CardView.getSingleCardView(card:card)
                cardView.frame.origin.y = CGFloat(cumulatedY)
                cumulatedY += Int(cardView.bounds.height
                    + 10)
                let tapGesture = UITapGestureRecognizer()
                tapGesture.addTarget(self, action: #selector(tapped))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardView.addGestureRecognizer(tapGesture)
                
                let gestureleft = UISwipeGestureRecognizer()
                gestureleft.direction = .left
                gestureleft.addTarget(self, action: #selector(controllPanel))
                cardView.addGestureRecognizer(gestureleft)
                
                scrollView.addSubview(cardView)
                scrollView.contentSize = CGSize(width: self.view.bounds.width, height: scrollView.contentSize.height + cardView.bounds.height + 10)
            }
        }
    
    @objc func controllPanel(_ sender:UISwipeGestureRecognizer){
        let selectedView = sender.view as! CardView
        let controllPanel = CardViewPanel.getSingleCardViewPanel(frame: CGRect(x:selectedView.frame.origin.x,y:selectedView.frame.origin.y,width:selectedView.frame.width,height:selectedView.frame.height))
        scrollView.addSubview(controllPanel)
        controllPanel.animation = "squeezeLeft"
        controllPanel.curve = "EaseIn"
        controllPanel.animate()
        controllPanel.delegate = self
        controllPanel.controlledView = selectedView
        let gestureright = UISwipeGestureRecognizer()
        gestureright.direction = .right
        gestureright.addTarget(self, action: #selector(controllPanelEaseOut))
        controllPanel.addGestureRecognizer(gestureright)
    }
    
    @objc func controllPanelEaseOut(_ sender:UISwipeGestureRecognizer){
      let panel = sender.view as! CardViewPanel
        panel.frame.origin.x = self.view.frame.width
        panel.animation = "squeezeRight"
        panel.curve = "EaseIn"
        panel.animate()
        panel.animateNext {
            panel.removeFromSuperview()
        }
    }
    
    func shareButtonClicked(_ controllPanel:CardViewPanel) {
        let cardView = controllPanel.controlledView as! CardView
        let alertView = SCLAlertView()
        alertView.addButton("To Notes Library") {
            self.shareCard(card:cardView.card)
        }
        alertView.addButton("Generate Picture") {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let cardEditor = storyBoard.instantiateViewController(withIdentifier: "cardEditor") as! CardEditor
            cardEditor.card = cardView.card
            cardEditor.viewDidLoad()
           let image = cutFullImageWithView(scrollView: cardEditor.scrollView)
           let shareView = SCLAlertView()
            shareView.addButton("To Other Apps", action: {
                let imageData = UIImageJPEGRepresentation(image, 1)
                do{
                let id = UUID().uuidString + ".jpeg"
                let url = Constant.Configuration.url.temporary.appendingPathComponent(id)
                    try FileManager.default.createDirectory(at:Constant.Configuration.url.temporary, withIntermediateDirectories: true, attributes: nil)
                    try imageData?.write(to: url)
                    if let u:NSURL? = NSURL(fileURLWithPath: url.path) {
                        self.docController = UIDocumentInteractionController.init(url: u as! URL)
                        self.docController.uti = "public.jpeg"
                        self.docController.delegate = self
                        // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                        self.docController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                    }
                    
                }catch let err{
                    print(err.localizedDescription)
                }
            })
            
            shareView.addButton("To Album", action: {
               ImageManager.writeImageToAlbum(image: image, completionhandler: nil)
            })
            shareView.showSuccess("Success", subTitle: "Now Let's share!")
        }
         alertView.showNotice("Sharing", subTitle: "It's nice to have your card open to public.")
    }
    
    func deleteButtonClicked(_ controllPanel:CardViewPanel) {
        let cardView = controllPanel.controlledView as! CardView
        let alertView = SCLAlertView()
        alertView.addButton("Delete") {
            self.deleteCard(card: cardView.card)
        }
         let responder = alertView.showWarning("Warning", subTitle: "Are you deleting this card?")
    
    }
    
    @objc private func shareCard(card:Card){
        //User.shareCard(card: card, states: [String]())
        let shareView = ShareView.show(target: self.view, card: card)
        shareView.shareBlock = {
            User.shareCard(card: card, states: shareView.state)
            shareView.cancel()
        }
    }
        
    
    @objc private func deleteCard(card:Card){
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("card.txt")
        if let dateRead = try? Data.init(contentsOf: url!){
            var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
            if cardList == nil{
                cardList = [Card]()
            }
            var index = 0
            for c in cardList!{
                if c.getId() == card.getId(){
                    cardList?.remove(at: index)
                    break
                }
                index += 1
            }
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
            do{
                try datawrite.write(to: url!)
            }catch{
                print("Fail to delete Card")
            }
        }
    
    
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer){
        let card:Card = (sender.view as! CardView).card
        sender.view?.hero.id = "batman"
        self.performSegue(withIdentifier: "cardEditor", sender: card)
    }
    
}
