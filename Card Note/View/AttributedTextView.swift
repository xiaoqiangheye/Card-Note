//
//  attributedTextView.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/29.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import ChameleonFramework
import Font_Awesome_Swift
class AttributedTextView:UIView,UIScrollViewDelegate{
    weak var delegate:AttributedTextViewDelegate?
    var textMode:Constant.TextMode!
    var textView:UITextView
    var font:UIFont?
    var fontColor:UIColor?
    var backColor:UIColor?
    var isUnderlined:NSNumber?
    var isItalic:NSNumber?
    var isStrike:NSNumber?
    var isBold:NSNumber?
    var isOrderedList:NSNumber?
    var order:Int = 0
    var isUnorderedList:NSNumber?
    var selectForFontButton:UIButton!
    var underl:UIButton!
    var obliButton:UIButton!
    var fontColorButton:UIButton!
    var BoldButton:UIButton!
    var strikeButton:UIButton!
    var backGroundColorButton:UIButton!
    var orderedList:UIButton!
    var unOrderedList:UIButton!
    var scrollView:UIScrollView!
    init(y:CGFloat,textView:UITextView) {
       
        let frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: 50)
        self.textView = textView
        if textView.attributedText.length > 0{
        var range = NSMakeRange(textView.attributedText.length - 1, 1)
        var location = textView.selectedRange.location - 1
        if location < 0{
                location = 0
            }
            self.textView.autocorrectionType = .no
            self.textView.spellCheckingType = .no
            self.font = self.textView.attributedText.attribute(NSAttributedStringKey.font, at:  location, effectiveRange: &range) as? UIFont
            self.fontColor = self.textView.attributedText.attribute(NSAttributedStringKey.foregroundColor, at: location, effectiveRange: &range) as? UIColor
            self.backColor = self.textView.attributedText.attribute(NSAttributedStringKey.backgroundColor, at:  location, effectiveRange: &range) as? UIColor
            self.isUnderlined = (self.textView.attributedText.attribute(NSAttributedStringKey.underlineStyle, at:  location, effectiveRange: &range)) == nil ? 0:1
            self.isItalic = self.textView.attributedText.attribute(NSAttributedStringKey.obliqueness, at:  location, effectiveRange: &range) == nil ? 0:0.5
            self.isStrike = self.textView.attributedText.attribute(NSAttributedStringKey.strikethroughStyle, at: location, effectiveRange: &range) == nil ? 0:1
            self.isBold = ((self.textView.attributedText.attribute(NSAttributedStringKey.font, at: location, effectiveRange: &range) as? UIFont)?.fontName.lowercased().contains("bold"))! ? 1:0
            
        }else{
            self.font = UIFont.systemFont(ofSize: 20)
            self.fontColor = .black
            self.backColor = .clear
            self.isUnderlined = 0
            self.isItalic = 0
            self.isStrike = 0
            self.isBold = 0
        }
        //self decoration
    
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.8
        
        //scrollView
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        scrollView.contentSize.height = 50
        scrollView.contentSize.width = 400
      
        //isOrderedListAtCurrentSelectedLine()
        
        //Font Name/font size/color
        selectForFontButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        selectForFontButton.setFAIcon(icon: .FAFont, forState: .normal)
        selectForFontButton.addTarget(self, action: #selector(selectFont), for: .touchDown)
        selectForFontButton.setTitleColor(.black, for: .normal)
         scrollView.addSubview(selectForFontButton)
        
        //underline
        underl = UIButton(frame: CGRect(x: 50, y: 0, width: 50, height: 50))
        underl.setFAIcon(icon: .FAUnderline, forState: .normal)
        underl.addTarget(self, action: #selector(underline), for: .touchDown)
        if isUnderlined == 0{
        underl.setTitleColor(.black, for: .normal)
        }else{
        underl.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }
         scrollView.addSubview(underl)
        
        //obliqui
        obliButton = UIButton(frame: CGRect(x: 100, y: 0, width: 50, height: 50))
        obliButton.setFAIcon(icon: .FAItalic, forState: .normal)
        obliButton.addTarget(self, action: #selector(Obliqueness), for: .touchDown)
        if isItalic == 0{
        obliButton.setTitleColor(.black, for: .normal)
        }else{
        obliButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }
         scrollView.addSubview(obliButton)
        
        //Font Color Button deprecated
        /**
        fontColorButton = UIButton(frame: CGRect(x: 90, y: 0, width: 30, height: 30))
        fontColorButton.setFAIcon(icon: .FAFont, forState: .normal)
        fontColorButton.setTitleColor(.red, for: .normal)
        fontColorButton.addTarget(self, action: #selector(selectFontColor), for: .touchDown)
 
        */
       // self.addSubview(fontColorButton)
 
        
        //
        BoldButton = UIButton(frame: CGRect(x: 150
            , y: 0, width: 50, height: 50))
        BoldButton.setFAIcon(icon: .FABold, forState: .normal)
        if isBold == 0{
        BoldButton.setTitleColor(.black, for: .normal)
        }else{
        BoldButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }
        BoldButton.addTarget(self, action: #selector(setBold), for: .touchDown)
         scrollView.addSubview(BoldButton)
        
        //BackGroundColor
        backGroundColorButton = UIButton(frame: CGRect(x: 200, y: 0, width: 50, height: 50))
        backGroundColorButton.setFAIcon(icon: .FAPaintBrush, forState: .normal)
        backGroundColorButton.addTarget(self, action: #selector(textBackGroundColor), for: .touchDown)
        backGroundColorButton.setTitleColor(.black, for: .normal)
         scrollView.addSubview(backGroundColorButton)
        
        //strikeButton
        strikeButton = UIButton(frame: CGRect(x: 250, y: 0, width: 50, height: 50))
        strikeButton.setFAIcon(icon: .FAStrikethrough, forState: .normal)
        strikeButton.addTarget(self, action: #selector(setStrike), for: .touchDown)
        if isStrike == 0{
            strikeButton.setTitleColor(.black, for: .normal)
        }else{
            strikeButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }
         scrollView.addSubview(strikeButton)
    
        //orderedList
        orderedList = UIButton(frame: CGRect(x: 300, y: 0, width: 50, height: 50))
        orderedList.setFAIcon(icon: .FAListOl, forState: .normal)
        isOrderedListAtSelectedLocation()
        if isOrderedList == 1{
            orderedList.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }else {
            orderedList.setTitleColor(.black, for: .normal)
        }
        orderedList.addTarget(self, action: #selector(setOrderedList), for: .touchDown)
         scrollView.addSubview(orderedList)
        
        //unorderedList
        unOrderedList = UIButton(frame: CGRect(x: 350, y: 0, width: 50, height: 50))
        unOrderedList.setFAIcon(icon: .FAListUl, forState: .normal)
        isUnorderedListAtCurrentSelectedLine()
        if isUnorderedList == 1{
            unOrderedList.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            textMode = Constant.TextMode.UnorderedListMode
        }else{
            unOrderedList.setTitleColor(.black, for: .normal)
        }
        unOrderedList.addTarget(self, action: #selector(setUnorderedList), for: .touchDown)
        scrollView.addSubview(unOrderedList)
        
        //TODO: textAlignment
            //center
        
        
            //left
        
            //right
        
        self.addSubview(scrollView)
    }
    
    
    
    func reset(){
        
        if self.font != nil{
        setFont(fontName: (self.font?.fontName)!)
        }
        let size = self.font?.pointSize
        
        if fontColor != nil{
        setFontColor(color: self.fontColor!)
        }
        if backColor != nil{
            setBgColor(color: self.backColor!)
        }
        for _ in 0...1{
            setBold()
            setStrike()
            underline()
            Obliqueness()
            self.textView.typingAttributes[NSAttributedStringKey.kern.rawValue] = 0
        }
    }
    
    /**
     update the attributedView value specific to attributed string at specific place in textView.
     
     :param: at
     */
    func update(at:Int){
        if textView.attributedText.length > 0{
            print(textView.text)
            var range = NSMakeRange(textView.attributedText.length - 1, 1)
            self.font = self.textView.attributedText.attribute(NSAttributedStringKey.font, at: at, effectiveRange: &range) as? UIFont
            print(self.font?.fontName)
            self.fontColor = self.textView.attributedText.attribute(NSAttributedStringKey.foregroundColor, at: at, effectiveRange: &range) as? UIColor
            self.backColor = self.textView.attributedText.attribute(NSAttributedStringKey.backgroundColor, at: at, effectiveRange: &range) as? UIColor
            self.isUnderlined = (self.textView.attributedText.attribute(NSAttributedStringKey.underlineStyle, at: at, effectiveRange: &range)) == nil ? 0:1
            self.isItalic = self.textView.attributedText.attribute(NSAttributedStringKey.obliqueness, at: at, effectiveRange: &range) == nil ? 0:0.5
            self.isStrike = self.textView.attributedText.attribute(NSAttributedStringKey.strikethroughStyle, at: at, effectiveRange: &range) == nil ? 0:1
            self.isBold = ((self.textView.attributedText.attribute(NSAttributedStringKey.font, at: at, effectiveRange: &range) as? UIFont)?.fontName.lowercased().contains("bold"))! ? 1:0
            
            
            if isUnderlined == 0{
                underl.setTitleColor(.black, for: .normal)
            }else{
                underl.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            }
            
            if isItalic == 0{
                obliButton.setTitleColor(.black, for: .normal)
            }else{
                obliButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            }
            
            if isBold == 0{
                BoldButton.setTitleColor(.black, for: .normal)
            }else{
                BoldButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            }
            
            isUnorderedListAtCurrentSelectedLine()
            isOrderedListAtSelectedLocation()
        }else{
            self.font = UIFont.systemFont(ofSize: 12)
            self.fontColor = .black
            self.backColor = .clear
            self.isUnderlined = 0
            self.isItalic = 0
            self.isStrike = 0
            self.isBold = 0
            self.isUnorderedList = 0
            self.isOrderedList = 0
        }
    }
    
    
    func isOrderedListAtSelectedLocation(){
        if textView.text.count > 0{
        var textMode:Constant.TextMode = Constant.TextMode.UnorderedListEndMode
        let location = textView.selectedRange.location
        var index:Int
        if location >= 1{
            index = location - 1
        }else{
            index = 0
        }
        
        let substring = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: index + 1))
        
        for character in substring.reversed(){
            print(character)
            if character == "\n"{
                break
            }else if character == "."{
                var range:NSRange = NSRange()
                let attributeOfLigature = textView.attributedText.attribute(NSAttributedStringKey.ligature, at: index - 1, effectiveRange: &range) == nil ? 0 : 1
                 let attributeOfFont = (textView.attributedText.attribute(NSAttributedStringKey.font, at: index - 1, effectiveRange: &range)) as? UIFont
                if attributeOfLigature == 1 || attributeOfFont == UIFont(name: "Avenir-Medium", size: 18){
                    textMode = Constant.TextMode.OrderedListStartMode
                }
               
            }else{
                if textMode == Constant.TextMode.OrderedListStartMode{
                    if let order = Int(String(character)){
                    textMode = Constant.TextMode.OrderedListMode
                    self.order = order
                    }
                    break
                }
            }
            if index >= 1{
            index -= 1
            }
        }
        if textMode == Constant.TextMode.OrderedListMode{
            isOrderedList = 1
            orderedList.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            self.textMode = Constant.TextMode.OrderedListMode
        }else{
            isOrderedList = 0
            orderedList.setTitleColor(.black, for: .normal)
        }
        }else{
            isOrderedList = 0
            orderedList.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc  func setOrderedList(){
        var textMode:Constant.TextMode = Constant.TextMode.UnorderedListEndMode
        var location = textView.selectedRange.location
        var index:Int
        if location >= 1{
            index = location - 1
        }else{
            index = 0
        }
        
        if textView.text.count > 0{
        let substring = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: index + 1))
        for character in substring.reversed(){
            print(character)
            if character == "\n"{
                break
            }else if character == "."{
                var range:NSRange = NSRange()
                let attributeOfLigature = (textView.attributedText.attribute(NSAttributedStringKey.ligature, at: index - 1, effectiveRange: &range)) == nil ? 0 : 1
                let attributeOfFont = (textView.attributedText.attribute(NSAttributedStringKey.font, at: index - 1, effectiveRange: &range)) as? UIFont
                if attributeOfLigature == 1 || attributeOfFont == UIFont(name: "Avenir-Medium", size: 18){
                    textMode = Constant.TextMode.OrderedListStartMode
                }
            }else{
                if textMode == Constant.TextMode.OrderedListStartMode{
                    if let order = Int(String(character)){
                        textMode = Constant.TextMode.OrderedListMode
                        break
                    }
                }
            }
            if index >= 1{
            index -= 1
            }
        }
        }
        
        if textMode == Constant.TextMode.OrderedListMode{
            isOrderedList = 0
            orderedList.setTitleColor(.black, for: .normal)
            let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            attributedString.deleteCharacters(in: NSRange(location: index, length: 2))
            var newIndex = index
            while (newIndex < textView.text.count - 1 && textView.text[textView.text.index(textView.text.startIndex, offsetBy: newIndex)] != "\n"){
                newIndex += 1
            }
            var length = newIndex - 1 - index
            if index == 0{
                index = 1
                length -= 1
            }
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.headIndent = 0
            paragraph.firstLineHeadIndent = 0
            paragraph.lineBreakMode = .byCharWrapping
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraph, range: NSRange(location: index - 1, length: length))
        
            textView.attributedText = attributedString
            textView.selectedRange = NSRange(location: location - 2, length: 0)
            textView.typingAttributes[NSAttributedStringKey.paragraphStyle.rawValue] = paragraph
            reset()
            
            self.textMode = Constant.TextMode.OrderedListEndMode
        }else{
            if isUnorderedList == 1{
                setUnorderedList()
                location = textView.selectedRange.location
            }
            self.textMode = Constant.TextMode.OrderedListMode
            var orderIndex = 0
            var newIndex:Int = 0
            if location >= 1{
                newIndex = location - 1
            }else{
                newIndex = 0
            }
            self.order = 0
            if textView.text.count > 0{
                 let substring = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: newIndex + 1))
                for character in substring.reversed(){
                if character == "\n"{
                    orderIndex += 1
                    if orderIndex > 1{
                        break
                    }
                }else if character == "." && orderIndex == 1{
                    var range:NSRange = NSRange()
                    let attributeOfLigature = (textView.attributedText.attribute(NSAttributedStringKey.ligature, at: newIndex, effectiveRange: &range)) == nil ? 0 : 1
                    let attributeOfFont = (textView.attributedText.attribute(NSAttributedStringKey.font, at: newIndex, effectiveRange: &range)) as? UIFont
                    if attributeOfLigature == 1 || attributeOfFont == UIFont(name: "Avenir-Medium", size: 18){
                        textMode = Constant.TextMode.OrderedListStartMode
                    }
                }else if orderIndex == 1{
                    if textMode == Constant.TextMode.OrderedListStartMode{
                        if let order = Int(String(character)){
                            textMode = Constant.TextMode.OrderedListMode
                            self.order = order
                            break
                        }
                    }
                }
                newIndex -= 1
            }
            }
            isOrderedList = 1
            orderedList.setTitleColor(Constant.Color.勿忘草色, for: .normal)
            let paragraph = NSMutableParagraphStyle()
            paragraph.firstLineHeadIndent = 10
            let bullet = "\(order + 1)."
            let attributedBullet = NSAttributedString(string: bullet, attributes: [NSAttributedStringKey.font:UIFont(name: "Avenir-Medium", size: 18),NSAttributedStringKey.ligature:1, NSAttributedStringKey.paragraphStyle:paragraph])
            let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            if index <= 0{
                index = 0
            }else{
                index += 1
            }
            attributedString.insert(attributedBullet, at: index)
            textView.attributedText = attributedString
            textView.selectedRange = NSRange(location: location + 2, length: 0)
            reset()
        }
    }
    
    
    func isUnorderedListAtCurrentSelectedLine(){
        if textView.text.count > 0{
        var textMode:Constant.TextMode = Constant.TextMode.UnorderedListEndMode
        let location = textView.selectedRange.location
        
            var index:Int
            if location >= 1{
                index = location - 1
            }else{
                index = 0
            }
            
            let substring = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: index + 1))
            print(substring)
            for character in substring.reversed(){
                print(character)
                if character == "\n"{
                    break
                }else if character == "\u{2022}"{
                    var range:NSRange = NSRange()
                    let attributeOfKern = textView.attributedText.attribute(NSAttributedStringKey.kern, at: index, effectiveRange: &range) == nil ? 0:15
                    let attributeOfFont = textView.attributedText.attribute(NSAttributedStringKey.font, at: index, effectiveRange: &range) as! UIFont
                    let size = attributeOfFont.pointSize
                    if attributeOfKern == 15 && size == 20{
                        textMode = Constant.TextMode.UnorderedListMode
                    }
                }
                if index >= 1{
                index -= 1
                }
            }
            if textMode == Constant.TextMode.UnorderedListMode{
                self.textMode = Constant.TextMode.UnorderedListMode
                isUnorderedList = 1
                unOrderedList.setTitleColor(Constant.Color.themeColor, for: .normal)
            }else{
              
                isUnorderedList = 0
                unOrderedList.setTitleColor(.black, for: .normal)
        }
        }else{
            isUnorderedList = 0
            unOrderedList.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc func setUnorderedList(){
        var textMode:Constant.TextMode = Constant.TextMode.UnorderedListEndMode
        var location = textView.selectedRange.location
        if textView.selectedRange.length == 0{
            var index:Int
            if location >= 1{
                index = location - 1
            }else{
                
                index = 0
                
            }
            
            if textView.text.count > 0{
            let substring = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: index + 1))
            print(substring)
            for character in substring.reversed(){
                print(character)
                if character == "\n"{
                    break
                }else if character == "\u{2022}"{
                    var range:NSRange = NSRange()
                    let attributeOfKern = textView.attributedText.attribute(NSAttributedStringKey.kern, at: index, effectiveRange: &range) == nil ? 0:15
                    let attributeOfFont = textView.attributedText.attribute(NSAttributedStringKey.font, at: index, effectiveRange: &range) as! UIFont
                    let size = attributeOfFont.pointSize
                    if attributeOfKern == 15 && size == 20{
                        textMode = Constant.TextMode.UnorderedListMode
                    }
                    break
                }
                if index >= 1{
                index -= 1
                }
            }
            }
            
            if textMode == Constant.TextMode.UnorderedListMode{
                isUnorderedList = 0
                unOrderedList.setTitleColor(.black, for: .normal)
                 let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
                attributedString.deleteCharacters(in: NSRange(location: index, length: 1))
                
                var newIndex = index
                while (newIndex < textView.text.count - 1 && textView.text[textView.text.index(textView.text.startIndex, offsetBy: newIndex)] != "\n"){
                    newIndex += 1
                }
                var length = newIndex - index
                if index == 0{
                    index = 1
                    length -= 1
                }
                let paragraph = NSMutableParagraphStyle()
                paragraph.headIndent = 0
                paragraph.firstLineHeadIndent = 0
                 paragraph.lineBreakMode = .byCharWrapping
                attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraph, range: NSRange(location: index - 1, length: length))
                textView.attributedText = attributedString
                textView.selectedRange = NSRange(location: location - 1, length: 0)
                textView.typingAttributes[NSAttributedStringKey.paragraphStyle.rawValue] = paragraph
                reset()
                self.textMode = Constant.TextMode.UnorderedListEndMode
            }else{
                
                if isOrderedList == 1{
                    setOrderedList()
                    location = textView.selectedRange.location
                }
                self.textMode = Constant.TextMode.UnorderedListMode
                isUnorderedList = 1
                unOrderedList.setTitleColor(Constant.Color.勿忘草色, for: .normal)
               
                let paragraph = NSMutableParagraphStyle()
                paragraph.firstLineHeadIndent = 10
                let bullet = "\u{2022}"
                let attributedBullet = NSAttributedString(string: bullet, attributes: [NSAttributedStringKey.font:UIFont(name: "Avenir-Medium", size: 20),NSAttributedStringKey.kern:15,NSAttributedStringKey.paragraphStyle:paragraph])
                let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
              
                if index <= 0{
                    index = 0
                }else{
                    index += 1
                }
                attributedString.insert(attributedBullet, at: index)
                textView.attributedText = attributedString
                textView.selectedRange = NSRange(location: location + 1, length: 0)
                reset()
            }
        }
    }
    
    @objc private func textBackGroundColor(){
        
    }
    
    @objc private func selectFont(){
        if delegate != nil{
            delegate?.selectFont!(height:self.frame.origin.y)
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
           textView.typingAttributes[NSAttributedStringKey.obliqueness.rawValue] = nil
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
        underl.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }else{
            isUnderlined = 0
        self.textView.typingAttributes[NSAttributedStringKey.underlineStyle
            .rawValue] = nil
        underl.setTitleColor(UIColor.black, for: .normal)
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
        strikeButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }else{
        self.isStrike = 0
        self.textView.typingAttributes[NSAttributedStringKey.strikethroughStyle.rawValue] = nil
        strikeButton.setTitleColor(.black, for: .normal)
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
            }else{
                self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] = UIFont.boldSystemFont(ofSize: (self.font?.pointSize)!)
            }
            
            BoldButton.setTitleColor(Constant.Color.勿忘草色, for: .normal)
        }else if isBold == 1{
            self.isBold = 0
            self.textView.typingAttributes[NSAttributedStringKey.font.rawValue] =  UIFont.systemFont(ofSize: (self.font?.pointSize)!)
            BoldButton.setTitleColor(.black, for: .normal)
        }
    }
}
