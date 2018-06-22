//
//  CardEditorDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/6/15.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
@objc protocol CardEditorDelegate:NSObjectProtocol{
    @objc optional func saveSubCards(card:Card)
}
