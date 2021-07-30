//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/6/5.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
class MovieCard:Card{
    var path:String
    init(id:String,parent:Card) {
        self.path = Constant.Configuration.url.Movie.appendingPathComponent(id + ".mov").path
        super.init(title: "", tag: nil, description: "", id: id, definition: "", color: nil, cardType: Card.CardType.movie.rawValue, modifytime: "")
        self.setParent(card: parent)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.path, forKey: "path")
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        self.path = aDecoder.decodeObject(forKey: "path") as! String
        super.init(coder: aDecoder)
    }
    
}
