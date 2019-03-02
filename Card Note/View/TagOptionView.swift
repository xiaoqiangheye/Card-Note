//
//  TagOptionView.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class TagOptionView:UIView,UIScrollViewDelegate{
    private var scrollView:UIScrollView!
    weak var delegate:TapOptionViewDelegate?
    var tagColor:UIColor?
    var tags:Set<TagView> = Set<TagView>()
    var exitButton:UIButton!
    init(frame: CGRect,existingTags:[String],color:UIColor...) {
        if color.count > 0{
        tagColor = color[0]
        }
        //scrollView
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 40, width: frame.width, height: frame.height - 40))
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        super.init(frame: frame)
        scrollView.delegate = self
        self.addSubview(scrollView)
        self.clipsToBounds = true
    
        
        //loadTag
        loadTag(existingTags)
        
        //self decoration
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        
        //exitButton
        exitButton = UIButton(frame: CGRect(x: self.frame.width - 40, y: 10, width: 30, height: 30))
        exitButton.setFAIcon(icon: .FATimes, forState: .normal)
        exitButton.addTarget(self, action: #selector(exit), for: .touchDown)
        exitButton.setFATitleColor(color: .black)
        self.addSubview(exitButton)
    }
    
    
    @objc func exit(){
        if delegate != nil{
            delegate?.willBeRemovedFromSuperView?(tagOptionView: self)
        }
       self.removeFromSuperview()
    }
    
    @objc func createTag(){
       let addTagView =  AddTagView.show(superView:self.superview!)
        self.exitButton.isEnabled = false
        addTagView.addTagCancelledHandler = {[unowned self] in
            self.exitButton.isEnabled = true
        }
        
        addTagView.addTagCompletionHandler = {[unowned self] tag in
            let tagView:TagView
            if self.tagColor != nil{
                tagView = TagView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.8, height: 30), tag: tag, colors: self.tagColor!)
            }else{
                tagView = TagView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.8, height: 30), tag: tag, colors: Constant.Color.blueLeft)
            }
        self.exitButton.isEnabled = true
        self.tags.insert(tagView)
        self.scrollView.addSubview(tagView)
        self.reloadTag()
        }
    }
    
    func loadTag(_ existingTag:[String]){
        let tags = UserDefaults.standard.array(forKey: Constant.Key.Tags)
        if tags == nil || tags?.count == 0{return}
        var cumulatedHeight:CGFloat = 0
        let createTagView = UIButton(frame: CGRect(x: 0, y: cumulatedHeight, width: self.frame.width * 0.8, height: 30))
        createTagView.center.x = self.frame.width/2
        createTagView.backgroundColor = .white
        createTagView.setFAIcon(icon: .FAPlus, forState: .normal)
        createTagView.setFATitleColor(color: .black)
        createTagView.layer.cornerRadius = 10
        createTagView.layer.shadowColor = Constant.Color.translusentGray.cgColor
        createTagView.layer.shadowRadius = 5
        createTagView.layer.shadowOffset = CGSize(width: 0, height: 5)
        createTagView.layer.shadowOpacity = 0.5
        createTagView.addTarget(self, action: #selector(createTag), for: .touchDown)
        self.scrollView.addSubview(createTagView)
        cumulatedHeight = 40
        for tag in tags!{
            if existingTag.contains(tag as! String){continue}
            let tagView:TagView!
            if tagColor != nil{
            tagView = TagView(frame: CGRect(x: 0, y: cumulatedHeight, width: self.frame.width * 0.8, height: 30), tag: tag as! String, colors: tagColor!)
            }else{
            tagView = TagView(frame: CGRect(x: 0, y: cumulatedHeight, width: self.frame.width * 0.8, height: 30), tag: tag as! String)
            }
            tagView.center.x = self.frame.width/2
            self.tags.insert(tagView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(tagViewTapped(sender:)))
            tagView.addGestureRecognizer(tap)
            self.scrollView.addSubview(tagView)
            cumulatedHeight += 40
            scrollView.contentSize.height = tagView.frame.height + tagView.frame.origin.y + 10
        }
    }
    
    func reloadTag(){
        var cumulatedHeight:CGFloat = 40
        scrollView.contentSize.height = 0
        for tag in self.tags{
            tag.frame.origin.y = cumulatedHeight
            tag.center.x = self.frame.width/2
            cumulatedHeight += 40
            scrollView.contentSize.height = tag.frame.height + tag.frame.origin.y + 10
        }
    }
    
    @objc private func tagViewTapped(sender:UITapGestureRecognizer){
        if sender.state == .ended{
            if delegate != nil{
                delegate?.tagClicked!(tag:(sender.view as! TagView).getTag())
                sender.view?.removeFromSuperview()
                self.tags.remove(sender.view as! TagView)
                if self.tags.count > 0{
                    reloadTag()}else{
                    self.removeFromSuperview()
                    if delegate != nil{
                        delegate?.willBeRemovedFromSuperView?(tagOptionView: self)
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc protocol TapOptionViewDelegate:NSObjectProtocol{
    @objc optional func tagClicked(tag:String)
    @objc optional func willBeRemovedFromSuperView(tagOptionView:TagOptionView)
}
