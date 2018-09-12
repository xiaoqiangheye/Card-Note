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
    
    init(id:String,title:String){
        let date = NSDate()
        let interval = date.timeIntervalSince1970
         super.init(title: title, tag: nil, description: "", id: id, definition: "", color: nil, cardType: CardType.example.rawValue,modifytime:String(interval))
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    public func getExample()->NSAttributedString?{
        var url = Constant.Configuration.url.attributedText
        url.appendPathComponent(self.getId() + ".rtf")
        do{
            let data = try Data(contentsOf: url)
            var ducumentAttribute:NSDictionary?
            
            let attr = try NSAttributedString(data: data, options: [ NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.rtf], documentAttributes: &ducumentAttribute)
            return attr
        }catch let error{
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func setExample(_ attr:NSAttributedString){
        var url = Constant.Configuration.url.attributedText
        url.appendPathComponent(self.getId() + ".rtf")
        let range = NSRange(location: 0, length: attr.length)
        do{
            let data = try attr.data(from: range, documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf])
            try data.write(to: url)
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
