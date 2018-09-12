//
//  TagInputView.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
class TagInputView:UIView,TapOptionViewDelegate{
    private var cumulatedX:CGFloat = 0
    private var cumulatedY:CGFloat = 0
    private var deleteButton:UIButton!
    var plusButton:UIButton!
    weak var delegate:TagInputViewDelegate?
    var tagList:[UILabel] = [UILabel]()
    var tags:[String] = [String]()
    class TagLabel:UILabel{
        init(text:String,font:UIFont) {
            super.init(frame:CGRect(x: -1, y: -1, width: 30, height: 30))
            self.font = font
            //self.clipsToBounds = true
            self.text = text
           // self.backgroundColor = .white
            self.textColor = .gray
            self.numberOfLines = 1
            self.textAlignment = .center
           // self.layer.borderWidth = 1
            self.sizeToFit()
            self.frame.size.width += 30
            self.frame.size.height = 30
            self.layer.cornerRadius = self.frame.size.height/2
            self.layer.backgroundColor = UIColor.white.cgColor
            self.layer.shadowOpacity = 0.7
            self.layer.shadowColor = Constant.Color.translusentGray.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shadowRadius = 5
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    init(frame: CGRect,tags:[String]) {
        super.init(frame: frame)
        
        deleteButton = UIButton(frame: CGRect(x: self.frame.width - 30, y: self.frame.height - 30, width: 30, height: 30))
        deleteButton.setFAIcon(icon: .FACheckCircle, iconSize: 30, forState: .normal)
        deleteButton.setTitleColor(.gray, for: .normal)
        deleteButton.alpha = 0.8
        deleteButton.addTarget(self, action: #selector(popTag), for: .touchDown)
        
        //plus button
        plusButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        plusButton.setFAIcon(icon: .FAPlusCircle, iconSize: 30, forState: .normal)
        plusButton.setTitleColor(.black, for: .normal)
        plusButton.addTarget(self, action: #selector(showOptionView), for: .touchDown)
        plusButton.layer.cornerRadius = 15
        plusButton.backgroundColor = .white
        self.addSubview(plusButton)
        //loadTag(tags:tags)
    }
    
    @objc func showOptionView(){
        let tagOptionView = TagOptionView(frame: CGRect(x: 0, y: 0, width: 150, height: 150), existingTags: tags,color:plusButton.titleColor(for: .normal)!)
        tagOptionView.delegate = self
        tagOptionView.center = CGPoint(x: self.center.x, y: self.center.y + 75)
        if self.superview != nil{
            self.superview?.addSubview(tagOptionView)
             plusButton.isEnabled = false
        }
    }
    
    func tagClicked(tag: String) {
        addTag(tag)
    }
    
    func willBeRemovedFromSuperView(tagOptionView: TagOptionView) {
         plusButton.isEnabled = true
    }
    
    func loadTag(tags:[String]){
        cumulatedX = 0
        cumulatedY = 0
        for tag in tagList{
            tag.removeFromSuperview()
            
        }
        tagList.removeAll()
        self.tags = tags
        if tags.count == 0{return}
        for tag in tags{
           let tagLabel = TagLabel(text: tag, font: UIFont.systemFont(ofSize: 18))
             tagList.append(tagLabel)
            if cumulatedX + tagLabel.frame.width > self.frame.width + 10{
                for tag in tagList{
                    if tag.frame.origin.y == cumulatedY{
                        print(tag.text)
                        tag.frame.origin.x += (self.frame.width - cumulatedX + 10)/2
                    }else if tag.frame.origin.y > cumulatedY{
                        break
                    }
                }
                cumulatedX = 0
                cumulatedY += tagLabel.frame.height + 10
                self.frame.size.height = cumulatedY + 40
                
            }
            tagLabel.frame.origin = CGPoint(x: cumulatedX, y: cumulatedY)
           self.addSubview(tagLabel)
           cumulatedX += tagLabel.frame.width + 10
        }
        
        if cumulatedX + plusButton.frame.width > self.frame.width{
            cumulatedX = 0
            cumulatedY += 40
            self.frame.size.height = cumulatedY + 40
        }
        plusButton.frame.origin.x = cumulatedX
        plusButton.frame.origin.y = cumulatedY
        
    }
    
    @objc func addTag(_ tag:String){
         tags.append(tag)
         let tagLabel = TagLabel(text: tag, font: UIFont.systemFont(ofSize: 18))
         tagList.append(tagLabel)
         if cumulatedX + tagLabel.frame.width > self.frame.width{
            cumulatedX = 0
            cumulatedY += tagLabel.frame.height + 10
            self.frame.size.height = cumulatedY + 40
         }
         tagLabel.frame.origin = CGPoint(x: cumulatedX, y: cumulatedY)
         self.addSubview(tagLabel)
         cumulatedX += tagLabel.frame.width + 10
        if cumulatedX + plusButton.frame.width > self.frame.width{
            cumulatedX = 0
            cumulatedY += 40
            self.frame.size.height = cumulatedY + 40
        }
        plusButton.frame.origin.x = cumulatedX
        plusButton.frame.origin.y = cumulatedY
        if delegate != nil{
            delegate?.tagDidFinishAdding?(tag:tag)
        }
    }
    
    @objc func popTag(){
        if tagList.count > 0{
        tags.removeLast()
        tagList.last?.removeFromSuperview()
        tagList.remove(at: tagList.count - 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


@objc protocol TagInputViewDelegate:NSObjectProtocol{
    @objc optional func tagDidFinishAdding(tag:String)
    @objc optional func tagsDidFinishLoading(tags:[String])
}
