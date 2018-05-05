//
//  TextCard.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/22.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation



class TextCard:Card{
    var text:String
    init(text:String) {
        self.text = text
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        super.init(title: "", tag: "", description: "", id: "", definition: "", color: .orange, cardType: CardType.text.rawValue,modifytime:strNowTime)
    }
    
    func getText()->String{
        return self.text
    }
    
    func setText(_ text:String){
        self.text = text
    }
    required init?(coder aDecoder: NSCoder) {
        self.text = aDecoder.decodeObject(forKey: "text") as! String
        super.init(coder: aDecoder)
       // fatalError("init(coder:) has not been implemented")
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(text, forKey: "text")
    }
}
