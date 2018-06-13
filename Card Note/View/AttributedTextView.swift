//
//  attributedTextView.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/29.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import ChameleonFramework
class AttributedTextView:UIView{
    weak var delegate:AttributedTextViewDelegate?
    var textView:UITextView
    var font:UIFont?
    var fontColor:UIColor?
    var backColor:UIColor?
    var isUnderlined:NSNumber?
    var isItalic:NSNumber?
    var isStrike:NSNumber?
    var isBold:NSNumber?
    var selectForFontButton:UIButton!
    var underl:UIButton!
    var obliButton:UIButton!
    var fontColorButton:UIButton!
    var BoldButton:UIButton!
    init(y:CGFloat,textView:UITextView) {
        let frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: 30)
        self.textView = textView
        if textView.attributedText.length > 0{
        var range = NSMakeRange(textView.attributedText.length - 1, 1)
            self.font = self.textView.attributedText.attribute(NSAttributedStringKey.font, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIFont
            self.fontColor = self.textView.attributedText.attribute(NSAttributedStringKey.foregroundColor, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIColor
            self.backColor = self.textView.attributedText.attribute(NSAttributedStringKey.backgroundColor, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIColor
            self.isUnderlined = (self.textView.attributedText.attribute(NSAttributedStringKey.underlineStyle, at: textView.attributedText.length - 1, effectiveRange: &range)) == nil ? 0:1
            self.isItalic = self.textView.attributedText.attribute(NSAttributedStringKey.obliqueness, at: textView.attributedText.length - 1, effectiveRange: &range) == nil ? 0:0.5
            self.isStrike = self.textView.attributedText.attribute(NSAttributedStringKey.strikethroughStyle, at: textView.attributedText.length - 1, effectiveRange: &range) == nil ? 0:1
            self.isBold = (self.textView.attributedText.attribute(NSAttributedStringKey.font, at: textView.attributedText.length - 1, effectiveRange: &range) as? UIFont)?.fontName == "AvenirNext-Medium" ? 1:0
            
            
        }else{
            self.font = UIFont.systemFont(ofSize: 12)
            self.fontColor = .black
            self.backColor = .clear
            self.isUnderlined = 0
            self.isItalic = 0
            self.isStrike = 0
            self.isBold = 0
        }
       
        super.init(frame: frame)
         self.backgroundColor = .white
        
        //Font Name/font size
        selectForFontButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        selectForFontButton.setFAIcon(icon: .FAFont, forState: .normal)
        selectForFontButton.addTarget(self, action: #selector(selectFont), for: .touchDown)
        selectForFontButton.setTitleColor(.black, for: .normal)
        self.addSubview(selectForFontButton)
        
        //underline
        underl = UIButton(frame: CGRect(x: 30, y: 0, width: 30, height: 30))
        underl.setFAIcon(icon: .FAUnderline, forState: .normal)
        underl.addTarget(self, action: #selector(underline), for: .touchDown)
        underl.setTitleColor(.black, for: .normal)
        self.addSubview(underl)
        
        //obliqui
        obliButton = UIButton(frame: CGRect(x: 60, y: 0, width: 30, height: 30))
        obliButton.setFAIcon(icon: .FAItalic, forState: .normal)
        obliButton.addTarget(self, action: #selector(Obliqueness), for: .touchDown)
        obliButton.setTitleColor(.black, for: .normal)
        self.addSubview(obliButton)
        
        //Font Color Button deprecated
        /**
        fontColorButton = UIButton(frame: CGRect(x: 90, y: 0, width: 30, height: 30))
        fontColorButton.setFAIcon(icon: .FAFont, forState: .normal)
        fontColorButton.setTitleColor(.red, for: .normal)
        fontColorButton.addTarget(self, action: #selector(selectFontColor), for: .touchDown)
 
        */
       // self.addSubview(fontColorButton)
 
        
        //
        BoldButton = UIButton(frame: CGRect(x: 90
            , y: 0, width: 30, height: 30))
        BoldButton.setFAIcon(icon: .FABold, forState: .normal)
        BoldButton.setTitleColor(.black, for: .normal)
        BoldButton.addTarget(self, action: #selector(setBold), for: .touchDown)
        self.addSubview(BoldButton)
        //BackGroundColor
        let backGroundColorButton = UIButton(frame: CGRect(x: 120, y: 0, width: 30, height: 30))
        backGroundColorButton.setFAIcon(icon: .FAPencil, forState: .normal)
        
        
        
        
    }
    
    /**
     update the attributedView value specific to attributed string at specific place in textView.
     
     :param: at
     */
    func update(at:Int){
        if textView.attributedText.length > 0{
            var range = NSMakeRange(textView.attributedText.length - 1, 1)
            self.font = self.textView.attributedText.attribute(NSAttributedStringKey.font, at: at, effectiveRange: &range) as? UIFont
            self.fontColor = self.textView.attributedText.attribute(NSAttributedStringKey.foregroundColor, at: at, effectiveRange: &range) as? UIColor
            self.backColor = self.textView.attributedText.attribute(NSAttributedStringKey.backgroundColor, at: at, effectiveRange: &range) as? UIColor
            self.isUnderlined = (self.textView.attributedText.attribute(NSAttributedStringKey.underlineStyle, at: at, effectiveRange: &range)) == nil ? 0:1
            self.isItalic = self.textView.attributedText.attribute(NSAttributedStringKey.obliqueness, at: at, effectiveRange: &range) == nil ? 0:0.5
            self.isStrike = self.textView.attributedText.attribute(NSAttributedStringKey.strikethroughStyle, at: at, effectiveRange: &range) == nil ? 0:1
            self.isBold = (self.textView.attributedText.attribute(NSAttributedStringKey.font, at: at, effectiveRange: &range) as? UIFont)?.fontName == "AvenirNext-Medium" ? 1:0
        }else{
            self.font = UIFont.systemFont(ofSize: 12)
            self.fontColor = .black
            self.backColor = .clear
            self.isUnderlined = 0
            self.isItalic = 0
            self.isStrike = 0
            self.isBold = 0
        }
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
        if isItalic == 0{
            textView.typingAttributes[NSAttributedStringKey.obliqueness.rawValue] = 0.5
            isItalic = 0.5
            obliButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            
        }
        else{
            isItalic = 0
           textView.typingAttributes[NSAttributedStringKey.obliqueness.rawValue] = 0
            obliButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    /**
     设置下划线
     
     :param: sender
     */
    @objc func underline() {
        if isUnderlined == 0{
            isUnderlined = 1
        self.textView.typingAttributes[NSAttributedStringKey.underlineStyle.rawValue] = 1
        }else{
            isUnderlined = 0
        self.textView.typingAttributes[NSAttributedStringKey.underlineStyle
            .rawValue] = 0
        }
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
    
    @objc func setStrike(){
        if isStrike == 0{
        self.isStrike = 1
        self.textView.typingAttributes[NSAttributedStringKey.strikethroughStyle.rawValue] = 1
        }else{
        self.isStrike = 0
        self.textView.typingAttributes[NSAttributedStringKey.strikethroughStyle.rawValue] = 0
        }
    }
    
    @objc func setBold(){
        if isBold == 0{
            self.isBold = 1
            let array = UIFont.fontNames(forFamilyName: (self.font?.familyName)!)
            print("\((self.font?.fontName)!)-Bold")
            print(array)
            if array.contains("\((self.font?.familyName)!)-Bold"){
            self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont(name: "\((self.font?.familyName)!)-Bold", size: (self.font?.pointSize)!)
            }
            BoldButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }else if isBold == 1{
            self.isBold = 0
            self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = self.font
            BoldButton.setTitleColor(.black, for: .normal)
        }
    }
}
