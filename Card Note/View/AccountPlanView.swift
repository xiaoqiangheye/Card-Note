//
//  AccountPlanView.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/10.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import Font_Awesome_Swift

class AccountPlanView:UIView{
    var title:UILabel!
    var price:UILabel!
    var advantageView:UIView!
    private let ADVANTAGE_BASIC = ["10 Notes Most", "Limited Time for voice record", "Non-Cloud Storage", "Non-Sync", "Translation across different languages", "Voice,Photo,Video Record","Map Record"]
    private let ADVANTAGE_PREMIUM = ["Limitless Notes", "Limitless Time for voice record", "Cloud Storage", "Auto-Sync", "Limitless Devices", "Translation across different languages", "Voice,Photo,Video Record" ,"Voice to Text Conversion","Map Record"]
    init(plan:Plan) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.6))
        title = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 30))
        title.textColor = .white
        title.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        title.textAlignment = .center
        price = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 50))
        price.textColor = .white
        price.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        price.textAlignment = .left
        advantageView = UIView(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width * 0.8, height: 320))
        advantageView.backgroundColor = .flatWhite
        self.addSubview(title)
        self.addSubview(price)
        self.addSubview(advantageView)
        
        //self decoration
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.8
        
        switch plan{
        case Plan.basic:
            self.backgroundColor = UIColor.flatBlue
            title.text = "Basic"
            var cumulatedHeight = 0
            for advantage in ADVANTAGE_BASIC{
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 20))
            label.textColor = .black
            label.font = UIFont(name: "ChalkboardSE-Light", size: 15)
            label.text = advantage
            label.numberOfLines = 3
            label.textAlignment = .center
            label.backgroundColor = UIColor.flatWhite
                label.frame.size.height = UILabel.heightWithConstrainedWidth(width: UIScreen.main.bounds.width * 0.8, font: label.font, str: label.text as! NSString) + 20
            label.frame.origin.y = CGFloat(cumulatedHeight)
            cumulatedHeight += Int(label.frame.height)
            advantageView.addSubview(label)
            }
            
        case Plan.premium:
            self.backgroundColor = UIColor.flatPurple
            title.text = "Professional"
            var cumulatedHeight = 0
            for advantage in ADVANTAGE_PREMIUM{
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 20))
                label.textColor = .black
                label.textAlignment = .center
                label.font = UIFont(name: "ChalkboardSE-Light", size: 15)
                label.text = advantage
                label.numberOfLines = 3
                label.backgroundColor = UIColor.flatWhite
                label.lineBreakMode = .byWordWrapping
                label.frame.size.height = UILabel.heightWithConstrainedWidth(width: UIScreen.main.bounds.width * 0.8, font: label.font, str: label.text as! NSString) + 20
                label.frame.origin.y = CGFloat(cumulatedHeight)
                cumulatedHeight += Int(label.frame.height)
                advantageView.addSubview(label)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Plan {
        case basic
        case premium
    }
    
    
}

extension UILabel{
    class func heightWithConstrainedWidth ( width :  CGFloat , font :  UIFont,  str : NSString )  ->  CGFloat  {
        let constraintRect =  CGSize ( width : width , height :  CGFloat . greatestFiniteMagnitude )
        let boundingBox =  str.boundingRect ( with: constraintRect , options :  NSStringDrawingOptions . usesLineFragmentOrigin , attributes :  [ kCTFontAttributeName as NSAttributedStringKey : font ], context :  nil )
        // 返回boundingBox的。高度
        return boundingBox.height
    }
}
