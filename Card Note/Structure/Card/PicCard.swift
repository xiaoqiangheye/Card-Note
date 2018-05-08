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
        super.init(title: "", tag: "", description: "", id: UUID().uuidString, definition: "", color: .clear, cardType: Card.CardType.picture.rawValue, modifytime: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
       // self.pic = aDecoder.decodeObject(forKey: "pic") as? UIImage
        super.init(coder: aDecoder)
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent(self.getId() + ".jpg")
        let im = UIImage(named: (url?.path)!)
        if im != nil{
            self.pic = im
        }else{
            self.pic = #imageLiteral(resourceName: "bubble")
            /*deprecared
            User.getImage(email: loggedemail, cardID: self.getId(), completionHandler: { (image:UIImage?) in
                if image != nil{
                    DispatchQueue.main.async {
                       self.pic = image
                    }
                }
            })
            */
            User.downloadPhotosUsingQCloud(email: loggedemail, cardID: self.getId()) { (bool, error) in
                if bool{
                    self.pic = UIImage(contentsOfFile: (url?.path)!)
                }
            }
        }
       
       // fatalError("init(coder:) has not been implemented")
    }
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(pic, forKey: "pic")
    }
}
