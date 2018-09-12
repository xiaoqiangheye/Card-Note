//
//  ListCard.swift
//  Card Note
//
//  Created by 强巍 on 2018/6/5.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
class ListCard:Card{
    var list:[String]
    init(id:String, type:String, title:String){
    list = [String]()
    super.init(title: title, tag: nil, description: "", id: id, definition: "", color: nil, cardType: type, modifytime: "")
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(list, forKey: "list")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.list = aDecoder.decodeObject(forKey: "list") as! [String]
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
