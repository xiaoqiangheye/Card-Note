//
//  CardView.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/4.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit


class CardView: UIView{
    var card:Card!
    var label:UILabel = UILabel()
    var labelofDes:UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    class ExaView:UIView,UITextViewDelegate{
        var textView = UITextView()
        var example:String = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
    class func getSingleCardView(card:Card)->CardView{
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let cardView = CardView(frame: CGRect(x: 0, y: 0, width: x*0.8, height: y/4))
        cardView.card = card
        cardView.center.x = x/2
        cardView.backgroundColor = card.color
        cardView.layer.cornerRadius = 20
        
        let title:String = card.getTitle()
        let label = UILabel(frame: CGRect(x:20,y:0,width:cardView.bounds.width-20,height:cardView.bounds.height/5))
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.center.x = cardView.frame.width/2
        label.textColor = .white
        cardView.label = label
        cardView.addSubview(label)
        
        /*
        let tag:String = card.getTag()
        let labelOfTag = UILabel(frame: CGRect(x:20,y:label.bounds.height,width:cardView.bounds.width-20,height:cardView.bounds.height/5))
        labelOfTag.text = tag
        labelOfTag.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        cardView.addSubview(labelOfTag)
        */
        
        let definition:String = card.getDefinition()
        let labelOfDes = UILabel(frame: CGRect(x:20,y:label.frame.origin.y,width:cardView.bounds.width-20,height:cardView.bounds.height/2))
        labelOfDes.text = definition
        labelOfDes.font = UIFont.boldSystemFont(ofSize: 15)
        labelOfDes.numberOfLines = 3
        labelOfDes.lineBreakMode = .byWordWrapping
        labelOfDes.textColor = .white
        cardView.labelofDes = labelOfDes
        cardView.addSubview(labelOfDes)
        return cardView
    }
    
    class func getSubCardView(_ card:Card)->CardView{
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let cardView = CardView(frame: CGRect(x: 0, y: 0, width: x*0.7, height: y/4))
        cardView.card = card
        cardView.center.x = x/2
        cardView.backgroundColor = card.color
        cardView.layer.cornerRadius = 20
        
        let title:String = card.getTitle()
       let label = UILabel(frame: CGRect(x:0,y:0,width:cardView.bounds.width,height:cardView.bounds.height/5))
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.center.x = cardView.frame.width/2
        label.textColor = .white
        label.textAlignment = .center
        cardView.label = label
        cardView.addSubview(label)
        
        /*
        let tag:String = card.getTag()
        labelOfTag = UILabel(frame: CGRect(x:0,y:label.bounds.height,width:cardView.bounds.width,height:cardView.bounds.height/5))
        labelOfTag.text = tag
        labelOfTag.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        cardView.addSubview(labelOfTag)
       */
        
        let definition:String = card.getDefinition()
        let labelOfDes = UILabel(frame: CGRect(x:0,y:label.frame.origin.y + label.frame.height + 20,width:cardView.bounds.width,height:cardView.bounds.height/2))
        labelOfDes.text = definition
        labelOfDes.font = UIFont.boldSystemFont(ofSize: 15)
        labelOfDes.numberOfLines = 3
        labelOfDes.lineBreakMode = .byWordWrapping
        labelOfDes.textColor = .white
        cardView.labelofDes = labelOfDes
        cardView.addSubview(labelOfDes)
        return cardView
    }
    
    class func singleExampleView()->ExaView{
        let view = ExaView()
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4)
        view.backgroundColor = UIColor.orange
        view.center.x = UIScreen.main.bounds.width/2
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1,height:1)
        view.layer.shadowOpacity = 0.5

        view.textView.layer.cornerRadius = 15
        view.textView.frame = CGRect(x:0, y:50, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4 - 50)
        view.textView.center.x = view.bounds.width/2
        view.textView.backgroundColor = .clear
        
        let Label = UILabel()
        Label.textColor = .white
        Label.backgroundColor = .clear
        Label.font = UIFont.boldSystemFont(ofSize: 15)
        Label.text = "Example"
        Label.textAlignment = .center
        Label.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        Label.center.y = 25
        Label.center.x = view.bounds.width/2
        view.addSubview(view.textView)
        view.addSubview(Label)
        return view
    }
}
