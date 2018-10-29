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
    var advantageView:UITextView!
    var logo:UIImageView!
    private let ADVANTAGE_BASIC = ["10 Notes Most", "Limited Time for voice record", "Non-Cloud Storage", "Non-Sync", "Translation across different languages", "Voice,Photo,Video Record","Map Record"]
    private let ADVANTAGE_PREMIUM = ["Limitless Notes", "Limitless Time for voice record", "Cloud Storage", "Auto-Sync", "Limitless Devices", "Translation across different languages", "Voice,Photo,Video Record" ,"Voice to Text Conversion","Map Record"]
    init(plan:Plan) {
        super.init(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.5))
        logo = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        logo.image = UIImage(named: "white_version_logo")
        self.addSubview(logo)
        
        //title
        title = UILabel(frame: CGRect(x: 40, y: 10, width: UIScreen.main.bounds.width * 0.8, height: 30))
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textAlignment = .left
        

        advantageView = UITextView(frame: CGRect(x: 20, y: 40, width: self.frame.width, height: self.frame.height - 40))
        advantageView.isEditable = false
        advantageView.isSelectable = false
        advantageView.backgroundColor = .clear
        advantageView.textColor = .white
        advantageView.font = UIFont.systemFont(ofSize: 15)
        advantageView.textAlignment = .left
       // advantageView = UIView(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width * 0.8, height: 320))
      //  advantageView.backgroundColor = .flatWhite
        self.addSubview(title)
        self.addSubview(advantageView)
        
        //self decoration
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowOpacity = 0.5
        
        switch plan{
        case Plan.basic:
            self.backgroundColor = Constant.Color.themeColor
            self.layer.shadowColor = Constant.Color.themeColor.cgColor
            title.text = "Basic"
            advantageView.text = "Unlimited note cards\nNo AI Support\nMay have Ads"
        case Plan.premium:
            self.backgroundColor = UIColor.flatPurple
            self.layer.shadowColor = UIColor.flatPurple.cgColor
            title.text = "Premium"
            advantageView.text = "Unlimited note cards\nAI Support\n\t-OCR\n\t-Translation\n\t-Voice Recognition\nNo Ads"
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
