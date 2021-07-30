//
//  VoiceRecognitionController.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/18.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
import AVKit
import Speech
import SCLAlertView

class VoiceRecognitionController:UIViewController,SFSpeechRecognitionTaskDelegate{
    weak var delegate:CardEditorDelegate?
    var backButton:UIButton!
    var recordButton:UIButton!
    var recognizeFileButton:UIButton!
    let audioEngine = AVAudioEngine()
    var speechRecognizer:SFSpeechRecognizer?
    var recognitionTask:SFSpeechRecognitionTask? = nil
    let request = SFSpeechAudioBufferRecognitionRequest()
    var voiceCardView:VoiceCardView!
    var textView:UITextView!
    var card:VoiceCard?
    var superCard:UIView!
    var timer:Timer?
    var loadingView:LoadingView?
    var deleteButton:UIButton!
    var toLanguageLabel:UIButton!
    var copyButton:UIButton!
    private var isConfigured = false
    override func viewWillDisappear(_ animated: Bool) {
        audioEngine.stop()
        recognitionTask?.finish()
        if (card?.voiceManager?.recorder) != nil{
            card?.voiceManager?.stopRecord()
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let node = audioEngine.inputNode
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en"))
            
            let recordingFormat = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
                self.request.append(buffer)
            }
            isConfigured = true
        } catch {
            isConfigured = false
        }
    }
    
    override func viewDidLoad() {
        configureAudioSession()
        
        SpeechManager.requestForAuth()
        self.view.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.8)
        backButton = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FATimes, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
    }
    
    
    @objc private func tapped(sender:UIButton){
        let label = sender
        let vc = OptionViewController()
        vc.setTitle(string: "Languages")
        vc.modalPresentationStyle = .overCurrentContext
        if label == toLanguageLabel{
            let strings = languageDictionary?.allKeys as! [String]
            var s = Set(strings)
            s.remove("Auto")
            vc.loadOptions(strings: s.sorted()) {[weak self] (string) in
                label.setTitle(string, for: .normal)
                let value = languageDictionary![string] as! String
                self?.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: value))
                if self?.speechRecognizer == nil{
                    DispatchQueue.main.async {
                         AlertView.show(alert: "Current languages seems not available.")
                    }
                    self?.speechRecognizer = SFSpeechRecognizer()
                }
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func loadVoiceCardView(voiceCard:VoiceCard){
        //init card
        self.card = voiceCard
        //the white big card
        superCard = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 450))
        superCard.backgroundColor = .white
        superCard.layer.cornerRadius = 10
        superCard.center = self.view.center
        superCard.layer.masksToBounds = true
        
        
        toLanguageLabel = UIButton(frame: CGRect(x: 0, y: 0, width: superCard.frame.width, height: 50))
        toLanguageLabel.setTitle("English", for: .normal)
        toLanguageLabel.setTitleColor(.white, for: .normal)
        toLanguageLabel.addTarget(self, action: #selector(tapped), for: .touchDown)
        toLanguageLabel.backgroundColor = Constant.Color.themeColor
        
        
        //recognize File
        /*
        recognizeFileButton = UIButton(frame: CGRect(x: 20, y: 50, width: superCard.frame.width/2 - 10, height: 40))
        recognizeFileButton.setFAIcon(icon: .FASearch, iconSize: 30, forState: .normal)
        recognizeFileButton.center.x = superCard.frame.width/4
        recognizeFileButton.frame.origin.y = 400
        recognizeFileButton.isHidden = true
        recognizeFileButton.setTitleColor(.white, for: .normal)
        recognizeFileButton.layer.cornerRadius = 10
        recognizeFileButton.backgroundColor = Constant.Color.themeColor
        recognizeFileButton.addTarget(self, action: #selector(recognizeFile), for: .touchDown)
        */
        
        //copyButton
        copyButton = UIButton(frame: CGRect(x: 20, y: 50, width: superCard.frame.width/2 - 10, height: 40))
        copyButton.setFAIcon(icon: .FACopy, iconSize: 30, forState: .normal)
        copyButton.center.x = superCard.frame.width/4
        copyButton.frame.origin.y = 400
        copyButton.isHidden = true
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.layer.cornerRadius = 10
        copyButton.backgroundColor = Constant.Color.themeColor
        copyButton.addTarget(self, action: #selector(copyString), for: .touchDown)
        
        
        //deleteButton
         deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: superCard.frame.width/2 - 10, height: 40))
         deleteButton.setFAIcon(icon: .FARepeat, iconSize: 30, forState: .normal)
         deleteButton.center.x = superCard.frame.width/4*3
         deleteButton.frame.origin.y = 400
         deleteButton.isHidden = true
         deleteButton.setTitleColor(.white, for: .normal)
         deleteButton.layer.cornerRadius = 10
         deleteButton.backgroundColor = .flatRed()
         deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchDown)
        
        //voiceCard
        voiceCardView = getsingleVoiceView(card: voiceCard)
        voiceCardView.frame.origin.y = 50
        voiceCardView.center.x = superCard.bounds.width/2
        
        textView = UITextView(frame: CGRect(x: 0, y: 150, width: superCard.frame.width * 0.8, height: 200))
        textView.textAlignment = .center
        textView.isSelectable = true
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.center.x = superCard.frame.width/2
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.layer.shadowColor = Constant.Color.translusentGray.cgColor
        textView.layer.shadowOffset = CGSize(width: 2, height: 2)
        textView.layer.shadowOpacity = 0.7
        self.textView.text = self.card?.getDescription()
        
        superCard.addSubview(textView)
        superCard.addSubview(toLanguageLabel)
        superCard.addSubview(voiceCardView)
        //superCard.addSubview(recognizeFileButton)
        superCard.addSubview(copyButton)
        superCard.addSubview(deleteButton)
        self.view.addSubview(superCard)
        
    }
    
    @objc private func deleteAction(){
        self.card?.voiceManager?.state = .willRecord
        self.card?.voiceManager?.stopRecord()
        let manager = FileManager.default
        do {try manager.removeItem(atPath: (self.card?.voicepath)!)}
        catch let error{
            print(error.localizedDescription)
        }
        //voiceCardView.removeFromSuperview()
        //loadVoiceCardView(voiceCard: self.card!)
        deleteButton.isHidden = true
        //recognizeFileButton.isHidden = true
        copyButton.isHidden = true
    }
    
    @objc private func copyString(){
        UIPasteboard.general.string = textView.text
        AlertView.show(success: "Text Copied.")
    }
    
     private func getsingleVoiceView(card:VoiceCard)->VoiceCardView{
        let view = VoiceCardView(withOutdecoration: card)
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.frame = CGRect(x:0, y:0, width: self.view.frame.width * 0.8, height: 100)
        view.center.x = UIScreen.main.bounds.width/2
        view.controllerButton.frame = CGRect(x:30, y:0, width: 30, height:30)
        view.controllerButton.setTitleColor(.black, for: UIControl.State.normal)
        loadingView = LoadingView(frame: CGRect(x: view.controllerButton.frame.origin.x + 30, y: 0, width: 50, height: 30))
        if card.voiceManager?.state == .willRecord || card.voiceManager?.state == .recording{
            view.controllerButton.setFAIcon(icon: .FAMicrophone, iconSize: 30, forState: .normal)
            view.controllerButton.center.x = view.frame.width/2
            view.controllerButton.center.y = view.frame.height/2
            loadingView?.center.y = view.controllerButton.center.y + 30
            loadingView?.center.x = view.controllerButton.center.x
            view.addSubview(loadingView!)
            
        }else{
            //recognizeFileButton.isHidden = false
            copyButton.isHidden = false
            deleteButton.isHidden = false
            view.controllerButton.center.y = view.frame.height/2
            view.controllerButton.setFAIcon(icon: .FAPlayCircle, iconSize: 30, forState: .normal)
            view.timerLable.frame = CGRect(x:view.frame.width - 75, y:0, width: 75, height:75)
            view.timerLable.font = UIFont.systemFont(ofSize: 15)
            view.timerLable.textColor = .black
            view.timerLable.text = "0"
            view.timerLable.textAlignment = .center
            view.timerLable.center.y = view.frame.height/2
            view.progressBar.frame = CGRect(x: 80, y: 0, width: view.frame.width - 75 - 80, height: 50)
            view.progressBar.center.y = view.frame.height/2
            view.progressBar.progress = 0
            view.addSubview(view.timerLable)
            view.addSubview(view.progressBar)
            startRecognizeFile()
        }
        view.controllerButton.addTarget(self, action: #selector(controllerClicked), for:UIControl.Event.touchDown)
        // view.controllerButton.setTitle("录音", for: UIControlState.normal)
        view.recognizer = SFSpeechRecognizer()
        view.addSubview(view.controllerButton)
        return view
    }
    
    @objc private func updateTimer(){
        
    }
    
    @objc private func controllerClicked(sender:UIButton){
        let card = voiceCardView.card as! VoiceCard
        let manager = card.voiceManager
        if manager?.state == .recording{
            //recognizeFileButton.isHidden = false
            copyButton.isHidden = false
            deleteButton.isHidden = false
            toLanguageLabel.isEnabled = true
            manager?.stopRecord()
            manager?.state = .willRecord
            audioEngine.stop()
            recognitionTask?.finish()
            loadingView?.animationStop()
            //loadingView?.removeFromSuperview()
            card.setDescription(self.textView.text)
            sender.setFAIcon(icon: .FAMicrophone, forState: .normal)
        }else if manager?.state == .willRecord{
            if(isConfigured){
                loadingView?.startAnimation()
                speech()
                if (manager?.beginRecord())!{
                    var stopRecordThreshold = 0
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    guard (manager?.recorder) != nil else{
                        timer.invalidate()
                        return
                    }
                    
                
                    if !(manager?.recorder?.isRecording)!{
                        timer.invalidate()
                    }
                    
                    manager?.recorder?.updateMeters()
                    guard let power = manager?.recorder?.peakPower(forChannel: 0)  else{return}
                    if Int(power) < -30 && self.recognitionTask?.state == .running && (manager?.recorder?.isRecording)!{
                        stopRecordThreshold += 1
                        if stopRecordThreshold >= 5{
                            print("finish The sentence")
                             self.recognitionTask?.finish()
                             self.audioEngine.stop()
                            self.loadingView?.waitingAnimation()
                            stopRecordThreshold = 0
                        }
                    }else if Int(power) > -30 && (self.recognitionTask?.state == .completed) && (manager?.recorder?.isRecording)!{
                            print("start the sentence")
                            self.recordandRecognizeSpeech()
                            self.loadingView?.startAnimation()
                    }
                    
                    })
               
                    sender.setFAIcon(icon: .FAStopCircle, forState: .normal)
                }
            }else{
                AlertView.show(error: "Voice can't not be used now since some app already using the voice")
            }
                
        }else if manager?.state == .haveRecord{
            let play = manager?.play()
            if play!{
                sender.setFAIcon(icon: .FAPauseCircle, forState: .normal)
                copyButton.isHidden = false
                voiceCardView.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] (timer) in
                    self.voiceCardView.timerLable.text = String(Int((card.voiceManager?.player?.currentTime)!)) + "/" + String(Int((card.voiceManager?.player?.duration)!))
                    self.voiceCardView.progressBar.progress =  Float((card.voiceManager?.player?.currentTime)!)/Float((card.voiceManager?.player?.duration)!)
                    self.voiceCardView.progressBar.slideButton.center.x = self.voiceCardView.progressBar.frame.width * CGFloat(self.voiceCardView.progressBar.progress)
                    if !(manager?.player?.isPlaying)!{
                        manager?.state = .haveRecord
                        self.voiceCardView.timer?.invalidate()
                        sender.setFAIcon(icon: .FAPlayCircle, forState: .normal)
                    }
                })
            }else{
                AlertView.show(error: "The file has been damaged.")
                manager?.state = RecordManager.State.willRecord
            }
        }else if manager?.state == .playing{
            manager?.pause()
             sender.setFAIcon(icon: .FAPauseCircle, forState: .normal)
        }else if manager?.state == .stopplaying{
            manager?.continuePlaying()
            sender.setFAIcon(icon: .FAStopCircle, forState: .normal)
        }else if manager?.state == .pausedRecording{
            manager?.continueRecord()
        }
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true) {
            if self.delegate != nil{
                self.delegate?.saveSubCards!(card: self.card!)
            }
        }
    }
    
    @objc private func recognizeFile(){
        self.startRecognizeFile()
    }
    @objc private func startRecognizeFile() {
        if(!checkRestRecognition()){
            popOutWindow(vc: self)
            return
        }
        
        let url = Constant.Configuration.url.Audio.appendingPathComponent((self.card)!.getId() + ".wav")
        guard let myRecognizer = SFSpeechRecognizer()else{return}
        if !myRecognizer.isAvailable{return}
        let processController = LoadingViewController()
        processController.setAlert("Converting to Text...")
        processController.modalPresentationStyle = .overCurrentContext
        self.present(processController, animated: false, completion: nil)
        let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: url.path))
        speechRecognizer?.recognitionTask(with: request) { (result, error) in
            if let result = result{
                if result.isFinal{
                    minusOneRecognition()
                    let bestString = result.bestTranscription.formattedString
                    print(bestString)
                    self.textView.text = bestString
                    self.card?.setDescription(self.textView.text)
                    processController.dismiss(animated: true, completion: nil)
                }
            }else if let error = error{
                print(error.localizedDescription)
                processController.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                     AlertView.show(alert: "Recognition failed.")
                }
            }
        }
    }
    
    
    @objc private func speech(){
        if(!checkRestRecognition()){
            popOutWindow(vc: self)
            return
        }
        self.recordandRecognizeSpeech()
    }
    
    @objc private func recordandRecognizeSpeech(){
        toLanguageLabel.isEnabled = false
        let text = self.textView.text == nil ? "" : self.textView.text
        audioEngine.prepare()
        do{
        try audioEngine.start()
        }catch let error{
        print(error.localizedDescription)
        }
        guard let myRecognizer = SFSpeechRecognizer()else{return}
        if !myRecognizer.isAvailable{return}
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [unowned self](result, error) in
            if let result = result{
                let bestString = result.bestTranscription.formattedString
                print(bestString)
                self.textView.text = text! + bestString + "\n"
            }else if let error = error{
                print(error.localizedDescription)
            }
        })
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        toLanguageLabel.isEnabled = true
        
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        toLanguageLabel.isEnabled = true
        minusOneRecognition()
    }
    
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        toLanguageLabel.isEnabled = true
    }
    
    
    /**delegate*/
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        toLanguageLabel.isEnabled = true
    }
    
}
