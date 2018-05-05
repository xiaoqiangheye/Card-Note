//
//  UIMapPickerDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation


@objc protocol UIMapPickerDelegate:NSObjectProtocol{
    func UIMapDidSelected(image:UIImage,poi:AMapPOI?, formalAddress:String)
    @objc optional func UIMapWillBeSelected()
}
