//
//  Constaint.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/13.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Font_Awesome_Swift
class Constraint{
    var type:Constraint.type!
    var value:Any!
    enum type{
        case color
        case tag
    }
    init(_ type:Constraint.type!, _ value: Any) {
        self.type = type
        self.value = value
    }
}  
