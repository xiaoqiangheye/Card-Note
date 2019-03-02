//
//  VideoController.swift
//  Card Note
//
//  Created by Wei Wei on 1/22/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Font_Awesome_Swift

class VideoController:UIViewController,StatusDelegate,ProGressBarDelegate{
    private var videoView:UIView!
    private var exitButton:UIButton!
    private var statusBar:StatusBar!
    private var avPlayer:AVPlayer!
    private var avPlayerLayer:AVPlayerLayer!
    private var playerButton:UIButton!
    private var currentstate:StatusBar.State!
    private var background:UIView!
    private var backButton:UIButton!
    private var forwardButton:UIButton!
    private var timer:Timer = Timer()
    private var bartimer:Timer = Timer()
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    
    @objc func canRotate() -> Void {}
    
    
    func progressBar(didChangeProgress progress: Float) {
        pause()
        avPlayer?.seek(to: CMTime(seconds: statusBar.duration * Double(progress), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        if avPlayer?.status == .readyToPlay{
            play()
        }
    }
    
    func progressBar(panned progressBar: ProgressBar) {
        pause()
    }
    
    
    //first entry
    override func viewDidLoad() {
        self.view.backgroundColor = .black
        //videoView
        videoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width))
        self.view.addSubview(videoView)
        
        //background
        background = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width))
        background.backgroundColor = Constant.Color.translusentBlack
        background.alpha = 0.8
        self.view.addSubview(background)
        
        //back
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        backButton.center.x = self.view.frame.height/3
        backButton.center.y = self.view.frame.width/2
        backButton.addTarget(self, action: #selector(back), for: .touchDown)
        backButton.setFAIcon(icon: .FABackward, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        self.view.addSubview(backButton)
        //forward
        forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        forwardButton.center.x = self.view.frame.height/3*2
        forwardButton.center.y = self.view.frame.width/2
        forwardButton.addTarget(self, action: #selector(forward), for: .touchDown)
        forwardButton.setFAIcon(icon: .FAForward, iconSize: 30, forState: .normal)
        forwardButton.setTitleColor(.white, for: .normal)
        self.view.addSubview(forwardButton)
        
        //status bar
        statusBar = StatusBar(frame: CGRect(x: 0, y: self.view.frame.width - 50, width: self.view.frame.height, height: 50), state: .readyToPlay)
        
        statusBar.setProgressColor(color: .white)
        statusBar.delegate = self
        statusBar.progressBar.delegate = self
        self.view.addSubview(statusBar)
        
        //exitbutton
        exitButton = UIButton(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
        exitButton.setFAIcon(icon:FAType.FATimes, iconSize: 30, forState: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.addTarget(self, action: #selector(dismissVC), for: .touchDown)
        self.view.addSubview(exitButton)
        
        //playerbutton
        playerButton = UIButton(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
        playerButton.setFAIcon(icon: .FAPlay, iconSize: 50, forState: .normal)
        playerButton.setTitleColor(.white, for: .normal)
        playerButton.addTarget(view, action: #selector(play), for: .touchDown)
        playerButton.center.x = view.frame.width/2
        playerButton.center.y = view.frame.height/2
        self.view.addSubview(playerButton)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.view.addGestureRecognizer(gesture)
        playerButton.isHidden = true
        
        //state
        currentstate = StatusBar.State.readyToPlay
        if(avPlayer != nil){
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: avPlayer.currentItem)
            play()
        }
    }
    
    
    internal func statusBar(status: StatusBar.State) {
        if status == .pause{
            pause()
        }else if status == .playing{
            play()
        }
    }
    
    @objc private func dismissVC(){
        timer.invalidate()
        bartimer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func back(){
        avPlayer?.seek(to: avPlayer.currentTime() -
            CMTime(seconds: 15.0, preferredTimescale: 1))
       
        
    }
    
    @objc private func forward(){
        avPlayer?.seek(to: avPlayer.currentTime() +  CMTime(seconds: 15.0, preferredTimescale: 1))
    }
    
    
    func loadMovie(avPlayer:AVPlayer){
        self.avPlayerLayer = AVPlayerLayer(player: avPlayer)
        self.avPlayer = avPlayer
        self.avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width)
        self.avPlayerLayer?.videoGravity = .resizeAspect
        self.videoView.layer.addSublayer(avPlayerLayer)
    }
    
    func loadMovie(url:URL){
        let manager = FileManager.default
        if(manager.fileExists(atPath: url.path)){
            let playerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self.view,
                                                   selector: #selector(playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            self.avPlayer = AVPlayer(playerItem: playerItem)
            let theNaturalSize = self.avPlayer.currentItem?.asset.tracks(withMediaType: .video)[0]
            let size = theNaturalSize!.naturalSize
            let ratio = (size.width)/(size.height)
            view.frame.size.height = view.frame.width/ratio
            
            self.avPlayerLayer = AVPlayerLayer(player: avPlayer)
            // view.frame.size = (view.playerLayer?.videoRect.size)!
            self.avPlayerLayer?.frame = view.bounds
            self.avPlayerLayer?.videoGravity = .resizeAspect
            
            self.videoView.layer.addSublayer(avPlayerLayer)
            avPlayerLayer.zPosition = -1
            view.bringSubview(toFront: statusBar)
        }
    }
    
    @objc internal func playerDidFinishPlaying(){
        timer.invalidate()
        currentstate = .readyToPlay
        playerButton.isHidden = false
        statusBar.time = 0
        statusBar.state = .readyToPlay
        avPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        statusBar.isHidden = true
    }
    
    @objc func play(){
        avPlayer?.play()
        currentstate = .playing
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[unowned self] (timer) in
            self.statusBar.duration = self.avPlayer?.currentItem?.asset.duration.seconds
            self.statusBar.time = (self.avPlayer?.currentTime().seconds)!
            self.statusBar.state = .playing
        })
    }
    
    @objc func pause(){
        avPlayer?.pause()
        currentstate = .pause
        timer.invalidate()
        self.statusBar.state = .pause
        
    }
    
    @objc private func tapped(){
        //show status bar
        if self.statusBar.isHidden{
            self.statusBar.isHidden = false
            self.exitButton.isHidden = false
            self.background.isHidden = false
            self.playerButton.isHidden = false
            self.backButton.isHidden = false
            self.forwardButton.isHidden = false
            bartimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {[weak self] (timer) in
                self?.backButton.isHidden = true
                self?.forwardButton.isHidden = true
                self?.statusBar.isHidden = true
                self?.exitButton.isHidden = true
                self?.background.isHidden = true
                self?.playerButton.isHidden = true
            }
        }else{
            bartimer.invalidate()
            self.statusBar.isHidden = true
            self.exitButton.isHidden = true
            self.background.isHidden = true
            self.playerButton.isHidden = true
            self.backButton.isHidden = true
            self.forwardButton.isHidden = true
        }
    }
}



class StatusBar:UIView{
    private var controllButton:UIButton!
    var progressBar:ProgressBar!
    private var timeLabel:UILabel!
    private var expandButton:UIButton!
    weak var delegate:StatusDelegate?
    private var _state:State!
    private var _time:TimeInterval!
    
    enum State{
        case playing
        case readyToPlay
        case pause
    }
    
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
            let minite = Int(duration - newValue)/60
            let second = Int(duration - newValue)%60
            timeLabel.text = "" + (minite >= 10 ? "\(minite)" : "0\(minite)") + ":" + (second >= 10 ? "\(second)":"0\(second)")
            progressBar.setProgress(Float(newValue/duration), animated: true)
            progressBar.slideButton.center.x = progressBar.frame.width * CGFloat(newValue)/CGFloat(duration)
        }
        
        get{
            return _time
        }
    }
    
    
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
        
        progressBar = ProgressBar(frame: CGRect(x: 0, y: 0, width: self.frame.width - 50 - 60, height: 30))
        progressBar.frame.origin.x = 50
        progressBar.center.y = self.frame.height/2
        timeLabel = UILabel(frame: CGRect(x: self.frame.width - 50, y: 10, width: 50 , height: 30))
        timeLabel.center.y = self.frame.height/2
        timeLabel.textColor = .white
        timeLabel.text = "00:00"
        
        _time = 0
        
        self.addSubview(progressBar)
        self.addSubview(timeLabel)
        
        self.backgroundColor = Constant.Color.translusentBlack
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
            delegate?.statusBar(status: state)
        }
    }
    
    
    @objc func setProgressColor(color:UIColor){
        self.progressBar.backgroundColor = color
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol StatusDelegate:NSObjectProtocol{
    func statusBar(status:StatusBar.State)
}
