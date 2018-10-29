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
    var tagList:[TagLabel] = [TagLabel]()
    var tags:Set<String> = Set<String>()
    var selectedTag:TagLabel?
    class TagLabel:UIButton{
        override var canBecomeFirstResponder: Bool {
            return true
        }
        
        init(text:String,font:UIFont) {
            super.init(frame:CGRect(x: -1, y: -1, width: 30, height: 30))
            
            //self.clipsToBounds = true
            self.setTitle(text, for: .normal)
           // self.backgroundColor = .white
            self.setTitleColor(.gray, for: .normal)
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
        let tags = self.tags.sorted()
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
        self.tags.removeAll()
        self.tags = self.tags.union(tags)
        for tag in tags{
           let tagLabel = TagLabel(text: tag, font: UIFont.systemFont(ofSize: 18))
            tagLabel.isUserInteractionEnabled = true
            tagLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
             tagList.append(tagLabel)
            if cumulatedX + tagLabel.frame.width > self.frame.width + 10{
                for tag in tagList{
                    if tag.frame.origin.y == cumulatedY{
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
    
    @objc private func tap(gesture:UIGestureRecognizer){
        if gesture.state == .ended{
            selectedTag = gesture.view as? TagLabel
            selectedTag?.becomeFirstResponder()
            let menu = UIMenuController.shared
            menu.menuItems = [UIMenuItem(title: "Delete", action: #selector(deleteTag))]
            menu.setTargetRect((selectedTag?.bounds)!, in: selectedTag!)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(deleteTag){
            return true
        }else{
            return false
        }
    }
    
    
    @objc private func deleteTag(){
        if selectedTag != nil{
            self.tags.remove((selectedTag?.title(for: .normal))!)
            loadTag(tags: self.tags.sorted())
            if delegate != nil{
                delegate?.tagDidFinishRemoving?(tag: (selectedTag?.title(for: .normal))!)
            }
        }
    }
    
    @objc func addTag(_ tag:String){
         tags.insert(tag)
         let tagLabel = TagLabel(text: tag, font: UIFont.systemFont(ofSize: 18))
        tagLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(gesture:))))
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
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


@objc protocol TagInputViewDelegate:NSObjectProtocol{
    @objc optional func tagDidFinishAdding(tag:String)
    @objc optional func tagsDidFinishLoading(tags:[String])
    @objc optional func tagDidFinishRemoving(tag:String)
}
