//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
@objc protocol LocationListViewDelegate{
    @objc optional func cell(cellDidClicked cell:LocationListView.LocationCellView,Pois:AMapPOI)
    @objc optional func cell(cellDidClicked cell:LocationListView.LocationCellView)
}

