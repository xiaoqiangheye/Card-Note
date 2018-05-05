//
//  CardEditorView.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/10.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class CardEditorView:UIView{
    var cardTitle: UITextView! = UITextView()
    var classification: UITextView! = UITextView()
    var definition: UITextView! = UITextView()
    var descriptions: UITextView! = UITextView()
    var color:UIColor = UIColor.red
    var cardBackGround = UIView()
    var card:Card?
    var subCards:[CardView] = [CardView]()
    var examples:[CardView.ExaView] = [CardView.ExaView]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardTitle.frame = CGRect(x: 0, y: 0, width: self.bounds.width*0.8, height: 50)
        cardTitle.font = UIFont.boldSystemFont(ofSize: 20)
        cardTitle.textColor = .white
        cardTitle.backgroundColor = .clear
        cardTitle.center.x = self.bounds.width/2
        cardTitle.layer.cornerRadius = 10
        cardTitle.textAlignment = .center
        classification.frame = CGRect(x: 0, y: 50, width: self.bounds.width*0.8, height: 30)
        classification.font = UIFont.systemFont(ofSize: 15)
        classification.textColor = .white
        classification.backgroundColor = .clear
        classification.center.x = self.bounds.width/2
        classification.layer.cornerRadius = 10
        let definitionLabel = UILabel()
        definitionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        definitionLabel.text = "Definition"
        definitionLabel.frame = CGRect(x:20, y: classification.frame.origin.y + classification.frame.height + 20, width: self.bounds.width, height: 20)
        definitionLabel.textColor = .white
        
        definition.frame = CGRect(x: 0, y: definitionLabel.frame.origin.y + definitionLabel.frame.height + 20, width: self.bounds.width*0.8, height: 100)
        definition.font = UIFont.systemFont(ofSize: 15)
        definition.textColor = .white
        definition.backgroundColor = .clear
        definition.center.x = self.bounds.width/2
        definition.layer.cornerRadius = 10
        definition.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
        
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        descriptionLabel.text = "Description"
        descriptionLabel.textColor = .white
        descriptionLabel.frame = CGRect(x: 20, y: definition.frame.origin.y + definition.frame.height + 20, width: self.bounds.width, height: 20)
        
        descriptions.frame = CGRect(x:0, y: descriptionLabel.frame.height + descriptionLabel.frame.origin.y + 20, width: self.bounds.width*0.8, height: 200)
        descriptions.font = .systemFont(ofSize:15)
        descriptions.textColor = .white
        descriptions.backgroundColor = .clear
        descriptions.center.x = self.bounds.width/2
        descriptions.layer.cornerRadius = 10
        descriptions.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
        
        cardBackGround.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height-20)
        cardBackGround.backgroundColor = color
        cardBackGround.addSubview(cardTitle)
        cardBackGround.addSubview(classification)
        cardBackGround.addSubview(definition)
        cardBackGround.addSubview(descriptions)
        cardBackGround.addSubview(definitionLabel)
        cardBackGround.addSubview(descriptionLabel)
        cardBackGround.layer.cornerRadius = 15
        
        self.addSubview(cardBackGround)
       
    }
    
    func loadCard(_ card:Card){
        descriptions.text = card.getDescription()
        definition.text = card.getDefinition()
        cardTitle.text = card.getTitle()
        classification.text = card.getTag()
        cardBackGround.backgroundColor = card.getColor()
        self.card = card
        
        var cumulatedHeight = descriptions.frame.origin.y + descriptions.frame.height + 20
        /*
        for example in card.getExamples(){
            let exaView = CardView.singleExampleView()
            exaView.textView.text = example
            exaView.example = example
            exaView.frame.origin.y = cumulatedHeight
            cumulatedHeight += exaView.frame.height + 20
            cardBackGround.addSubview(exaView)
            cardBackGround.frame.size.height += exaView.frame.height + 20
            self.frame.size.height += exaView.frame.height + 20
            self.examples.append(exaView)
        }
 */
        
        for card in card.getChilds(){
            let cardView = CardView.getSubCardView(card)
            cardView.frame.origin.y = cumulatedHeight
            cardView.layer.shadowOpacity = 0.5
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOffset = CGSize(width:1, height:1)
            cumulatedHeight += cardView.frame.height + 20
            cardBackGround.addSubview(cardView)
            cardBackGround.frame.size.height += cardView.frame.height + 20
            self.frame.size.height += cardView.frame.height + 20
            self.subCards.append(cardView)
        }
        
    }
    
    func reLoad(){
        descriptions.text = card?.getDescription()
        definition.text = card?.getDefinition()
        cardTitle.text = card?.getTitle()
        classification.text = card?.getTag()
        cardBackGround.backgroundColor = card?.getColor()
        
        for subview in cardBackGround.subviews{
            if subview.isKind(of: CardView.self) || subview.isKind(of: CardView.ExaView.self){
                subview.removeFromSuperview()
            }
        }
        
        var cumulatedHeight = descriptions.frame.origin.y + descriptions.frame.height + 20
        for example in examples{
            cardBackGround.addSubview(example)
            cardBackGround.frame.size.height += example.frame.height + 20
        }
        
        for card in subCards{
            cardBackGround.addSubview(card)
            cardBackGround.frame.size.height += card.frame.height + 20
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
