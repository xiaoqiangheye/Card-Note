//
//  Constaint.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/13.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation


class Constaint{
    var type:Constaint.type!
    var value:Any!
    enum type{
        case color
        case tag
    }
    init(_ type:Constaint.type!, _ value: Any) {
        self.type = type
        self.value = value
    }
}
