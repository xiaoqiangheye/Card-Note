//
//  CardViewPanelDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/9.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
@objc protocol CardViewPanelDelegate:NSObjectProtocol{
    @objc optional func deleteButtonClicked(_ controllPanel:CardViewPanel)
    @objc optional func shareButtonClicked(_ controllPanel:CardViewPanel)
}
