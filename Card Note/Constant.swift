//
//  Constant.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/4.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class Constant{
    struct Configuration{
        static let version = 1.0
        static let sharedSecret = "95b689872bae44ff9de22d57f3b5510c"
        struct url {
            static let manager = FileManager.default
            static var url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
            static var user:URL = url.appendingPathComponent(loggedID)
            static let Card:URL = user
            static let PicCard:URL = user
            static let Audio:URL = url.appendingPathComponent("audio")
            static let Map:URL = url.appendingPathComponent("mapPic")
            static let Movie:URL = url.appendingPathComponent("movie")
            static let temporary:URL = url.appendingPathComponent("temp")
            static let attributedText = url.appendingPathComponent("attr")
        }
        static var AccountPlan:String = ""
    }
    
    enum TextMode {
        case UnorderedListStartMode
        case UnorderedListMode
        case UnorderedListEndMode
        case OrderedListStartMode
        case OrderedListEndMode
        case OrderedListMode
        case ItalicMode
        case BoldMode
        case UnderLineMode
        case StrokeMode
    }
    
    enum AccountPlan:String{
        case premium = "premium"
        case basic = "basic"
    }
    
    struct Color{
        static let 水荡漾清猿啼 = UIColor(red: 199/255, green: 255/255, blue: 236/236, alpha: 1)
        static let 西瓜红 = UIColor(red: 253/255, green: 91/255, blue: 120/255, alpha: 1)
        static let 勿忘草色 = UIColor(red: 123/255, green: 191/255, blue: 234/255, alpha: 1)
        static let 江戸紫 = UIColor(red: 111/255, green: 89/255, blue: 156/255, alpha: 1)
        static let 花季色 = UIColor(red: 227/255, green: 170/255, blue: 203/255, alpha: 1)
    }
    
    struct Key{
        static let Token = "userToken"
        static let Tags = "tags"
        static let ifLauched = "ifLauched"
        static let loggedEmail = "loggedEmail"
        static let loggedUsername = "username"
        static let loggedID = "id"
    }
}
