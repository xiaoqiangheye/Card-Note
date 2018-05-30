//
//  attributedTextView.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/29.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
class AttributedTextView:UIView{
    weak var delegate:AttributedTextViewDelegate?
    var textView:UITextView
    var font:UIFont?
    var fontColor:UIColor?
    var backColor:UIColor?
    init(y:CGFloat,textView:UITextView) {
        let frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: 30)
        self.textView = textView
        if textView.attributedText.length > 0{
        var range = NSMakeRange(textView.attributedText.length - 1, 1)
            self.font = self.textView.attributedText.attribute(NSAttributedStringKey.font, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIFont
            self.fontColor = self.textView.attributedText.attribute(NSAttributedStringKey.foregroundColor, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIColor
            self.backColor = self.textView.attributedText.attribute(NSAttributedStringKey.backgroundColor, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIColor
        }else{
            self.font = UIFont.systemFont(ofSize: 12)
            self.fontColor = .black
            self.backColor = .clear
        }
       
        super.init(frame: frame)
         self.backgroundColor = .black
        
        //Font Name/font size
        let selectForFontButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        selectForFontButton.setFAIcon(icon: .FAFont, forState: .normal)
        selectForFontButton.addTarget(self, action: #selector(selectFont), for: .touchDown)
        self.addSubview(selectForFontButton)
        
        //underline
        let underl = UIButton(frame: CGRect(x: 30, y: 0, width: 30, height: 30))
        underl.setFAIcon(icon: .FAUnderline, forState: .normal)
        underl.addTarget(self, action: #selector(underline), for: .touchDown)
        self.addSubview(underl)
        //Font Color
        
        let fontColorButton = UIButton(frame: CGRect(x: 60, y: 0, width: 30, height: 30))
        fontColorButton.setFAIcon(icon: .FAFont, forState: .normal)
        fontColorButton.setTitleColor(.red, for: .normal)
        fontColorButton.addTarget(self, action: #selector(selectFontColor), for: .touchDown)
        self.addSubview(fontColorButton)
        
        
        //BackGroundColor
        
        let backGroundColorButton = UIButton(frame: CGRect(x: 90, y: 0, width: 30, height: 30))
        backGroundColorButton.setFAIcon(icon: .FAPencil, forState: .normal)
    }
    
    @objc private func selectFont(){
        if delegate != nil{
            delegate?.selectFont!()
        }
    }
    
    @objc private func selectFontColor(){
        if delegate != nil{
            delegate?.selectFontColor!()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func fontincrease() {
        self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
    }
    /**
     字体增大
     
     :param: sender
     */
    @objc func fontdecase() {
        self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! - 1)
    }
    /**
     设置斜体
     
     :param: sender
     */
    @objc func Obliqueness() {
        textView.typingAttributes[NSAttributedStringKey.obliqueness.rawValue] = (textView.typingAttributes[NSAttributedStringKey.obliqueness.rawValue] as? NSNumber) == 0 ? 0.5 : 0
    }
    /**
     设置下划线
     
     :param: sender
     */
    @objc func underline() {
        self.textView.typingAttributes[NSAttributedStringKey.underlineStyle.rawValue] =  (NSUnderlineStyle.styleSingle.hashValue ) == 0 ? 1 : NSUnderlineStyle.styleSingle.hashValue
    }
    
    
    
   @objc func setFont(fontName:String){
    self.font = UIFont(name: fontName, size: (CGFloat)((self.font?.pointSize)!))
    self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont(name: fontName, size: (CGFloat)((self.font?.pointSize)!))
    }
    
    @objc func setFontSize(size:CGFloat){
        self.font = UIFont(name: (self.font?.fontName)!, size: size)
        self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont(name: (self.font?.fontName)!, size: size)
    }
    
    @objc func setFontColor(color:UIColor){
        self.fontColor = color
        self.textView.typingAttributes[NSAttributedStringKey.foregroundColor.rawValue] = color
    }
    
    @objc func setBgColor(color:UIColor){
        self.backColor = color
        self.textView.typingAttributes[NSAttributedStringKey.backgroundColor.rawValue] = color
    }
    
}
