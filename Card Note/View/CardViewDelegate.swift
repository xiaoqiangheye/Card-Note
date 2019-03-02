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
    @objc optional func cardView(translate view:CardView,text:String)
    @objc optional func picView(extractText:CardView.PicView)
    @objc optional func voiceView(recognition cardView:CardView.VoiceCardView)
    @objc optional func movieView(expand videoView:CardView.MovieView)
}
