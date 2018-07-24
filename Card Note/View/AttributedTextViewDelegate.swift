//
//  AttributedTextViewDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/29.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation

@objc protocol AttributedTextViewDelegate{
    @objc optional func selectFont(height:CGFloat)
    @objc optional func selectFontColor()
    
}
