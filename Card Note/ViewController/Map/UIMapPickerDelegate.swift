//
//  UIMapPickerDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Mapbox
import MapboxGeocoder
@objc protocol UIMapPickerDelegate:NSObjectProtocol{
    @objc optional func UIMapDidSelected(image:UIImage,poi:AMapPOI?, formalAddress:String)
    @objc optional func UIMapDidSelected(image:UIImage,place:Placemark?)
    @objc optional func UIMapDidSelected(image:UIImage,name:String,address:String,coordinate:CLLocationCoordinate2D)
    @objc optional func UIMapWillBeSelected()
}
