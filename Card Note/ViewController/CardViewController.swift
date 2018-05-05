//
//  CardViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/5.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class CardViewController:UIViewController,UIScrollViewDelegate,UITextFieldDelegate{
    @IBOutlet weak var addCardButton: UIButton!
    var scrollView:UIScrollView!
    var searchTextView:SearchBar = SearchBar()
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
        //filter Button
        let filterButton = UIButton()
        filterButton.frame = CGRect(x: 40, y: searchTextView.frame.height + searchTextView.frame.origin.y + 10, width: 60, height: 30)
        
        let string = NSAttributedString(string: "Filter", attributes: [NSAttributedStringKey.font:UIFont(name: "AmericanTypewriter", size: 14)])
        print(string)
        filterButton.setAttributedTitle(string, for: .normal)
        filterButton.setTitleColor(.black, for: .normal)
        filterButton.layer.cornerRadius = 2
        filterButton.backgroundColor = .white
        filterButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        filterButton.layer.shadowColor = UIColor.black.cgColor
        filterButton.layer.shadowOpacity = 0.5
        self.view.addSubview(filterButton)
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.frame = CGRect(x: 0, y: filterButton.frame.origin.y + filterButton.frame.height + 10, width: self.view.bounds.width, height: self.view.bounds.height-(filterButton.frame.origin.y + filterButton.frame.height + 10))
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:10)
        self.view.addSubview(scrollView)
        
        self.view.bringSubview(toFront: addCardButton)
        
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
          scrollView.contentSize = CGSize(width:self.view.bounds.width,height:10)
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
            
            var cumulatedY = 10
            for card in cardList!{
                
                let cardView:CardView = CardView.getSingleCardView(card:card)
                cardView.frame.origin.y = CGFloat(cumulatedY)
                cumulatedY += Int(cardView.bounds.height
                + 10)
                let tapGesture = UITapGestureRecognizer()
                tapGesture.addTarget(self, action: #selector(tapped))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardView.addGestureRecognizer(tapGesture)
                scrollView.addSubview(cardView)
                scrollView.contentSize = CGSize(width: self.view.bounds.width, height: scrollView.contentSize.height + cardView.bounds.height + 10)
            }
            
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
                if colorConstaints.contains(card.color) && tagConstaints.contains(card.getTag()){
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
                scrollView.addSubview(cardView)
                scrollView.contentSize = CGSize(width: self.view.bounds.width, height: scrollView.contentSize.height + cardView.bounds.height + 10)
            }
        }
        
    
    
    @objc func tapped(_ sender:UITapGestureRecognizer){
        let card:Card = (sender.view as! CardView).card
        self.performSegue(withIdentifier: "cardEditor", sender: card)
    }
    
}
