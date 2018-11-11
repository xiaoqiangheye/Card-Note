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
import Instructions
extension CardViewController:CoachMarksControllerDataSource{
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        if index == 0{
        return coachMarksController.helper.makeCoachMark(for:addCardButton)
        }else if index == 1{
            return coachMarksController.helper.makeCoachMark(for: addCardButton)
        }else if index == 2{
         return coachMarksController.helper.makeCoachMark(for: searchTextView)
        }else{
         return coachMarksController.helper.makeCoachMark(for: slideView)
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        if index == 0{
        coachViews.bodyView.hintLabel.text = "Welcome to Card Note. Ready for a walk?"
        coachViews.bodyView.nextLabel.text = "Ok"
        }else if index == 1{
        coachViews.bodyView.hintLabel.text = "Click '+' to add a new card."
        coachViews.bodyView.nextLabel.text = "Ok"
        }else if index == 2{
        coachViews.bodyView.hintLabel.text = "This is an search Bar for you to search your cards."
        coachViews.bodyView.nextLabel.text = "OK"
        }else if index == 3{
        coachViews.bodyView.hintLabel.text = "This is a tool Bar to select your cards."
        coachViews.bodyView.nextLabel.text = "OK"
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

class CardViewController:UIViewController,UIScrollViewDelegate,UITextFieldDelegate,CardViewPanelDelegate,UIDocumentInteractionControllerDelegate{
    @IBOutlet weak var addCardButton: FloatButton!
    var scrollView:UIScrollView!
    var searchTextView:SearchBar = SearchBar()
    var slideView:UIView!
    var docController:UIDocumentInteractionController!
    let coachMarksController = CoachMarksController()
    var filterView = FilterView()
    @IBAction func addNewCard(_ sender:UIButton){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "cardEditor") as! CardEditor
        vc.modalPresentationStyle = .overCurrentContext
        vc.type = CardEditor.type.add
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
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
        // self.view.backgroundColor = .clear
        coachMarksController.dataSource = self
        if !isFirstLaunch{
            self.coachMarksController.start(on: self)
        }
        syncCard()
        func createButtonUnderBar(title:String)->UIButton{
            let filterButton = UIButton()
            filterButton.frame = CGRect(x: 40, y: 10, width: 60, height: 30)
            slideView.addSubview(filterButton)
            let string = NSAttributedString(string: title, attributes: [NSAttributedStringKey.font:UIFont(name: "Farah", size: 20)!,NSAttributedStringKey.foregroundColor:UIColor.gray])
            filterButton.setAttributedTitle(string, for: .normal)
           // filterButton.setTitleColor(UIColor.flatGray, for: .normal)
            filterButton.layer.cornerRadius = 2
            filterButton.backgroundColor = .white
            filterButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            filterButton.layer.shadowColor = Constant.Color.darkWhite.cgColor
            filterButton.layer.shadowOpacity = 0.8
            filterButton.layer.cornerRadius = filterButton.frame.height/2
            return filterButton
        }
        
        addCardButton.setBackgroundImage(UIImage(named: "plusButton"), for: .normal)
        addCardButton.setTitleColor(.clear, for: .normal)
        addCardButton.frame.origin = CGPoint(x: self.view.frame.width - 50, y: self.view.frame.height - 200)
        addCardButton.frame.size = CGSize(width: 50, height: 50)
        addCardButton.yBottomOffSet = 49
        
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:100);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        
       
        //addCardButton.frame.origin.y = CGFloat(y)
        self.view.bringSubview(toFront: addCardButton)
        
        //search Bar
        searchTextView.frame = CGRect(x: 40, y: 80, width: Int(UIScreen.main.bounds.width-80), height: 40)
        self.view.addSubview(searchTextView)
        self.view.bringSubview(toFront: searchTextView)
        searchTextView.searchTextView.addTarget(self, action: #selector(textViewChange), for: .allEditingEvents)
        searchTextView.searchTextView.delegate = self
        //slideView
        slideView = UIView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 50))
        slideView.backgroundColor = .white
       
        //filter Button
        let filterButton = createButtonUnderBar(title: "Filter")
        let syncButton = createButtonUnderBar(title: "Sync")
        filterButton.frame = CGRect(x: 40, y: 30, width: 60, height: 30)
        filterButton.addTarget(self, action: #selector(showFilter), for: .touchDown)
        syncButton.frame = CGRect(x: 110, y: 30, width: 60, height: 30)
        syncButton.addTarget(self, action: #selector(syncCard), for: .touchDown)
        slideView.addSubview(filterButton)
        slideView.addSubview(syncButton)
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.frame = CGRect(x: 0, y: searchTextView.frame.origin.y + searchTextView.frame.height - 20, width: self.view.bounds.width, height: self.view.bounds.height-(searchTextView.frame.origin.y + searchTextView.frame.height))
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:slideView.frame.height)
        scrollView.addSubview(slideView)
        self.view.addSubview(scrollView)
        self.view.bringSubview(toFront: addCardButton)
        self.view.bringSubview(toFront: searchTextView)
        
        
        //gesture for endEditing
        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        self.view.addGestureRecognizer(gesture)
        
        
        //filterView
        filterView.isHidden = true
        self.view.addSubview(filterView)
    }
    
    @objc private func showFilter(){
        if(filterView.isHidden){
            filterView.center.x = self.view.bounds.width/2
            filterView.center.y = self.view.bounds.height/2
            filterView.isHidden = false
        }
    }
    
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    @objc func slide(gesture: UIPanGestureRecognizer){
   
    }
    
    var lastScrollViewContentOffY:CGFloat = 0
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollViewContentOffY = scrollView.contentOffset.y
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0{
            slideView.frame.origin.y = scrollView.contentOffset.y
        }else{
            slideView.frame.origin.y = scrollView.contentOffset.y/2
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= 0{
            
        }else if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < slideView.frame.height/2{
             scrollView.contentOffset.y = 0
    }else if scrollView.contentOffset.y >= self.slideView.frame.height/2 && scrollView.contentOffset.y <= self.slideView.frame.height{
            scrollView.contentOffset.y = self.slideView.frame.height
        }
        
      
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        loadCard()
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
       
    }
    
    @objc func textViewChange(_ sender:UITextView){
        
    }
    
    
    func reload(){
        
    }
    
    func loadCard(){
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
        let textField = searchTextView.searchTextView
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
            loadCardWithConstaints(cardList, [Constraint]())
        }
    }
    
   
    
    func loadCardWithConstaints(_ cardList:[Card],_ constaints:[Constraint]){
        let contentOffSetY = scrollView.contentOffset.y
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:scrollView.frame.height + 20)
        for subview in scrollView.subviews{
            if subview.isKind(of: CardView.self){
            subview.removeFromSuperview()
            }
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
                if colorConstaints.contains(card.color!) && tagConstaints.isEmpty{
                    filterdCardList.append(card)
                }else if colorConstaints.contains(card.color!) && !tagConstaints.isEmpty{
                    for tagConstriant in tagConstaints{
                        if card.getTag().contains(tagConstriant){
                            filterdCardList.append(card)
                            break
                        }
                    }
                }else if colorConstaints.isEmpty && tagConstaints.isEmpty{
                    filterdCardList.append(card)
                }
            }
            
        var cumulatedY:CGFloat = 70
            for card in filterdCardList{
                let cardView:CardView = CardView.getSingleCardView(card:card)
                cardView.frame.origin.y = CGFloat(cumulatedY)
                cumulatedY += cardView.bounds.height
                    + 30
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
                if cumulatedY > scrollView.contentSize.height{
                    scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cumulatedY)
                }
            }
        
            scrollView.contentOffset.y = contentOffSetY
        }
    
    @objc func controllPanel(_ sender:UISwipeGestureRecognizer){
        let selectedView = sender.view as! CardView
        let controllPanel = CardViewPanel.getSingleCardViewPanel(frame: CGRect(x:selectedView.frame.origin.x,y:selectedView.frame.origin.y,width:selectedView.frame.width,height:selectedView.frame.height))
        scrollView.addSubview(controllPanel)
        controllPanel.animation = "slideLeft"
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
        panel.animation = "slideRight"
        panel.curve = "EaseOut"
        panel.animate()
        panel.animateNext {
        panel.removeFromSuperview()
        }
    }
    
    func shareButtonClicked(_ controllPanel:CardViewPanel) {
        let cardView = controllPanel.controlledView as! CardView
        let alertView = SCLAlertView()
        /*
        alertView.addButton("To Notes Library") {
            self.shareCard(card:cardView.card)
        }
        */
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
                    let u = NSURL(fileURLWithPath: url.path)
                    self.docController = UIDocumentInteractionController.init(url: u as URL)
                    self.docController.uti = "public.jpeg"
                    self.docController.delegate = self
                    // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                    self.docController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                    
                    
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
        alertView.addButton("local repository") {
            controllPanel.removeFromSuperview()
            self.deleteCard(card: cardView.card)
            alertView.hideView()
            self.loadCard()
        }
        alertView.addButton("local repository and iCloud") {
             controllPanel.removeFromSuperview()
            self.deleteCard(card: cardView.card)
            self.loadCard()
            Cloud.deleteRecordData(id: cardView.card.getId(), completionHandler: { (bool) in
                DispatchQueue.main.async {
                if bool{
                   AlertView.show(success: "Succeed!")
                }else{
                    AlertView.show(error: "Error. The deleting operation failed.")
                }
                }
            })
            
        }
        alertView.showWarning("Warning", subTitle: "Are you deleting this card From?")
    }
    
    @objc private func shareCard(card:Card){
        
        /*//User.shareCard(card: card, states: [String]())
        let shareView = ShareView.show(target: self.view, card: card)
        shareView.shareBlock = {
            User.shareCard(card: card, states: shareView.state)
            shareView.cancel()
        }
         */
    }
        
    
    @objc private func deleteCard(card:Card){
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
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
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList!)
            do{
                try datawrite.write(to: url!)
            }catch{
                print("Fail to delete Card")
            }
        }
        
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer){
        let vc = storyboard?.instantiateViewController(withIdentifier: "cardEditor") as! CardEditor
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        let card:Card = (sender.view as! CardView).card
        sender.view?.hero.id = card.getId()
        vc.hero.isEnabled = true
        //vc.view.hero.id = card.getId()
        vc.card = card
        vc.type = CardEditor.type.save
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func syncCard(){
        sync { (bool) in
            if bool{
                DispatchQueue.main.async {
                    AlertView.show(success: "Sync Succeed.")
                    self.loadCard()
                }
            }else{
                DispatchQueue.main.async {
                    AlertView.show(error: "Sync Failed. Check The Internet.")
                }
            }
        }
    }
    
    
}

extension CardViewController:CardEditorDelegate{
    func cardEditor(DidFinishSaveCard card: Card) {
        loadCard()
    }
}
