//
//  TextView.swift
//  Card Note
//
//  Created by Wei Wei on 7/6/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

class TextView:CardView,UITextViewDelegate{
    var textView = MyTextView()
    var translateTextView = UITextView()
    
    override init(card: Card) {
        super.init(frame: CGRect())
        self.card = card
        TextView.decorate(view: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func decorate(view:TextView){
        let card = view.card as! TextCard
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4)
        view.backgroundColor = UIColor.orange
        view.center.x = UIScreen.main.bounds.width/2
        // view.layer.cornerRadius = 20
        
        view.backgroundColor = .clear
        view.textView.frame.size = view.frame.size
        view.textView.frame.origin = CGPoint(x: 0, y: 0)
        view.textView.backgroundColor = .clear
        view.textView.layer.cornerRadius = 15
        view.textView.isScrollEnabled = false
        view.textView.attributedText = card.getText() == nil ? NSAttributedString(string: "") : card.getText()
        if card.getText() == nil || card.getText()?.string == ""{
            view.textView.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
            view.textView.typingAttributes = [NSAttributedStringKey.font.rawValue:UIFont.systemFont(ofSize: 20),NSAttributedStringKey.foregroundColor.rawValue:UIColor.black]
        }
        let constrainSize = CGSize(width:view.textView.frame.size.width,height:CGFloat(MAXFLOAT))
        let size = view.textView.sizeThatFits(constrainSize)
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        //重新设置textview的高度
        if size.height > 50{
            view.textView.frame.size.height = size.height
            view.frame.size.height = size.height
        }else{
            view.textView.frame.size.height = 50
            view.frame.size.height = 50
        }
        
        view.addSubview(view.textView)
        
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.delegate = view
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
    }
    
    
    @objc override func observeMode(){
        super.observeMode()
    }
    
    @objc override func editMode() {
        super.editMode()
    }
    
    
    @objc override func menuController(_ sender: UIGestureRecognizer) {
        print(sender.state)
        if sender.state == .ended{
            self.becomeFirstResponder()
            uimenu = UIMenuController.shared
            uimenu.arrowDirection = .default
            uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "Translate", action: #selector(self.translate)),UIMenuItem(title: "Cancel Translation", action: #selector(self.hideTranslate)),UIMenuItem(title: "Share", action: #selector(self.share)),UIMenuItem(title: "Delete", action: #selector(deleteCard))]
            uimenu.setTargetRect(self.bounds, in: self)
            uimenu.setMenuVisible(true, animated: true)
        }
        
    }
    
    
    
    @objc override func hideTranslate(){
        translateTextView.removeFromSuperview()
        textView.isHidden = false
        _ifTranslated = false
    }
    
    
    @objc override func translate(){
        translateTextView.textColor = .black
        translateTextView.frame.size = self.frame.size
        translateTextView.frame.origin = CGPoint(x: 0, y: 0)
        TranslationManager.translate(text: textView.text) { (translate) in
            if translate != nil{
                self.translateTextView.text = translate
                self.translateTextView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.menuController(_:))))
                self.textView.isHidden = true
                self.addSubview(self.translateTextView)
                self._ifTranslated = true
            }else{
                let view = MessageView.viewFromNib(layout: .cardView)
                // Theme message elements with the warning style.
                view.configureTheme(.warning)
                
                // Add a drop shadow.
                view.configureDropShadow()
                
                // Set message title, body, and icon. Here, we're overriding the default warning
                // image with an emoji character.
                view.button?.removeFromSuperview()
                view.configureContent(title: "Error", body: "Translation Went Wrong.", iconText: "")
                
                // Show the message.
                SwiftMessages.show(view: view)
            }
        }
        
    }
    
}
