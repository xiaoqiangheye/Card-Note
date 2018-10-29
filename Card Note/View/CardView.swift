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
    private var label:UILabel = UILabel()
    private var labelofDes:UILabel = UILabel()
    private var _ifTranslated = false
    weak var uimenu:UIMenuController!
    private var observeButton:UIButton!
    private var _isEditMode = false
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
    
    private var docController:UIDocumentInteractionController!
    override init(frame: CGRect) {
        super.init(frame: frame)
       
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
                        self.docController = UIDocumentInteractionController.init(url: u as URL)
                        self.docController.uti = "public.jpeg"
                        self.docController.delegate = self
                        // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
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
    
    class ExaView:CardView,UITextViewDelegate{
        var textView = MyTextView()
        var title = UITextField()
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
        
        /*
        @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
                if sender.state == .began{
                        self.becomeFirstResponder()
                        uimenu = UIMenuController.shared
                        uimenu.arrowDirection = .default
                        uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(self.translate)),UIMenuItem(title: "Cancel Translation", action: #selector(self.hideTranslate)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Share", action: #selector(self.share))]
                        uimenu.setTargetRect(self.bounds, in: self)
                        uimenu.setMenuVisible(true, animated: true)
                }
            
        }
       */
        
        @objc override func hideTranslate(){
            translateTextView.removeFromSuperview()
            textView.isHidden = false
            _ifTranslated = false
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
                    self._ifTranslated = true
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
        var textView = MyTextView()
        var translateTextView = UITextView()
        
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
    
    class PicView:CardView{
        var image:UIImageView = UIImageView()
        var commentView:UITextField = UITextField()
        var ifCommentShowed = false
        
        @objc override func share() {
            let alertView = SCLAlertView()
            var url = Constant.Configuration.url.PicCard
            url.appendPathComponent(self.card.getId() + ".jpg")
            if !FileManager.default.fileExists(atPath: url.path){
               AlertView.show(alert: "Picture has not been loaded or is damaged.")
               return
            }
            alertView.addButton("Generate Picture") {
                let shareView = SCLAlertView()
                shareView.addButton("To Other Apps", action: {
                self.docController = UIDocumentInteractionController.init(url:url)
                self.docController.uti = "public.jpeg"
                self.docController.delegate = self
                            // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                self.docController.presentOpenInMenu(from: CGRect.zero, in: self, animated: true)
                })
                
                shareView.addButton("To Album", action: {
                    ImageManager.writeImageToAlbum(image: self.image.image!, completionhandler: nil)
                })
                shareView.showSuccess("Success", subTitle: "Now Let's share!")
            }
            alertView.showNotice("Sharing", subTitle: "It's nice to have your card open to public.")
        }
        @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "FootNote", action: #selector(self.addComment)),UIMenuItem(title: "Hide FootNote", action: #selector(self.hideComment)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Extract Text", action: #selector(self.extractText))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                
            }
        }
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if (action == #selector(self.deleteCard)){
                return true
            }else if(action == #selector(self.addComment)) && !ifCommentShowed{
                return true
            }else if (action == #selector(self.hideComment)) && ifCommentShowed{
                return true
            }else if (action == #selector(self.extractText)){
                return true
            }else if action == #selector(self.editMode){
                return true
            }else{
                return false
            }
        }
        
        @objc func extractText(){
            delegate?.picView!(extractText:self)
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
            var url = Constant.Configuration.url.PicCard
            url.appendPathComponent(self.card.getId() + ".jpg")
            User.downloadPhotosUsingQCloud(cardID: self.card.getId()) { (bool, error) in
                if bool{
                    DispatchQueue.main.async {
                        (self.card as! PicCard).pic = UIImage(contentsOfFile: (url.path))
                        self.image.image = UIImage(contentsOfFile: (url.path))
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
    
    class VoiceCardView:CardView,SFSpeechRecognizerDelegate,ProGressBarDelegate{
        var title = UITextField()
        var controllerButton = UIButton()
        var timerLable = UILabel()
        var progressBar = ProgressBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        var timer:Timer?
        var time:Int = 0
        var recognizer:SFSpeechRecognizer!
        var conversionButton:UIButton!
        var loadingView:UIView!
        func loadAudioFile(){
            loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            let loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 20))
            loadingLabel.font = UIFont.boldSystemFont(ofSize: 20)
            loadingLabel.text = "Loading..."
            loadingLabel.center.y = self.frame.height/2
            loadingLabel.center.x = self.frame.width/2
            loadingView.addSubview(loadingLabel)
            self.addSubview(loadingView)
            User.downloadAudioUsingQCloud(cardID: self.card.getId()) {[unowned self] (bool, error) in
                if bool{
                    print("load Audio SuccessFully")
                    DispatchQueue.main.async {
                        self.loadingView.removeFromSuperview()
                    }
                }else{
                    
                }
            }
        }
        
        override func menuController(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began{
                self.becomeFirstResponder()
                uimenu = UIMenuController.shared
                uimenu.arrowDirection = .default
                uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Recognition", action: #selector(openRecognition)),UIMenuItem(title: "Share", action: #selector(share))]
                uimenu.setTargetRect(self.bounds, in: self)
                uimenu.setMenuVisible(true, animated: true)
            }
        }
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if action == #selector(share) || action == #selector(editMode) || action == #selector(deleteCard) || action == #selector(openRecognition){
                return true
            }else{
                return false
            }
        }
        
        override func share() {
            let alertView = SCLAlertView()
            alertView.addButton("Share audio file to other Apps") {
                        var url = Constant.Configuration.url.Audio
                        url.appendPathComponent(self.card.getId() + ".wav")
                        if FileManager.default.fileExists(atPath: url.path){
                        let u = NSURL(fileURLWithPath: url.path)
                            self.docController = UIDocumentInteractionController.init(url: u as URL)
                            self.docController.delegate = self
                            // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                            self.docController.presentOpenInMenu(from: CGRect.zero, in: self, animated: true)
                        }else{
                            AlertView.show(alert: "The Audio File has not been downloaded locally.")
                        }
                }
            alertView.showNotice("Sharing", subTitle: "It's nice to have your card open to public.")
        }
        
        @objc func openRecognition(){
            if delegate != nil{
                delegate?.voiceView?(recognition: self)
            }
        }
        
        
        func progressBar(didChangeProgress progress: Float) {
           let card =  self.card as! VoiceCard
            if card.voiceManager?.player != nil{
                if (card.voiceManager?.player?.isPlaying)!{
                   card.voiceManager?.pause()
                }
            card.voiceManager?.player?.currentTime = Double(progress) * (card.voiceManager?.player?.duration)!
            }else{
                if (card.voiceManager?.play())!{
                card.voiceManager?.player?.currentTime = Double(progress) * (card.voiceManager?.player?.duration)!
                }
            }
        }
        
        
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
        
        
        
       
    }
    
    class MapCardView:CardView{
        //var title = UITextView()
        var neighbourAddrees = UILabel()
        var formalAddress = UILabel()
        var image = UIImageView()
        
        func loadPic(){
            var url = Constant.Configuration.url.Map
            url.appendPathComponent(self.card.getId() + ".jpg")
            
          
            User.downloadMapUsingQCloud(cardID: self.card.getId()) { (bool, error) in
                if bool{
                    DispatchQueue.main.async {
                        self.image.image = UIImage(contentsOfFile: (url.path))
                    }
                    print("load map success; cardId\(self.card.getId())")
                }
            }
            
        }
    }
    
    class ListView:CardView{
        var title:UITextField!
        
    }
    
    
    class MovieView:CardView,ProGressBarDelegate,StatusBarDelegate{
        var url:URL?
        var player:AVPlayer?
        var playerLayer:AVPlayerLayer?
        var progressBar:UIProgressView?
        var state:State = State.readyToPlay
        var playerButton:UIButton!
        var statusBar:StatusBar!
        var timer:Timer = Timer()
        
        func progressBar(didChangeProgress progress: Float) {
            player?.pause()
            player?.seek(to: CMTime(seconds: statusBar.duration * Double(progress), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            if player?.status == .readyToPlay{
                player?.play()
            }
        }
        
        func statusBar(changeStatus status: CardView.MovieView.State) {
            if status == .pause{
                pause()
            }else if status == .playing{
                play()
            }
        }
        
        class StatusBar:UIView{
            var controllButton:UIButton!
            var progressBar:ProgressBar!
            var timeLabel:UILabel!
            var expandButton:UIButton!
            weak var delegate:StatusBarDelegate?
            private var _state:State!
            var state:State{
                set{
                    _state = newValue
                    if controllButton != nil{
                    switch newValue{
                    case .pause:
                        controllButton.setFAIcon(icon: .FAPlay, forState: .normal)
                    case .playing:
                        controllButton.setFAIcon(icon: .FAPause, forState: .normal)
                    case .readyToPlay:
                        controllButton.setFAIcon(icon: .FAPlay, forState: .normal)
                    }
                    }
                }
                get{
                    return _state
                }
            }
            
            var duration:TimeInterval!
            var time:TimeInterval{
                set{
                    _time = newValue
                     timeLabel.text = "\(Int(newValue))|\(Int(duration))"
                    progressBar.setProgress(Float(newValue/duration), animated: true)
                    progressBar.slideButton.center.x = progressBar.frame.width * CGFloat(newValue)/CGFloat(duration)
                }
                
                get{
                   return _time
                }
            }
            
            private var _time:TimeInterval!
            init(frame: CGRect,state:State) {
                super.init(frame: frame)
                self.state = state
                self.frame.size.height = 50
                controllButton = UIButton(frame: CGRect(x: 10, y: 0, width: 30, height: 30))
                switch state{
                case .pause:
                    controllButton.setFAIcon(icon: .FAPlay, iconSize:30, forState: .normal)
                case .playing:
                    controllButton.setFAIcon(icon: .FAPause, iconSize: 30, forState: .normal)
                case .readyToPlay:
                    controllButton.setFAIcon(icon: .FAPlay, iconSize:30,forState: .normal)
                }
                controllButton.center.y = self.frame.height/2
                controllButton.addTarget(self, action: #selector(controllerButtonClicked), for: .touchDown)
                self.addSubview(controllButton)
                
                progressBar = ProgressBar(frame: CGRect(x: 0, y: 0, width: self.frame.width - 40 - 50 - 20, height: 30))
                progressBar.frame.origin.x = 50
                progressBar.center.y = self.frame.height/2
                timeLabel = UILabel(frame: CGRect(x: self.frame.width - 50, y: 10, width: 50 , height: 30))
                timeLabel.center.y = self.frame.height/2
                timeLabel.text = "0|0"
                self.addSubview(progressBar)
                self.addSubview(timeLabel)
            }
            
            @objc private func controllerButtonClicked(){
                if state == .pause{
                    state = .playing
                }else if state == .playing{
                    state = .pause
                }else if state == .readyToPlay{
                    state  = .playing
                }
                if delegate != nil{
                    delegate?.statusBar(changeStatus: state)
                }
            }
            
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
        }
        
        deinit {
            timer.invalidate()
        }
        
        enum State{
            case playing
            case readyToPlay
            case pause
        }
        
       @objc func playerDidFinishPlaying(){
            state = .readyToPlay
            playerButton.isHidden = false
            statusBar.time = 0
            statusBar.state = .readyToPlay
            player?.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            statusBar.isHidden = true
        }
        
        @objc func play(){
            player?.play()
            state = .playing
            timer.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[unowned self] (timer) in
                self.statusBar.duration = self.player?.currentItem?.asset.duration.seconds
                self.statusBar.time = (self.player?.currentTime().seconds)!
                self.statusBar.state = .playing
            })
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            self.addGestureRecognizer(gesture)
            playerButton.isHidden = true
        }
        
        @objc func tapped(){
            if self.statusBar.isHidden{
            self.statusBar.isHidden = false
            }else{
                self.statusBar.isHidden = true
            }
        }
        
        @objc func pause(){
            player?.pause()
            state = .pause
            timer.invalidate()
            self.statusBar.state = .pause
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getSingleCardView(card:Card)->CardView{
        let x = UIScreen.main.bounds.width
        let y = UIScreen.main.bounds.height
        let cardView = CardView(frame: CGRect(x: 0, y: 0, width: x*0.85, height: y/4))
        //cardView.clipsToBounds = true
        cardView.card = card
        cardView.center.x = x/2
        
        //colorView.backgroundColor = card.color
       // cardView.backgroundColor = .white
        
      
        cardView.layer.shadowColor = card.getColor().cgColor
        cardView.layer.shadowOffset = CGSize(width:0,height:10)
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 15
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
        let labelOfDes = UILabel(frame: CGRect(x: 20,y:label.frame.height + 20,width:cardView.bounds.width - 40,height:cardView.bounds.height/2))
        labelOfDes.text = definition
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
        return cardView
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
        let labelOfDes = UILabel(frame: CGRect(x: 20,y:label.frame.height + 20,width:cardView.bounds.width - 40,height:cardView.bounds.height/2))
        labelOfDes.text = definition
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
    
    class func singleExampleView(card:ExampleCard)->ExaView{
        let view = ExaView()
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height/4)
        view.backgroundColor = UIColor.white
        view.center.x = UIScreen.main.bounds.width/2
        view.layer.cornerRadius = 15
        view.layer.shadowColor = Constant.Color.translusentGray.cgColor
        view.layer.shadowOffset = CGSize(width:0,height:5)
        view.layer.shadowOpacity = 0.5
        view.textView.layer.cornerRadius = 15
        view.textView.frame = CGRect(x:20, y:50, width: UIScreen.main.bounds.width * 0.8 - 40, height: UIScreen.main.bounds.height/4 - 50)
        view.textView.center.x = view.bounds.width/2
        view.textView.backgroundColor = .clear
        view.textView.textColor = .black
        view.textView.text = card.getDefinition()
        view.textView.isScrollEnabled = false
        let constrainSize = CGSize(width:view.textView.frame.size.width,height:CGFloat(MAXFLOAT))
        let size = view.textView.sizeThatFits(constrainSize)
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        //重新设置textview的高度
        if size.height > 50{
            view.textView.frame.size.height = size.height
            view.frame.size.height = view.textView.frame.height + view.textView.frame.origin.y
        }else{
            view.textView.frame.size.height = 50
            view.frame.size.height = view.textView.frame.height + view.textView.frame.origin.y
        }
        view.card = card
        
      
         view.title.textColor = .black
         view.title.backgroundColor = .clear
         view.title.font = UIFont.systemFont(ofSize: 20)
         view.title.text = card.getTitle()
         view.title.textAlignment = .left
         view.title.frame = CGRect(x: 20, y: 0, width:UIScreen.main.bounds.width * 0.8 - 40, height: 50)
         view.title.center.y = 25
         view.title.addBottomLine()
         view.addSubview(view.textView)
         view.addSubview(view.title)
        
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.delegate = view
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        
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
       
        view.card = card
        view.addSubview(view.textView)
       
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.delegate = view
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
      
        
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
        view.layer.cornerRadius = 15
        view.center.x = UIScreen.main.bounds.width/2
        view.backgroundColor = .clear
        view.image.layer.cornerRadius = 15
        view.image.frame.origin = CGPoint(x:0,y:0)
        view.image.frame.size = view.frame.size
        view.image.backgroundColor = .clear
        view.image.image = pic.pic
        view.image.alpha = 1
        view.addSubview(view.image)
        
        view.layer.shadowColor = Constant.Color.translusentGray.cgColor

        view.image.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.image.layer.shadowOpacity = 0.5
        view.commentView.frame = CGRect(x: 0, y: view.image.frame.height, width:  UIScreen.main.bounds.width * 0.8, height: 40)
        view.commentView.backgroundColor = .clear
        view.commentView.font = UIFont.systemFont(ofSize: 20)
        view.commentView.textColor = .black
        view.commentView.text = pic.getDescription()
        view.commentView.textAlignment  = .center
        view.addSubview(view.commentView)
        if pic.getDescription() == ""{
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
        //func adjust UI when recording
        let targetView = sender.superview as! VoiceCardView
        let card = targetView.card as! VoiceCard
        let manager = card.voiceManager
        func adjustRecoderUIWhenRecording(){
            sender.setFAIcon(icon: .FAPauseCircle, forState: .normal)
            targetView.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                targetView.timerLable.text = String(Int((card.voiceManager?.player?.currentTime)!)) + "/" + String(Int((card.voiceManager?.player?.duration)!))
                targetView.progressBar.progress =  Float((card.voiceManager?.player?.currentTime)!)/Float((card.voiceManager?.player?.duration)!)
                targetView.progressBar.slideButton.center.x = targetView.progressBar.frame.width * CGFloat(targetView.progressBar.progress)
                if !(manager?.player?.isPlaying)!{
                    manager?.state = .haveRecord
                    targetView.timer?.invalidate()
                    sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
                }
            })
        }
        
        
        if manager?.state == RecordManager.State.willRecord{
            if (manager?.beginRecord())!{
            sender.setFAIcon(icon: .FAStopCircle, forState: .normal)
            targetView.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            if manager?.state == .recording{
                targetView.timerLable.text = String(Int((card.voiceManager?.recorder?.currentTime)!))
            }
            })
            }else{
               AlertView.show(error: "Record Failed. Check if the Record Permission is On.")
            }
            
        }else if manager?.state == RecordManager.State.recording{
            manager?.stopRecord()
            sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
            manager?.canPlay = true
            targetView.timer?.invalidate()
            targetView.timerLable.text = String((card.voiceManager?.time)!)
            targetView.progressBar.isHidden = false
            UIView.animate(withDuration: 0.2) {
                sender.frame.origin.x = 30
            }
            card.voiceManager?.time = 0
           targetView.progressBar.progress = 0
        }else if manager?.state == RecordManager.State.haveRecord{
            //manager?.play()
            if manager?.player == nil{
            let play = manager?.play()
            if play!{
               adjustRecoderUIWhenRecording()
            }else{
                AlertView.show(targetView, alert: "The file has been damaged.")
                manager?.state = RecordManager.State.willRecord
            }
            }else{
                manager?.continuePlaying()
                adjustRecoderUIWhenRecording()
            }
        }else if manager?.state == RecordManager.State.playing{
            manager?.pause()
            sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
        }
        
    }
    
    class func getSingleVoiceView(card:VoiceCard)->VoiceCardView{
        let view = VoiceCardView()
        view.card = card
        view.backgroundColor = .white
       
        view.layer.shadowColor = Constant.Color.translusentGray.cgColor
        view.layer.shadowOffset = CGSize(width:0,height:5)
        view.layer.shadowOpacity = 0.5
        view.layer.cornerRadius = 15
    
        view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height:100)
        view.center.x = UIScreen.main.bounds.width/2
        
        view.title.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 30)
        view.title.font = UIFont.boldSystemFont(ofSize: 18)
        view.title.textAlignment = .center
        view.title.text = card.getTitle()
        view.title.textColor = .black
        view.addSubview(view.title)
        
        
        view.controllerButton.frame = CGRect(x:30, y:0, width: 30, height:30)
        if card.voiceManager?.state == .willRecord || card.voiceManager?.state == .recording{
        view.controllerButton.setFAIcon(icon: .FAMicrophone, iconSize: 30, forState: .normal)
        view.progressBar.isHidden = true
        view.controllerButton.center.x = view.frame.width/2
        view.controllerButton.center.y = view.frame.height/2
        }else{
        view.controllerButton.setFAIcon(icon: .FAPlayCircle, iconSize: 30, forState: .normal)
            view.controllerButton.center.y = view.frame.height/2
           
        }
        view.timerLable.frame = CGRect(x:view.frame.width - 75, y:0, width: 75, height:75)
        view.timerLable.font = UIFont.systemFont(ofSize: 15)
        view.timerLable.textColor = .black
        view.timerLable.text = "0"
        view.timerLable.textAlignment = .center
        view.timerLable.center.y = view.frame.height/2
        view.progressBar.frame = CGRect(x: 80, y: 0, width: view.frame.width - 75 - 80, height: 50)
        view.progressBar.center.y = view.frame.height/2
        view.progressBar.progress = 0
        view.progressBar.delegate = view
        
       // view.controllerButton.setTitle("录音", for: UIControlState.normal)
       
        
       // view.conversionButton = UIButton(frame: CGRect(x: 0, y: 80, width: 20, height: 20))
        //view.conversionButton.setFAIcon(icon: .FAGlobe, iconSize: 20, forState: .normal)
        //view.conversionButton.setTitleColor(.black, for: .normal)
        //view.conversionButton.addTarget(view, action: #selector(view.recognizeFile), for: .touchDown)
        view.controllerButton.setTitleColor(.black, for: UIControlState.normal)
        view.controllerButton.addTarget(self, action: #selector(voiceViewControllButtonClicked(_:)), for:UIControlEvents.touchDown)
        view.recognizer = SFSpeechRecognizer()
        
        //view.addSubview(view.conversionButton)
        view.addSubview(view.controllerButton)
        view.addSubview(view.timerLable)
        view.addSubview(view.progressBar)
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        
        return view
    }
    
    class func getSingleMapView(card:MapCard)->MapCardView{
        let y = UIScreen.main.bounds.height
        let view = MapCardView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: y/4))
        view.card = card
        view.layer.cornerRadius = 15
        view.center.x = UIScreen.main.bounds.width/2
        view.layer.shadowColor = Constant.Color.translusentGray.cgColor
        view.layer.shadowOffset = CGSize(width:0,height:5)
        view.layer.shadowOpacity = 0.5
        view.neighbourAddrees.font = UIFont.boldSystemFont(ofSize: 15)
        view.neighbourAddrees.frame  = CGRect(x: 10, y: 5, width: view.frame.width - 40, height: 20)
        if card.neibourAddress != ""{
        view.neighbourAddrees.text = card.neibourAddress
        }else{
        view.neighbourAddrees.text = card.formalAddress
        }
        view.formalAddress.frame = CGRect(x: 10, y: 25, width: view.frame.width - 40, height: 20)
        view.formalAddress.text = card.formalAddress
        view.formalAddress.font = UIFont.systemFont(ofSize: 12)
        var url = Constant.Configuration.url.Map
        url.appendPathComponent(card.getId() + ".jpg")
        let ifExist = FileManager.default.fileExists(atPath: url.path)
        if ifExist{
            view.image.image = UIImage(named: url.path)
        }else{
            view.image.image = UIImage(named:"searchBar")
        }
        view.image.frame = CGRect(x:0, y: 0, width: view.frame.width, height: view.frame.height)
        view.image.layer.cornerRadius = 15
        view.image.clipsToBounds = true
        let whiteCorner = UIView(frame: CGRect(x: 10, y: 10, width: view.frame.width - 20, height: 50))
        whiteCorner.layer.cornerRadius = 15
        whiteCorner.backgroundColor = .white
        whiteCorner.addSubview(view.neighbourAddrees)
        whiteCorner.addSubview(view.formalAddress)
        
       // view.addSubview(view.title)
        view.addSubview(view.image)
        view.addSubview(whiteCorner)
    
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        
        return view
    }
    
    class func getSingleMovieView(card:MovieCard)->MovieView{
       let view = MovieView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.6))
        view.center.x = UIScreen.main.bounds.width/2
        view.card = card
        let url = Constant.Configuration.url.Movie.absoluteURL.appendingPathComponent(card.getId() + ".mov")
        view.url = url
        view.clipsToBounds = true
        print("path:\(url.path)")
        let playerItem = AVPlayerItem(url: view.url!)
        NotificationCenter.default.addObserver(view,
                                               selector: #selector(view.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        view.player = AVPlayer(playerItem: playerItem)
          let theNaturalSize = view.player?.currentItem?.asset.tracks(withMediaType: .video)[0]
        let size = theNaturalSize?.naturalSize
        let ratio = (size?.width)!/(size?.height)!
        view.frame.size.height = view.frame.width/ratio
        view.playerLayer = AVPlayerLayer(player: view.player)
       // view.frame.size = (view.playerLayer?.videoRect.size)!
        view.playerLayer?.frame = view.bounds
        view.playerLayer?.videoGravity = .resizeAspect
        view.layer.addSublayer(view.playerLayer!)
        view.layer.cornerRadius = 10
       
        view.playerButton = UIButton(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
        view.playerButton.setFAIcon(icon: .FAPlay, iconSize: 50, forState: .normal)
        view.playerButton.setTitleColor(.white, for: .normal)
        view.playerButton.addTarget(view, action: #selector(view.play), for: .touchDown)
        view.playerButton.center.x = view.frame.width/2
        view.playerButton.center.y = view.frame.height/2
        view.addSubview(view.playerButton)
        
        view.statusBar = MovieView.StatusBar(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50), state: MovieView.State.readyToPlay)
        view.statusBar.isHidden = true
        view.statusBar.delegate = view
        view.addSubview(view.statusBar)
        
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
        let text = self.text.substring(with: r!)
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



//status Bar delegate
protocol StatusBarDelegate:NSObjectProtocol{
    func statusBar(changeStatus status:CardView.MovieView.State)
}
