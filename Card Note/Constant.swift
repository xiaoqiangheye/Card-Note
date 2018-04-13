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
    enum TextMode {
        case PlaceHolderMode
        case EditingMode
    }
    
    struct Color{
        static let 水荡漾清猿啼 = UIColor(red: 199/255, green: 255/255, blue: 236/236, alpha: 1)
        static let 西瓜红 = UIColor(red: 253/255, green: 91/255, blue: 120/255, alpha: 1)
        static let 勿忘草色 = UIColor(red: 123/255, green: 191/255, blue: 234/255, alpha: 1)
        static let 江戸紫 = UIColor(red: 111/255, green: 89/255, blue: 156/255, alpha: 1)
        static let 花季色 = UIColor(red: 227/255, green: 170/255, blue: 203/255, alpha: 1)
    }
    
    struct Key{
        static let Tags = "tags"
        static let ifLauched = "ifLauched"
    }
}
