//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/23.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class PicCard:Card{
    var pic:UIImage!
    init(_ pic:UIImage) {
        self.pic = pic
        super.init(title: "", tag: nil, description: "", id: UUID().uuidString, definition: "", color: .clear, cardType: Card.CardType.picture.rawValue, modifytime: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        var url = Constant.Configuration.url.PicCard
        url.appendPathComponent(self.getId() + ".jpg")
        let im = UIImage(named: (url.path))
        if im != nil{
            self.pic = im
        }else{
            
            Cloud.downloadAsset(id: self.getId(), type: "IMAGE") { (bool, error) in
                self.pic = UIImage(named: (url.path))
            }
        }
    }
    
   
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(pic, forKey: "pic")
    }
}
