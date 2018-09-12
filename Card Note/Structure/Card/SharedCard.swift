
//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/26.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class SharedCard:Card{
    var card:Card!
    var username:String = ""
    var date:String = ""
    var states:[String] = [State.readable.rawValue]
    enum State:String{
        case branchable
        case readable
        case reprintable
    }
    
    init(card:Card,datetime:String,states:[String],username:String) {
        super.init(title: card.getTitle(), tag: card.getTag(), description: card.description, id: card.getId(), definition: card.getDefinition(), color: card.getColor(), cardType: card.getType(), modifytime: card.getType())
        self.date = datetime
        self.states = states
        self.username = username
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        
        //fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

