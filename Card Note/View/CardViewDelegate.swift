//
//  CardViewDelegate.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/16.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation

@objc protocol CardViewDelegate:NSObjectProtocol{
    @objc optional func deleteButtonClicked()
    @objc optional func deleteButtonClicked(view:CardView)
    @objc optional func shareButtonCllicked()
    @objc optional func cardView(commentShowed picView:CardView.PicView)
    @objc optional func cardView(commentHide picView:CardView.PicView)
    @objc optional func cardView(up view:CardView)
    @objc optional func cardView(down view:CardView)
}
