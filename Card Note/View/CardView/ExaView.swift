//
//  ExaView.swift
//  Card Note
//
//  Created by Wei Wei on 7/6/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class ExaView:CardView,UITextViewDelegate{
    var textView = MyTextView()
    var title = UITextField()
    var translateTextView = UITextView()
    var translateTitle = UITextField()
    var example:String = ""
    
    override init(card: Card) {
        super.init(frame: CGRect())
        self.card = card
        self.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4)
        self.backgroundColor = UIColor.white
        self.center.x = UIScreen.main.bounds.width/2
        self.layer.cornerRadius = 15
        self.layer.shadowColor = Constant.Color.translusentGray.cgColor
        self.layer.shadowOffset = CGSize(width:0,height:5)
        self.layer.shadowOpacity = 0.5
        self.textView.layer.cornerRadius = 15
        self.textView.frame = CGRect(x:20, y:50, width: UIScreen.main.bounds.width * 0.8 - 40, height: UIScreen.main.bounds.height/4 - 50)
        self.textView.center.x = self.bounds.width/2
        self.textView.backgroundColor = .clear
        self.textView.textColor = .black
        self.textView.text = card.getDefinition()
        self.textView.isScrollEnabled = false
        let constrainSize = CGSize(width:self.textView.frame.size.width,height:CGFloat(MAXFLOAT))
        let size = self.textView.sizeThatFits(constrainSize)
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        //重新设置textview的高度
        if size.height > 50{
            self.textView.frame.size.height = size.height
            self.frame.size.height = self.textView.frame.height + self.textView.frame.origin.y
        }else{
            self.textView.frame.size.height = 50
            self.frame.size.height = self.textView.frame.height + self.textView.frame.origin.y
        }
    
        
        self.title.textColor = .black
        self.title.backgroundColor = .clear
        self.title.font = UIFont.systemFont(ofSize: 20)
        self.title.text = card.getTitle()
        self.title.textAlignment = .left
        self.title.frame = CGRect(x: 20, y: 0, width:UIScreen.main.bounds.width * 0.8 - 40, height: 50)
        self.title.center.y = 25
        self.title.addBottomLine()
        self.addSubview(textView)
        self.addSubview(title)
        
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.delegate = self
        longTapGesture.addTarget(self, action: #selector(menuController))
        addGestureRecognizer(longTapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc override func observeMode(){
        super.observeMode()
        self.textView.isEditable = false
    }
    
    @objc override func editMode() {
        super.editMode()
        self.textView.isEditable = true
    }
    
    
    @objc override func hideTranslate(){
        translateTextView.removeFromSuperview()
        translateTitle.removeFromSuperview()
        textView.isHidden = false
        title.isHidden = false
        _ifTranslated = false
    }
    
    @objc override func menuController(_ sender:UILongPressGestureRecognizer){
        if sender.state == .began{
            self.becomeFirstResponder()
            uimenu = UIMenuController.shared
            uimenu.arrowDirection = .default
            uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Share", action: #selector(self.share)),UIMenuItem(title: "Translate", action: #selector(translate)),UIMenuItem(title: "Cancel Translation", action: #selector(hideTranslate))]
            uimenu.setTargetRect(self.bounds, in: self)
            uimenu.setMenuVisible(true, animated: true)
        }
    }
    
    
    @objc override func translate(){
        translateTextView.textColor = .black
        translateTextView.frame = textView.frame
        translateTextView.isEditable = false
        translateTextView.isSelectable = false
        translateTextView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(menuController(_:))))
        
        translateTitle.textColor = .black
        translateTitle.backgroundColor = .clear
        translateTitle.font = UIFont.systemFont(ofSize: 20)
        translateTitle.text = card.getTitle()
        translateTitle.textAlignment = .left
        translateTitle.frame = CGRect(x: 20, y: 0, width:UIScreen.main.bounds.width * 0.8 - 40, height: 50)
        translateTitle.center.y = 25
        translateTitle.addBottomLine()
        
        TranslationManager.translate(text: textView.text) { [unowned self](translate) in
            if translate != nil{
                self.translateTextView.text = translate
                self.textView.isHidden = true
                self._ifTranslated = true
                self.addSubview(self.translateTextView)
            }else{
                AlertView.show(alert: "Translation Went Wrong.")
            }
        }
        
        TranslationManager.translate(text: title.text!) { [unowned self](translate) in
            if translate != nil{
                self.translateTitle.text = translate
                self.title.isHidden = true
                self._ifTranslated = true
                self.addSubview(self.translateTitle)
            }else{
                AlertView.show(alert: "Translation Went Wrong.")
            }
        }
    }
}
