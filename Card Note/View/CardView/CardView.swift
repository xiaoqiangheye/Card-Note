//
//  CardView.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/4.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import SwiftMessages
import Font_Awesome_Swift
import AVFoundation
import AVKit
import Speech

class CardView: UIView{
    weak var delegate:CardViewDelegate?
    var card:Card!
    private var label:UILabel!
    private var labelofDes:UILabel!
    internal var _ifTranslated = false
    weak var uimenu:UIMenuController!
    private var observeButton:UIButton!
    internal var _isEditMode = false
    var isEditMode:Bool{
        get{
            return _isEditMode
        }
    }
    var ifTranslated:Bool{
        get{
            return _ifTranslated
        }
    }
    
    internal var docController:UIDocumentInteractionController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(card:Card) {
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        super.init(frame:CGRect(x: 0, y: 0, width: x*0.85, height: y/4))
        self.card = card
        CardView.decorateCard(cardView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func decorateCard(cardView:CardView){
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let card = cardView.card
        //cardView.clipsToBounds = true
        cardView.center.x = x/2
        //colorView.backgroundColor = card.color
        // cardView.backgroundColor = .white
        
        
        cardView.layer.shadowColor = card!.getColor().cgColor
        cardView.layer.shadowOffset = CGSize(width:0,height:10)
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 15
        cardView.layer.cornerRadius = 20
        
        //cardView.addSubview(colorView)
        
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        card!.getColor().getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:cardView.frame.width,height:cardView.frame.height);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [card!.getColor().cgColor,getRightColorFromLeftGradient(left: card!.getColor()).cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 20
        cardView.layer.addSublayer(gl)
        
        let title:String = card!.getTitle()
        let label = UILabel(frame: CGRect(x:20,y:20,width:cardView.bounds.width-20,height:25))
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 1
        //  label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.center.x = cardView.frame.width/2
        label.textColor = .white
        cardView.label = label
        cardView.addSubview(label)
        
        /*
         let tag:String = card.getTag()
         let labelOfTag = UILabel(frame: CGRect(x:20,y:label.bounds.height,width:cardView.bounds.width-20,height:cardView.bounds.height/5))
         labelOfTag.text = tag
         labelOfTag.font = UIFont.boldSystemFont(ofSize: 20)
         label.numberOfLines = 1
         label.lineBreakMode = .byWordWrapping
         cardView.addSubview(labelOfTag)
         */
        
        
        let labelOfDes = UILabel(frame: CGRect(x: 20,y:label.frame.height + 20,width:cardView.bounds.width - 40,height:cardView.bounds.height/2))
        labelOfDes.text = card?.getDefinition()
        labelOfDes.font = UIFont.systemFont(ofSize: 15)
        labelOfDes.numberOfLines = 10
        labelOfDes.lineBreakMode = .byClipping
        labelOfDes.textColor = .white
        let constrainSize = CGSize(width:labelOfDes.frame.size.width,height:CGFloat(MAXFLOAT))
        let size = labelOfDes.sizeThatFits(constrainSize)
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        //重新设置textview的高度
        if size.height > 50{
            labelOfDes.frame.size.height = size.height
            cardView.frame.size.height = labelOfDes.frame.height + labelOfDes.frame.origin.y + 20
        }else{
            labelOfDes.frame.size.height = 50
            cardView.frame.size.height = labelOfDes.frame.height + labelOfDes.frame.origin.y + 20
        }
        
        cardView.labelofDes = labelOfDes
        cardView.addSubview(labelOfDes)
        if (!FileManager.default.fileExists(atPath: Constant.Configuration.url.attributedText.appendingPathComponent(card!.getId() + "_DEFINITION.rtf").path)){
            cardView.reload()
        }
        
        
        
        //add imageView
        let shootingStar = UIImageView(frame: CGRect(x: 200, y: 0, width: 82, height: 56))
        shootingStar.image = UIImage(named:"shootingstar")
        cardView.addSubview(shootingStar)
        
        let shootingStar2 = UIImageView(frame: CGRect(x: 50, y: 50, width: 70, height: 42))
        shootingStar2.image = UIImage(named:"shootingstar")
        cardView.addSubview(shootingStar2)
        
        let mountain = UIImageView(frame:CGRect(x: cardView.frame.width - 100, y: cardView.frame.height - 30, width: 60, height: 30))
        mountain.image = UIImage(named: "mountain")
        cardView.addSubview(mountain)
        
        
        cardView.layer.frame.size = cardView.frame.size
        gl.frame.size = cardView.frame.size
    }
    
    func reload(){
        Cloud.downloadDefinition(id: card.getId()) { [weak self](bool, error) in
            if(error == nil && bool){
                DispatchQueue.main.async {
                    self?.labelofDes.text = self?.card.getDefinition()
                }
            }
        }
    }
    
    @objc func share(){
            let alertView = SCLAlertView()
            alertView.addButton("Generate Picture") {
                let image = cutFullImageWithView(view: self)
                let shareView = SCLAlertView()
                shareView.addButton("To Other Apps", action: {
                    let imageData = UIImageJPEGRepresentation(image, 1)
                    do{
                        let id = UUID().uuidString + ".jpeg"
                        let url = Constant.Configuration.url.temporary.appendingPathComponent(id)
                        try FileManager.default.createDirectory(at:Constant.Configuration.url.temporary, withIntermediateDirectories: true, attributes: nil)
                        try imageData?.write(to: url)
                        let u:NSURL = NSURL(fileURLWithPath: url.path)
                        if(self.docController == nil){
                            self.docController = UIDocumentInteractionController.init(url: u as URL)
                        }
                        self.docController.uti = "public.jpeg"
                        self.docController.delegate = self
                        self.docController.presentOpenInMenu(from: CGRect.zero, in: self, animated: true)
                        
                        
                    }catch let err{
                        print(err.localizedDescription)
                    }
                })
                
                shareView.addButton("To Album", action: {
                    ImageManager.writeImageToAlbum(image: image, completionhandler: nil)
                })
                shareView.showSuccess("Success", subTitle: "Now Let's share!")
            }
            alertView.showNotice("Sharing", subTitle: "It's nice to have your card open to public.")
    }
    
    
    @objc private func longTap(gesture:UILongPressGestureRecognizer){
       
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print(action)
        if action == #selector(translate) && !ifTranslated{
            return true
        }else if action == #selector(hideTranslate) && ifTranslated{
            return true
        }else if action == #selector(deleteCard){
            return true
        }else if action == #selector(share){
            return true
        }else if action == #selector(editMode) && !self.isEditMode{
            return true
        }
        return false
    }
    
    @objc func translate(){
        
    }
    
    @objc func hideTranslate(){
        
    }
    
    @objc func deleteCard(){
        if delegate != nil{
            delegate?.deleteButtonClicked!(view:self)
        }
    }
    
    @objc func up(){
        if delegate != nil{
            delegate?.cardView!(up: self)
        }
    }
    
    @objc func down(){
        if delegate != nil{
            delegate?.cardView!(down: self)
        }
    }
    
    
    @objc func menuController(_ sender:UILongPressGestureRecognizer){
            if sender.state == .began{
                self.becomeFirstResponder()
                uimenu = UIMenuController.shared
                uimenu.arrowDirection = .default
                uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Share", action: #selector(self.share))]
                uimenu.setTargetRect(self.bounds, in: self)
                uimenu.setMenuVisible(true, animated: true)
            }
    }
    
    @objc func editMode(){
        if !isEditMode{
        observeButton = UIButton(frame: CGRect(x: self.frame.width-40, y: 10, width: 30, height: 30))
        observeButton.setFAIcon(icon: .FACheck, iconSize: 20, forState: .normal)
        observeButton.setTitleColor(Constant.Color.translusentGray, for: .normal)
        observeButton.backgroundColor = UIColor(red:70/255 , green: 70/255, blue: 70/255, alpha: 0.6)
        observeButton.layer.cornerRadius = 15
        observeButton.addTarget(self, action: #selector(observeMode), for: .touchDown)
        self.addSubview(observeButton)
        _isEditMode = true
        }
    }
    
    @objc func observeMode(){
        if isEditMode{
        observeButton.removeFromSuperview()
        observeButton = nil
        _isEditMode = false
        }
    }
    
    
    

    
    class SubCardView:CardView{
        var title = UILabel()
        var content = UILabel()
        var translatedTitle = UITextView()
        var translatedContent = UITextView()
        
        @objc override func translate() {
            translatedTitle.textColor = .black
            translatedTitle.frame = title.frame
            translatedTitle.backgroundColor = .clear
            translatedTitle.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
            translatedTitle.textAlignment = .center
            translatedContent.textColor = .black
            translatedContent.frame = content.frame
            translatedContent.backgroundColor = .clear
            translatedContent.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
            TranslationManager.translate(text: title.text!) { (translate) in
                if translate != nil{
                    self.translatedTitle.text = translate
                     self.translatedTitle.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.menuController(_:))))
                    self.title.isHidden = true
                    self.content.isHidden = true
                    self.addSubview(self.translatedTitle)
                    
                }else{
                    let view = MessageView.viewFromNib(layout: .cardView)
                    // Theme message elements with the warning style.
                    view.configureTheme(.warning)
                    
                    // Add a drop shadow.
                    view.configureDropShadow()
                    
                    view.button?.removeFromSuperview()
                    // Set message title, body, and icon. Here, we're overriding the default warning
                    // image with an emoji character.
                    
                    view.configureContent(title: "Error", body: "Translation Went Wrong.", iconText: "")
                    
                    // Show the message.
                    SwiftMessages.show(view: view)
                }
            }
            TranslationManager.translate(text: (content.text)!) { (translate) in
                if translate != nil{
                    self.translatedContent.text = translate
                     self.translatedContent.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.menuController(_:))))
                    self.addSubview(self.translatedContent)
                    self._ifTranslated = true
                }else{
                    let view = MessageView.viewFromNib(layout: .cardView)
                    // Theme message elements with the warning style.
                    view.configureTheme(.warning)
                    
                    // Add a drop shadow.
                    view.configureDropShadow()
                    
                    view.button?.removeFromSuperview()
                    // Set message title, body, and icon. Here, we're overriding the default warning
                    // image with an emoji character.
                    
                    view.configureContent(title: "Error", body: "Translation Went Wrong.", iconText: "")
                    
                    // Show the message.
                    SwiftMessages.show(view: view)
                }
            }
        }
        
        @objc override func hideTranslate() {
            translatedContent.removeFromSuperview()
            translatedTitle.removeFromSuperview()
            _ifTranslated = false
            self.title.isHidden = false
            self.content.isHidden = false
        }
    }
    
    

    
    
    
    
    class func getSubCardView(_ card:Card)->SubCardView{
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let cardView = SubCardView(frame: CGRect(x: 0, y: 0, width: x*0.8, height: y/4))
        //cardView.clipsToBounds = true
        cardView.card = card
        cardView.center.x = x/2
        
        //colorView.backgroundColor = card.color
        // cardView.backgroundColor = .white
        
        
        cardView.layer.shadowColor = card.getColor().cgColor
        cardView.layer.shadowOffset = CGSize(width:0,height:10)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowRadius = 10
        cardView.layer.cornerRadius = 20
        
        //cardView.addSubview(colorView)
        
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        card.getColor().getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:cardView.frame.width,height:cardView.frame.height);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [card.getColor().cgColor,getRightColorFromLeftGradient(left: card.getColor()).cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 20
        cardView.layer.addSublayer(gl)
        
        let title:String = card.getTitle()
        let label = UILabel(frame: CGRect(x:20,y:20,width:cardView.bounds.width-20,height:25))
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 1
        //  label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.center.x = cardView.frame.width/2
        label.textColor = .white
        cardView.label = label
        cardView.addSubview(label)
        cardView.title = label
        
       
        
        let labelOfDes = UILabel(frame: CGRect(x: 20,y:label.frame.height + 20,width:cardView.bounds.width - 40,height:cardView.bounds.height/2))
        labelOfDes.text = card.getDefinition()
        labelOfDes.font = UIFont.systemFont(ofSize: 15)
        labelOfDes.numberOfLines = 10
        labelOfDes.lineBreakMode = .byClipping
        labelOfDes.textColor = .white
        cardView.content = labelOfDes
        let constrainSize = CGSize(width:labelOfDes.frame.size.width,height:CGFloat(MAXFLOAT))
        let size = labelOfDes.sizeThatFits(constrainSize)
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        //重新设置textview的高度
        if size.height > 50{
            labelOfDes.frame.size.height = size.height
            cardView.frame.size.height = labelOfDes.frame.height + labelOfDes.frame.origin.y + 20
        }else{
            labelOfDes.frame.size.height = 50
            cardView.frame.size.height = labelOfDes.frame.height + labelOfDes.frame.origin.y + 20
        }
        
        cardView.labelofDes = labelOfDes
        cardView.addSubview(labelOfDes)
    
        
        //add imageView
        let shootingStar = UIImageView(frame: CGRect(x: 200, y: 0, width: 82, height: 56))
        shootingStar.image = UIImage(named:"shootingstar")
        cardView.addSubview(shootingStar)
        
        let shootingStar2 = UIImageView(frame: CGRect(x: 50, y: 50, width: 70, height: 42))
        shootingStar2.image = UIImage(named:"shootingstar")
        cardView.addSubview(shootingStar2)
        
        let mountain = UIImageView(frame:CGRect(x: cardView.frame.width - 100, y: cardView.frame.height - 30, width: 60, height: 30))
        mountain.image = UIImage(named: "mountain")
        cardView.addSubview(mountain)
        
        
        cardView.layer.frame.size = cardView.frame.size
        gl.frame.size = cardView.frame.size
        
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.delegate = cardView
        longTapGesture.addTarget(cardView, action: #selector(cardView.menuController))
        cardView.addGestureRecognizer(longTapGesture)
        return cardView
    }
    

}


extension CardView:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of:UILongPressGestureRecognizer.self) && (gestureRecognizer.view?.isKind(of:CardView.self))!{
            return false
        }else{
            return false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of:UILongPressGestureRecognizer.self){
            return true
        }else{
            return false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of:UITapGestureRecognizer.self) || gestureRecognizer.isKind(of:UILongPressGestureRecognizer.self){
            return false
        }else if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self){
            return true
        }else{
            return false
        }
    }
}



extension CardView:UIDocumentInteractionControllerDelegate{
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        let url = controller.url
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(at: url!)
        }catch let error{
            print(error.localizedDescription)
        }
    }
}




class MyTextView:UITextView{
   
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        let uimenu = UIMenuController.shared
        uimenu.arrowDirection = .default
        uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(self.translate))]
        uimenu.setTargetRect(self.bounds, in: self)
      // uimenu.setMenuVisible(true, animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func translate(){
        let range = self.selectedRange
        let r = Range(range, in: self.text)
        let text = String(self.text[r!])
        let cardView = self.superview as! CardView
        if delegate != nil{
            cardView.delegate?.cardView?(translate: cardView, text:text)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(select(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:)) && self.selectedRange.length == 0{
            return true
        }else if action == #selector(copy(_:)) || action == #selector(cut(_:)) || action == #selector(translate) || action == #selector(paste(_:)) && self.selectedRange.length > 0{
            return true
        }else{
            return false
        }
    }

}

protocol StatusBarDelegate:NSObjectProtocol{
    func statusBar(changeStatus status:MovieView.State)
}




