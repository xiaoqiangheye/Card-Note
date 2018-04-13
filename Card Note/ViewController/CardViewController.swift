//
//  CardViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/5.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class CardViewController:UIViewController,UIScrollViewDelegate{
    var scrollView:UIScrollView!
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
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.frame = CGRect(x: 0, y: 40, width: self.view.bounds.width, height: self.view.bounds.height-40)
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:10)
        self.view.addSubview(scrollView)
    }
    
    func loadCard(){
          scrollView.contentSize = CGSize(width:self.view.bounds.width,height:10)
        for subview in scrollView.subviews{
            subview.removeFromSuperview()
        }
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
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
    
    func loadCardWithConstaints(_ constaints:[Constaint]){
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
        
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent("card.txt")
        if let dateRead = try? Data.init(contentsOf: url!){
            var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
            if cardList == nil{
                cardList = [Card]()
            }
            var filterdCardList = [Card]()
            for card in cardList!{
                if colorConstaints.contains(card.color) && tagConstaints.contains(card.getTag()){
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
        
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer){
        let card:Card = (sender.view as! CardView).card
        self.performSegue(withIdentifier: "cardEditor", sender: card)
    }
    
}
