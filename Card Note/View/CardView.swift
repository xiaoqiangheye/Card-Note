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
    var label:UILabel = UILabel()
    var labelofDes:UILabel = UILabel()
    var ifTranslated = false
    weak var uimenu:UIMenuController!
    var deleteButton:UIButton!
    var isEditMode = false
    override init(frame: CGRect) {
        super.init(frame: frame)
       
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
                uimenu.menuItems = [UIMenuItem(title: "Down", action: #selector(self.down)),UIMenuItem(title: "Up", action: #selector(self.up))]
                uimenu.setTargetRect(self.bounds, in: self)
                uimenu.setMenuVisible(true, animated: true)
        }
    }
    
    @objc func editMode(){
        if !isEditMode{
        deleteButton = UIButton(frame: CGRect(x: self.frame.width-50, y: 0, width: 50, height: 50))
        deleteButton.setFAIcon(icon: .FAMinusCircle, iconSize: 30, forState: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteCard), for: .touchDown)
        self.addSubview(deleteButton)
        isEditMode = true
        }
    }
    
    @objc func observeMode(){
        if isEditMode{
        deleteButton.removeFromSuperview()
        deleteButton = nil
        isEditMode = false
        }
    }
    
    class ExaView:CardView,UITextViewDelegate{
        var textView = UITextView()
        var translateTextView = UITextView()
        var example:String = ""
        
        @objc override func observeMode(){
           super.observeMode()
           self.textView.isEditable = false
        }
        
        @objc override func editMode() {
            super.editMode()
            self.textView.isEditable = true
        }
        
        @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
                if sender.state == .began{
                    if !ifTranslated{
                        self.becomeFirstResponder()
                        uimenu = UIMenuController.shared
                        uimenu.arrowDirection = .default
                        uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(self.translate)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard))]
                        uimenu.setTargetRect(self.bounds, in: self)
                        uimenu.setMenuVisible(true, animated: true)
                    }else{
                        self.becomeFirstResponder()
                        uimenu = UIMenuController.shared
                        uimenu.arrowDirection = .default
                        uimenu.menuItems = [UIMenuItem(title: "Cancel Translation", action: #selector(self.hideTranslate)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard))]
                        uimenu.setTargetRect(self.bounds, in: self)
                        uimenu.setMenuVisible(true, animated: true)
                    }
                }
            
        }
        
        @objc override func hideTranslate(){
            translateTextView.removeFromSuperview()
            textView.isHidden = false
            ifTranslated = false
        }
        

        @objc override func translate(){
            translateTextView.textColor = .black
            translateTextView.frame = textView.frame
            translateTextView.isEditable = false
            translateTextView.isSelectable = false
            translateTextView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(menuController(_:))))
            TranslationManager.translate(text: textView.text) { (translate) in
                if translate != nil{
                    self.translateTextView.text = translate
                    self.textView.isHidden = true
                    self.ifTranslated = true
                    self.addSubview(self.translateTextView)
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
    
    class TextView:CardView,UITextViewDelegate{
        var textView = UITextView()
        var translateTextView = UITextView()
        
        @objc override func observeMode(){
            super.observeMode()
            self.textView.isEditable = false
        }
        
        @objc override func editMode() {
            super.editMode()
            self.textView.isEditable = true
        }
        
        @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began{
                if !ifTranslated{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(self.translate))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }else{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Cancel Translation", action: #selector(self.hideTranslate))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }
            }
            
        }
        
        @objc override func hideTranslate(){
            translateTextView.removeFromSuperview()
            textView.isHidden = false
            ifTranslated = false
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
                    self.ifTranslated = true
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
    
    class PicView:CardView{
        var image:UIImageView = UIImageView()
        var commentView:UITextField = UITextField()
        var ifCommentShowed = false
        
        @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began{
                if !ifCommentShowed{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Footnote", action: #selector(self.addComment))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }else{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Hide FootNote", action: #selector(self.hideComment)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }
            }
            
        }
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if (action == #selector(self.deleteCard)){
                return true
            }else if(action == #selector(self.addComment)){
                return true
            }else if (action == #selector(self.hideComment)){
                return true
            }else{
                return false
            }
        }
        
        
        
        @objc func addComment(){
            ifCommentShowed = true
            self.frame.size.height += 20
            commentView.isHidden = false
            if delegate != nil{
                delegate?.cardView!(commentShowed: self)
            }
            
        }
        
        @objc func hideComment(){
            ifCommentShowed = false
            self.frame.size.height -= 20
            commentView.isHidden = true
            if delegate != nil{
                delegate?.cardView!(commentHide: self)
            }
        }
        
        func loadPic(){
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent(self.card.getId() + ".jpg")
            /*deprecated
                User.getImage(email: loggedemail, cardID: self.card.getId(), completionHandler: { (im:UIImage?) in
                    if im != nil{
                        DispatchQueue.main.async {
                        (self.card as! PicCard).pic = im!
                            self.image.image = im!
                            print("get Image Success")
                        }
                    }else{
                        print("get Image failed")
                    }
                })
            */
            User.downloadPhotosUsingQCloud(email: loggedemail, cardID: self.card.getId()) { (bool, error) in
                if bool{
                    DispatchQueue.main.async {
                        (self.card as! PicCard).pic = UIImage(contentsOfFile: (url?.path)!)
                        self.image.image = UIImage(contentsOfFile: (url?.path)!)
                    }
                    print("load picture success; cardId\(self.card.getId())")
                }
            }
            }
    }
    
    class SharedCardView:CardView{
        var username:UILabel = UILabel()
        var date:UILabel = UILabel()
        var stateLabel = UILabel()
        var cardView = CardView()
    }
    
    class SubCardView:CardView{
        var title = UITextView()
        var content = UITextView()
        var translatedTitle = UITextView()
        var translatedContent = UITextView()
        
        @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began{
                if !ifTranslated{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(self.translate)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }else{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Cancel Translation", action: #selector(self.hideTranslate)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }
            }
            
        }
        
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
            TranslationManager.translate(text: title.text) { (translate) in
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
                    self.ifTranslated = true
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
            ifTranslated = false
            self.title.isHidden = false
            self.content.isHidden = false
        }
    }
    
    class VoiceCardView:CardView,SFSpeechRecognizerDelegate{
        var controllerButton = UIButton()
        var timerLable = UILabel()
        var progressBar = UIProgressView(progressViewStyle: .default)
        var timer:Timer?
        var time:Int = 0
        var recognizer:SFSpeechRecognizer!
        var recognitionTextView: UITextView!
        var conversionButton:UIButton!
        
        
        @objc func requestForAuth(){
            SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
                var isButtonEnabled = false
                switch authStatus {  //5
                case .authorized:
                    isButtonEnabled = true
                    
                case .denied:
                    isButtonEnabled = false
                    print("User denied access to speech recognition")
                    
                case .restricted:
                    isButtonEnabled = false
                    print("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    isButtonEnabled = false
                    print("Speech recognition not yet authorized")
                }
                DispatchQueue.main.async {
                    self.conversionButton.isEnabled = isButtonEnabled
                }
            }
            
        }
        
        @objc func recognizeFile() {
            let url = Constant.Configuration.url.Audio.appendingPathComponent((self.card as! VoiceCard).getId() + ".wav")
            requestForAuth()
            if !recognizer.isAvailable{
                //AlertView.show(self.superview!, alert: "Recognizer is currently not available, Please try to restart the software.")
                return
            }
            let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: url.path))
            recognizer.recognitionTask(with: request) { (result, error) in
                guard let result = result else {
                    //failed
                    print(error?.localizedDescription)
                    //AlertView.show(self.superview!, alert: "Failed to recognize the speech, please check the internet.")
                    return
                }
                if result.isFinal {
                    // Print the speech that has been recognized so far
                    print("Speech in the file is \(result.bestTranscription.formattedString)")
                    DispatchQueue.main.async{
                    self.recognitionTextView = UITextView(frame: CGRect(x: 0, y: self.frame.origin.y + self.frame.height, width: self.frame.width, height:0))
                    self.recognitionTextView.isEditable = false
                    self.recognitionTextView.textColor = .black
                    self.recognitionTextView.text = result.bestTranscription.formattedString
                    self.recognitionTextView.font = UIFont.systemFont(ofSize: 18)
                    self.recognitionTextView.frame.size.height = self.recognitionTextView.contentSize.height
                    self.addSubview(self.recognitionTextView)
                    self.frame.size.height += self.recognitionTextView.frame.height
                    }
                }
            }
        }
        
        @objc func hideSpeechTextView(){
        recognitionTextView.removeFromSuperview()
        self.frame.size.height -= self.recognitionTextView.frame.height
        }
    }
    
    class MapCardView:CardView{
        var title = UITextView()
        var neighbourAddrees = UILabel()
        var formalAddress = UILabel()
        var image = UIImageView()
        
        func loadPic(){
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent("mapPic")
            try? manager.createDirectory(atPath: (url?.path)!, withIntermediateDirectories: true, attributes: nil)
            url?.appendPathComponent(self.card.getId() + ".jpg")
            /*deprecared
            User.getImage(email: loggedemail, cardID: self.card.getId(), completionHandler: { (im:UIImage?) in
                if im != nil{
                    let imageData = UIImageJPEGRepresentation(im!, 0.5)
                    try? imageData?.write(to: url!)
                    DispatchQueue.main.async {
                        (self.card as! MapCard).image = im!
                        self.image.image = im!
                        print("get map Success")
                    }
                }else{
                     print("get map failed")
                }
            })
 */
          
            User.downloadMapUsingQCloud(email: loggedemail, cardID: self.card.getId()) { (bool, error) in
                if bool{
                    DispatchQueue.main.async {
                        (self.card as! MapCard).image = UIImage(contentsOfFile: (url?.path)!)!
                        self.image.image = UIImage(contentsOfFile: (url?.path)!)
                    }
                    print("load map success; cardId\(self.card.getId())")
                }
            }
            
        }
    }
    
    class ListView:CardView{
        var title:UITextField!
        
    }
    
    
    class MovieView:CardView{
        var url:URL?
        var player:AVPlayer?
        var playerLayer:AVPlayerLayer?
        var progressBar:UIProgressView?
        var state:State = State.readyToPlay
        enum State{
            case playing
            case readyToPlay
            case pause
        }
        
       @objc func playerDidFinishPlaying(){
            state = .readyToPlay
        }
        
        @objc func play(sender:UIButton){
        do{
            player?.play()
            state = .playing
            sender.isHidden = true
        }catch let error{
            print(error.localizedDescription)
        }
        }
        
        @objc func pause(){
            player?.pause()
            state = .pause
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getSingleCardView(card:Card)->CardView{
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let cardView = CardView(frame: CGRect(x: 0, y: 0, width: x*0.8, height: y/4))
        cardView.card = card
        cardView.center.x = x/2
        let colorView = UIView(frame: CGRect(x: 0, y: 0, width: cardView.frame.width/8, height: cardView.frame.height))
        colorView.backgroundColor = card.color
        cardView.backgroundColor = .white
        //cardView.layer.cornerRadius = 20
        
        cardView.addSubview(colorView)
        let title:String = card.getTitle()
        let label = UILabel(frame: CGRect(x:cardView.frame.width/8,y:0,width:cardView.bounds.width-cardView.frame.width/8,height:20))
        label.text = title
        label.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.center.x = cardView.frame.width/2
        label.textColor = .black
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
        
        let definition:String = card.getDefinition()
        let labelOfDes = UILabel(frame: CGRect(x:cardView.frame.width/8 + 20,y:label.frame.height,width:cardView.bounds.width-cardView.frame.width/8,height:cardView.bounds.height/2))
        labelOfDes.text = definition
        labelOfDes.font = UIFont(name: "ChalkboardSE-Light", size: 15)
        labelOfDes.numberOfLines = 4
        labelOfDes.lineBreakMode = .byWordWrapping
        labelOfDes.textColor = .black
        cardView.labelofDes = labelOfDes
        cardView.addSubview(labelOfDes)
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowOpacity = 0.8
        return cardView
    }
    
    class func getSubCardView(_ card:Card)->SubCardView{
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let cardView = SubCardView(frame: CGRect(x: 0, y: 0, width: x*0.8, height: y/4))
        cardView.card = card
        cardView.center.x = x/2
        let colorView = UIView(frame: CGRect(x: 0, y: 0, width: cardView.frame.width/8, height: cardView.frame.height))
        colorView.backgroundColor = card.color
        cardView.backgroundColor = .white
        //cardView.layer.cornerRadius = 20
        
        cardView.addSubview(colorView)
        let title:String = card.getTitle()
        let label = UITextView(frame: CGRect(x:cardView.frame.width/8,y:0,width:cardView.bounds.width-cardView.frame.width/8,height:50))
        label.backgroundColor = .clear
        label.attributedText = NSAttributedString(string: title)
        label.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        label.isScrollEnabled = false
        //label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
    
        label.center.x = cardView.frame.width/2
        label.textColor = .black
        cardView.title = label
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
        
        let definition:String = card.getDefinition()
        let labelOfDes = UITextView(frame: CGRect(x:cardView.frame.width/8 + 20,y:label.frame.height + 10,width:cardView.bounds.width-cardView.frame.width/8-20,height:cardView.bounds.height/2))
        labelOfDes.backgroundColor = .clear
        labelOfDes.attributedText = NSAttributedString(string: definition)
        labelOfDes.font = UIFont(name: "ChalkboardSE-Light", size: 15)
     //   labelOfDes.numberOfLines = 4
       // labelOfDes.lineBreakMode = .byWordWrapping
        labelOfDes.isScrollEnabled = false
        labelOfDes.textColor = .black
        cardView.content = labelOfDes
        cardView.addSubview(labelOfDes)
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowOpacity = 0.8
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(cardView, action: #selector(cardView.menuController))
        cardView.addGestureRecognizer(longTapGesture)
        return cardView
    }
    
    class func singleExampleView(card:Card)->ExaView{
        let view = ExaView()
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4)
        view.backgroundColor = UIColor.white
        view.center.x = UIScreen.main.bounds.width/2
        //view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width:1,height:1)
        view.layer.shadowOpacity = 0.5
        view.textView.layer.cornerRadius = 15
        view.textView.frame = CGRect(x:0, y:50, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4 - 50)
        view.textView.center.x = view.bounds.width/2
        view.textView.backgroundColor = .clear
        view.textView.textColor = .black
        view.card = card
        
        let Label = UILabel()
        Label.textColor = .black
        Label.backgroundColor = .clear
        Label.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        Label.text = "Example"
        Label.textAlignment = .left
        Label.frame = CGRect(x: 20, y: 0, width: 100, height: 50)
        Label.center.y = 25
        view.addSubview(view.textView)
        view.addSubview(Label)
        
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        /*
        let translateButton = UIButton()
        translateButton.frame = CGRect(x: view.frame.width - 100, y: view.frame.height - 50, width: 100, height: 50)
        translateButton.setTitle("Translate", for: .normal)
        translateButton.addTarget(view, action: #selector(view.translate), for: .touchDown)
        //translateButton.setFAIcon(icon: .FAComment, forState: .normal)
        translateButton.setTitleColor(.black, for: .normal)
        view.addSubview(translateButton)
        */
        return view
    }
    
    class func getSingleTextView(card:TextCard)->TextView{
      let view = TextView()
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4)
        view.backgroundColor = UIColor.orange
        view.center.x = UIScreen.main.bounds.width/2
       // view.layer.cornerRadius = 20
        
        view.backgroundColor = .clear
        view.textView.frame.size = view.frame.size
        view.textView.frame.origin = CGPoint(x: 0, y: 0)
        view.textView.backgroundColor = .clear
        view.textView.layer.cornerRadius = 20
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
        if size.height > 100{
        view.textView.frame.size.height = size.height
             view.frame.size.height = size.height
        }else{
        view.textView.frame.size.height = 100
             view.frame.size.height = 100
        }
       
        view.card = card
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        /*
        let translateButton = UIButton()
        translateButton.frame = CGRect(x: 200, y:0, width: 50, height: 50)
        translateButton.setTitle("Translate", for: .normal)
        translateButton.addTarget(view, action: #selector(view.translate), for: .touchDown)
     //   translateButton.setFAIcon(icon: .FAComment, forState: .normal)
        translateButton.setTitleColor(.black, for: .normal)
        view.addSubview(translateButton)
 */
        
        return view
    }
    
    class func getSinglePicView(pic:PicCard)->PicView{
        let view = PicView()
        view.card = pic
        let x = pic.pic.size.width
        let y = pic.pic.size.height
        let ratio = UIScreen.main.bounds.width*0.8/x
        let changedy = y * ratio
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: changedy)
        view.center.x = UIScreen.main.bounds.width/2
        view.layer.cornerRadius = 20
        view.backgroundColor = .clear
        view.image.frame.origin = CGPoint(x:0,y:0)
        view.image.frame.size = view.frame.size
        view.image.backgroundColor = .clear
        view.image.image = pic.pic
        view.image.alpha = 1
        view.addSubview(view.image)
        
        
        view.image.layer.shadowColor = UIColor.black.cgColor
        view.image.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.image.layer.shadowOpacity = 0.8
        view.commentView.frame = CGRect(x: 0, y: view.image.frame.height, width:  UIScreen.main.bounds.width * 0.8, height: 40)
        view.commentView.backgroundColor = .clear
        view.commentView.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        view.commentView.textColor = .black
        view.commentView.text = pic.getDefinition()
        view.commentView.textAlignment  = .center
        
        view.addSubview(view.commentView)
        
        if pic.getDefinition() == ""{
            view.commentView.isHidden = true
            view.ifCommentShowed = false
        }else{
            view.frame.size.height += 20
            view.ifCommentShowed = true
        }
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        
        return view
    }
    
    class func getSingleSharedCardView(card:SharedCard)->SharedCardView{
        let view = SharedCardView()
        view.card = card.card
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/3)
        view.center.x = UIScreen.main.bounds.width/2
        view.username = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height:20))
        view.username.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(view.username)
        view.date = UILabel(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width/2, height: 20))
        view.date.font = UIFont.systemFont(ofSize: 10)
        view.addSubview(view.date)
        view.cardView = getSingleCardView(card: card.card)
        view.cardView.frame.origin.y = 40
        view.cardView.center.x = view.frame.width/2
        view.frame.size.height = view.username.frame.height + view.date.frame.height + view.cardView.frame.height + 20
        view.addSubview(view.cardView)
        return view
    }
    
    @objc static func voiceViewControllButtonClicked(_ sender:UIButton){
        let targetView = sender.superview as! VoiceCardView
        let card = targetView.card as! VoiceCard
        let manager = card.voiceManager
        if manager?.state == RecordManager.State.willRecord{
            manager?.beginRecord()
            sender.setFAIcon(icon: .FAStopCircle, forState: .normal)
            targetView.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                targetView.time += 1
            if manager?.state == .recording{
                targetView.timerLable.text = String(Int((card.voiceManager?.recorder?.currentTime)!))
                targetView.progressBar.progress = Float((card.voiceManager?.recorder?.currentTime)!)/60.0
            }else{
                if targetView.time > 5{
                    targetView.timer?.invalidate()
                }
                }
            })
            
        }else if manager?.state == RecordManager.State.recording{
            manager?.stopRecord()
            sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
            manager?.canPlay = true
            targetView.timer?.invalidate()
            targetView.timerLable.text = String((card.voiceManager?.time)!)
            card.voiceManager?.time = 0
           targetView.progressBar.progress = 0
        }else if manager?.state == RecordManager.State.haveRecord{
            //manager?.play()
            let play = manager?.play()
            if play!{
                sender.setFAIcon(icon: .FAPauseCircle, forState: .normal)
                targetView.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                targetView.timerLable.text = String(Int((card.voiceManager?.player?.currentTime)!)) + "/" + String(Int((card.voiceManager?.player?.duration)!))
                targetView.progressBar.progress =  Float((card.voiceManager?.player?.currentTime)!)/Float((card.voiceManager?.player?.duration)!)
                    if !(manager?.player?.isPlaying)!{
                        manager?.state = .haveRecord
                        targetView.timer?.invalidate()
                        sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
                    }
            })
            }else{
                AlertView.show(targetView, alert: "The file has been damaged.")
                manager?.state = RecordManager.State.willRecord
            }
        }else if manager?.state == RecordManager.State.playing{
            manager?.pause()
            sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
        }else if manager?.state == RecordManager.State.stopplaying{
            manager?.continuePlaying()
            sender.setFAIcon(icon: .FAStopCircle, forState: .normal)
        }
    }
    
    class func getSingleVoiceView(card:VoiceCard)->VoiceCardView{
        let view = VoiceCardView()
        view.card = card
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
    
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height:100)
        view.center.x = UIScreen.main.bounds.width/2
        view.controllerButton.frame = CGRect(x:30, y:0, width: 30, height:30)
        if card.voiceManager?.state == .willRecord || card.voiceManager?.state == .recording{
        view.controllerButton.setFAIcon(icon: .FAMicrophone, iconSize: 20, forState: .normal)
        }else{
        view.controllerButton.setFAIcon(icon: .FAPlayCircle, iconSize: 20, forState: .normal)
        }
       // view.controllerButton.setTitle("录音", for: UIControlState.normal)
        view.controllerButton.setTitleColor(.black, for: UIControlState.normal)
        view.controllerButton.addTarget(self, action: #selector(voiceViewControllButtonClicked(_:)), for:UIControlEvents.touchDown)
        view.controllerButton.center.y = view.frame.height/2
        view.timerLable.frame = CGRect(x:view.frame.width - 75, y:0, width: 75, height:75)
        view.timerLable.font = UIFont.systemFont(ofSize: 15)
        view.timerLable.textColor = .black
        view.timerLable.text = "0"
        view.timerLable.textAlignment = .center
        view.timerLable.center.y = view.frame.height/2
        view.progressBar.frame = CGRect(x: 80, y: 0, width: view.frame.width - 75 - 80, height: 50)
        view.progressBar.center.y = view.frame.height/2
        view.progressBar.progress = 0
        
        view.conversionButton = UIButton(frame: CGRect(x: 0, y: 80, width: 20, height: 20))
        view.conversionButton.setFAIcon(icon: .FAGlobe, iconSize: 20, forState: .normal)
        view.conversionButton.setTitleColor(.black, for: .normal)
        view.conversionButton.addTarget(view, action: #selector(view.recognizeFile), for: .touchDown)
        view.recognizer = SFSpeechRecognizer()
        
        
        view.addSubview(view.conversionButton)
        view.addSubview(view.controllerButton)
        view.addSubview(view.timerLable)
        view.addSubview(view.progressBar)
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        return view
    }
    
    class func getSingleMapView(card:MapCard)->MapCardView{
        let view = MapCardView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8))
        view.card = card
        view.center.x = UIScreen.main.bounds.width/2
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.5
        view.neighbourAddrees.font = UIFont.boldSystemFont(ofSize: 15)
        view.neighbourAddrees.frame  = CGRect(x: 0, y: 0, width: view.frame.width, height: 20)
        if card.neibourAddress != ""{
        view.neighbourAddrees.text = card.neibourAddress
        }else{
        view.neighbourAddrees.text = card.formalAddress
        }
        view.formalAddress.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: 20)
        view.formalAddress.text = card.formalAddress
        view.formalAddress.font = UIFont.systemFont(ofSize: 12)
        let url = URL(fileURLWithPath: card.imagePath!)
        let ifExist = FileManager.default.fileExists(atPath: url.path)
        if ifExist{
            view.image.image = UIImage(contentsOfFile: (url.path))
        }else{
             view.image.image = card.image
        }
        view.image.frame = CGRect(x:0, y: 40, width: view.frame.width, height: view.frame.width - 40)
        view.addSubview(view.title)
        view.addSubview(view.neighbourAddrees)
        view.addSubview(view.formalAddress)
        view.addSubview(view.image)
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        
        return view
    }
    
    class func getSingleMovieView(card:MovieCard)->MovieView{
       let view = MovieView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.6))
        view.center.x = UIScreen.main.bounds.width/2
        let url = Constant.Configuration.url.Movie.absoluteURL.appendingPathComponent(card.getId() + ".mov")
        view.url = url
        print("path:\(url.path)")
        view.player = AVPlayer(url: view.url!)
        view.playerLayer = AVPlayerLayer(player: view.player)
        view.playerLayer?.frame = view.bounds
        view.card = card
        view.layer.addSublayer(view.playerLayer!)
        let playerItem = AVPlayerItem(url: view.url!)
        NotificationCenter.default.addObserver(view,
                                               selector: #selector(view.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        let playerButton = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
        playerButton.setFAIcon(icon: FAType.FAPlayCircle, forState: .normal)
        playerButton.setTitleColor(.black, for: .normal)
        playerButton.addTarget(view, action: #selector(view.play), for: .touchDown)
        playerButton.center.x = view.frame.width/2
        playerButton.center.y = view.frame.height/2
        
        view.addSubview(playerButton)
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        
        return view
    }
    
    
    class func getSingleListView(card:ListCard)->ListView{
        let view = ListView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.6))
        view.center.x = UIScreen.main.bounds.width/2
        view.card = card
        let title = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 50))
        title.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        title.textColor = .black
        return view
    }
    
    
}
