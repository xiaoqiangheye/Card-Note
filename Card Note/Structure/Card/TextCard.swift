//
//  TextCard.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/22.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation



class TextCard:Card{
    init() {
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        super.init(title: "", tag: nil, description: "", id: UUID().uuidString, definition: "", color: nil, cardType: CardType.text.rawValue,modifytime:strNowTime)
    }
    
    init(id:String){
    super.init(title: "", tag: nil, description: "", id: id, definition: "", color: nil, cardType: CardType.text.rawValue, modifytime: "")
    }
    
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       // fatalError("init(coder:) has not been implemented")
    }
    
   
    
   
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
}
