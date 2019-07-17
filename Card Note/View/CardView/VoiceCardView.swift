//
//  VoiceView.swift
//  Card Note
//
//  Created by Wei Wei on 7/6/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import Speech
import UIKit
import SCLAlertView

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
    
    
    override init(card: Card) {
        super.init(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height:100))
        self.card = card
        VoiceCardView.decorateView(view: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func decorateView(view:VoiceCardView){
        let card = view.card as! VoiceCard
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
        
        view.controllerButton.setTitleColor(.black, for: UIControl.State.normal)
        view.controllerButton.addTarget(view, action: #selector(view.voiceViewControllButtonClicked(_:)), for:UIControl.Event.touchDown)
        view.recognizer = SFSpeechRecognizer()
        
        //view.addSubview(view.conversionButton)
        view.addSubview(view.controllerButton)
        view.addSubview(view.timerLable)
        view.addSubview(view.progressBar)
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
    }
    
    
    @objc override func reload(){
        if (card as! VoiceCard).voiceManager?.state == .willRecord || (card as! VoiceCard).voiceManager?.state == .recording{
            self.controllerButton.setFAIcon(icon: .FAMicrophone, iconSize: 30, forState: .normal)
            self.progressBar.isHidden = true
            self.controllerButton.center.x = self.frame.width/2
            self.controllerButton.center.y = self.frame.height/2
        }else{
            self.controllerButton.setFAIcon(icon: .FAPlayCircle, iconSize: 30, forState: .normal)
            self.controllerButton.frame = CGRect(x:30, y:0, width: 30, height:30)
            self.controllerButton.center.y = self.frame.height/2
            self.progressBar.isHidden = false
            
        }
    }
    
    @objc func loadAudioFile(){
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        loadingView.backgroundColor = .white
        let loadingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 20))
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        loadingLabel.text = "Loading..."
        loadingLabel.center.y = self.frame.height/2
        loadingLabel.center.x = self.frame.width/2
        loadingLabel.textColor = .black
        loadingView.addSubview(loadingLabel)
        self.addSubview(loadingView)
        Cloud.downloadAsset(id: self.card.getId(), type: "AUDIO") { [weak self](bool, error) in
            if bool{
                DispatchQueue.main.async {
                    self?.loadingView.removeFromSuperview()
                }
            }else{
                DispatchQueue.main.async {
                    loadingLabel.text = "Loading failed. Click to reload."
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(self?.loadAudioFile))
                    self?.loadingView.addGestureRecognizer(gesture)
                }
            }
        }
    }
    
    override func menuController(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            self.becomeFirstResponder()
            uimenu = UIMenuController.shared
            uimenu.arrowDirection = .default
            uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Share", action: #selector(share))]
            uimenu.setTargetRect(self.bounds, in: self)
            uimenu.setMenuVisible(true, animated: true)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(share) || action == #selector(editMode) || action == #selector(deleteCard){
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
                self.docController.uti = "public.data"
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
            card.voiceManager?.player?.currentTime = Double(progress) * (card.voiceManager?.player?.duration)!
            play()
            // card.voiceManager?.player?.play(atTime: (card.voiceManager?.player?.duration)! * Double(progress))
        }else{
            if(play()){
                card.voiceManager?.player?.currentTime = Double(progress) * (card.voiceManager?.player?.duration)!
            }
        }
    }
    
    func play()->Bool{
        let card = self.card as! VoiceCard
        var success = true
        if card.voiceManager?.player == nil{
            let play = card.voiceManager?.play()
            if play!{
                adjustRecoderUIWhenRecording()
            }else{
                success = false
                AlertView.show(alert: "The file has been damaged.")
                card.voiceManager?.state = RecordManager.State.willRecord
                self.reload()
            }
        }else{
            card.voiceManager?.continuePlaying()
            adjustRecoderUIWhenRecording()
        }
        return success
    }
    
    func pause(){
        let card = self.card as! VoiceCard
        card.voiceManager?.pause()
        controllerButton.setFAIcon(icon: .FAPlayCircle, forState: .normal)
    }
    
    func adjustRecoderUIWhenRecording(){
        let card = self.card as! VoiceCard
        controllerButton.setFAIcon(icon: .FAPauseCircle, forState: .normal)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            let duration = card.voiceManager?.player?.duration
            let currentTime = card.voiceManager?.player?.currentTime
            let minute = Int(duration! - currentTime!)/60
            let second = Int(duration! - currentTime!) % 60
            self.timerLable.text = "" + (minute >= 10 ? "\(minute)":"0\(minute)") + ":" + (second >= 10 ? "\(second)":"0\(second)")
            self.progressBar.progress = Float((card.voiceManager?.player?.currentTime)!)/Float((card.voiceManager?.player?.duration)!)
            self.progressBar.slideButton.center.x = self.progressBar.frame.width * CGFloat(self.progressBar.progress)
            if !(card.voiceManager?.player?.isPlaying)!{
                card.voiceManager?.state = .haveRecord
                self.timer?.invalidate()
                self.controllerButton.setFAIcon(icon: .FAPlayCircle, forState: .normal)
            }
        })
    }
    
    @objc func voiceViewControllButtonClicked(_ sender:UIButton){
        //func adjust UI when recording
        let targetView = sender.superview as! VoiceCardView
        let card = targetView.card as! VoiceCard
        let manager = card.voiceManager
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
            play()
        }else if manager?.state == RecordManager.State.playing{
            pause()
        }
        
    }
    
    func progressBar(panned progressBar: ProgressBar) {
        let card = self.card as! VoiceCard
        if card.voiceManager?.player != nil{
            if (card.voiceManager?.player?.isPlaying)!{
                pause()
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
