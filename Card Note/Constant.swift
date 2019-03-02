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
        static let VERSION = 1.2
        static let SHARE_SECREAT_KET = "95b689872bae44ff9de22d57f3b5510c"
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
        static var AccountPlan:String = "basic"
        struct Cloud{
            static let SYNC_ONLY_WITH_WIFI = "auto-sync-if-wifi-presents"
            static let AUTO_SYNC = "auto-sync"
        }
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
        static let themeColor = UIColor(red: 70/255, green: 175/255, blue: 229/255, alpha: 1)
        static let translusentGray = UIColor(red: 202/255, green: 201/255, blue: 187/255, alpha: 0.7)
        static let darkWhite = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.7)
        static let blueLeft = UIColor(red:44/255.0,green:181/255.0,blue:241/255.0,alpha:1)
        static let blueRight = UIColor(red:97/255.0,green:130/255.0,blue:255/255.0,alpha:1)
        static let redLeft = UIColor(red:255/255.0,green:178/255.0,blue:144/255.0,alpha:1)
        static let redRight = UIColor(red:255/255.0,green:116/255.0,blue:120/255.0,alpha:1)
        static let greenLeft = UIColor(red:68/255.0,green:227/255.0,blue:171/255.0,alpha:1)
        static let greenRight = UIColor(red:59/255.0,green:218/255.0,blue:195/255.0,alpha:1)
        static let blueWhite = UIColor(red:250/255, green: 250/255, blue: 255/255, alpha: 1)
        static let translusentBlack = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.7)
    }
    
    struct Key{
        static let Token = "userToken"
        static let Tags = "tags"
        static let ifLauched = "ifLauched"
        static let loggedEmail = "loggedEmail"
        static let loggedUsername = "username"
        static let loggedID = "id"
        static let OCRTrial = "ocrtrial"
        static let TranslateTrial = "transtrial"
        static let VoiceTrial = "voicetrial"
    }
}
