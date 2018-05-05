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
    private var example:String
    init(example:String) {
        self.example = example
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        super.init(title: "", tag: "", description: "", id: "", definition: "", color: UIColor.orange, cardType: CardType.example.rawValue,modifytime:strNowTime)
       // self.example = example
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(example, forKey: "example")
    }
    
    public func getExample()->String{
    return example
    }
    
    public func setExample(_ example:String){
    self.example = example
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.example = aDecoder.decodeObject(forKey: "example") as! String
        super.init(coder: aDecoder)
    }

}
