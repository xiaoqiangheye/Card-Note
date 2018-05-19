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

class CardView: UIView{
    weak var delegate:CardViewDelegate?
    var card:Card!
    var label:UILabel = UILabel()
    var labelofDes:UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    class ExaView:CardView,UITextViewDelegate{
        var textView = UITextView()
        var translateTextView = UITextView()
        var example:String = ""
         var uimenu:UIMenuController!
        var ifTranslated = false
        @objc func hideTranslate(){
            translateTextView.removeFromSuperview()
            textView.isHidden = false
            ifTranslated = false
        }
        
        @objc func menuController(_ sender:UILongPressGestureRecognizer){
            if sender.state == .began{
                if !ifTranslated{
            self.becomeFirstResponder()
            uimenu = UIMenuController.shared
            uimenu.arrowDirection = .default
            uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(translate))]
            uimenu.setTargetRect(self.bounds, in: self)
            uimenu.setMenuVisible(true, animated: true)
                }else{
                    self.becomeFirstResponder()
                    uimenu = UIMenuController.shared
                    uimenu.arrowDirection = .default
                    uimenu.menuItems = [UIMenuItem(title: "Cancel Translation", action: #selector(hideTranslate))]
                    uimenu.setTargetRect(self.bounds, in: self)
                    uimenu.setMenuVisible(true, animated: true)
                }
            }
        }
        
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if action == #selector(translate) && !ifTranslated{
                return true
            }else if action == #selector(hideTranslate) && ifTranslated{
                return true
            }
            return false
        }
        
        override var canBecomeFirstResponder: Bool {
            return true
        }
        
        @objc func translate(){
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
        var ifTranslated = false
        var uimenu:UIMenuController!
        @objc func hideTranslate(){
            translateTextView.removeFromSuperview()
            textView.isHidden = false
            ifTranslated = false
        }
        
        @objc func menuController(_ sender:UILongPressGestureRecognizer){
            if sender.state == .began{
                if !ifTranslated{
             self.becomeFirstResponder()
             uimenu = UIMenuController.shared
             uimenu.arrowDirection = .default
             uimenu.setTargetRect(self.bounds, in: self)
             uimenu.setMenuVisible(true, animated: true)
             uimenu.menuItems = [UIMenuItem(title: "Translate", action: #selector(translate))]
                }else{
                   
                        self.becomeFirstResponder()
                        uimenu = UIMenuController.shared
                        uimenu.arrowDirection = .default
                        uimenu.menuItems = [UIMenuItem(title: "Cancel Translation", action: #selector(hideTranslate))]
                        uimenu.setTargetRect(self.bounds, in: self)
                        uimenu.setMenuVisible(true, animated: true)
                    
                }
            }
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
            }
            return false
        }
        
        @objc func translate(){
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
                  
                    view.configureContent(title: "Error", body: "Translation Went Wrong.", iconText: "")
                    
                    // Show the message.
                    SwiftMessages.show(view: view)
                }
            }
        }
    }
    
    class PicView:CardView{
        var image:UIImageView = UIImageView()
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
    }
    
    class VoiceCardView:CardView{
        var controllerButton = UIButton()
        var timerLable = UILabel()
        var progressBar = UIProgressView(progressViewStyle: .default)
        var timer:Timer?
        var time:Int = 0
        
        func ocr(){
            
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
        label.text = title
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
        let labelOfDes = UITextView(frame: CGRect(x:cardView.frame.width/8 + 20,y:label.frame.height + 10,width:cardView.bounds.width-cardView.frame.width/8,height:cardView.bounds.height/2))
        labelOfDes.backgroundColor = .clear
        labelOfDes.text = definition
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
        view.textView.addGestureRecognizer(longTapGesture)
        
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
    
    class func getSingleTextView(string:String)->TextView{
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
        view.textView.attributedText = NSAttributedString(string: string)
        let constrainSize = CGSize(width:view.textView.frame.size.width,height:CGFloat(MAXFLOAT))
        var size = view.textView.sizeThatFits(constrainSize)
        
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        //重新设置textview的高度
        view.textView.frame.size.height = size.height
        view.frame.size.height = size.height
        view.card = TextCard(text: string)
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
        view.textView.addGestureRecognizer(longTapGesture)
        
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
        view.controllerButton.frame = CGRect(x:0, y:0, width: 100, height:100)
        if card.voiceManager?.state == .willRecord || card.voiceManager?.state == .recording{
        view.controllerButton.setFAIcon(icon: .FAMicrophone, forState: .normal)
        }else{
        view.controllerButton.setFAIcon(icon: .FAPlayCircle, forState: .normal)
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
        view.addSubview(view.controllerButton)
        view.addSubview(view.timerLable)
        view.addSubview(view.progressBar)
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
        return view
    }
}
