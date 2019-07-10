//
//  ExampleCard.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/22.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class ExampleCard:Card{
    init() {
        let date = NSDate()
        let interval = date.timeIntervalSince1970
        super.init(title: "Key", tag: nil, description: "", id: UUID().uuidString, definition: "Value", color: nil, cardType: CardType.example.rawValue,modifytime:String(interval))
       // self.example = example
    }
    
    init(key:String,value:String){
        let date = NSDate()
        let interval = date.timeIntervalSince1970
        super.init(title: key, tag: nil, description: "", id: UUID().uuidString, definition: value, color: nil, cardType: CardType.example.rawValue,modifytime:String(interval))
    }
    
    init(id:String,title:String){
        let date = NSDate()
        let interval = date.timeIntervalSince1970
         super.init(title: title, tag: nil, description: "", id: id, definition: "", color: nil, cardType: CardType.example.rawValue,modifytime:String(interval))
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
