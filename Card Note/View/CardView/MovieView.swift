//
//  MovieView.swift
//  Card Note
//
//  Created by Wei Wei on 7/6/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import Font_Awesome_Swift
import SCLAlertView
class MovieView:CardView,ProGressBarDelegate,StatusBarDelegate{
    var url:URL?
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var progressBar:UIProgressView?
    var state:State = State.readyToPlay
    var playerButton:UIButton!
    var statusBar:StatusBar!
    var timer:Timer = Timer()
    var loadingView:UIButton!

    
    override init(card: Card) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.6))
        self.card = card
        MovieView.decorateCardView(view: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func decorateCardView(view:MovieView){
        view.center.x = UIScreen.main.bounds.width/2
        let url = Constant.Configuration.url.Movie.appendingPathComponent(view.card.getId() + ".mov")
        let manager = FileManager.default
        if !manager.fileExists(atPath: url.path){
            view.loadMovie()
        }
        
        view.url = url
        view.clipsToBounds = true
        print("path:\(url.path)")
        if FileManager.default.fileExists(atPath: url.path){
            let playerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(view,
                                                   selector: #selector(view.playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            view.player = AVPlayer(playerItem: playerItem)
            
            if let theNaturalSize = view.player?.currentItem?.asset.tracks(withMediaType: .video)[0]{
                let size = theNaturalSize.naturalSize
                let ratio = (size.width)/(size.height)
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
                view.statusBar.progressBar.delegate = view
                view.addSubview(view.statusBar)
            }
            
        }else{
            view.loadMovie()
        }
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
    }
    
    @objc func loadMovie(){
        loadingView = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = 15
        loadingView.setFAIcon(icon: FAType.FASpinner, forState: .normal)
        loadingView.center.x = self.frame.width/2
        loadingView.center.y = self.frame.height/2
        loadingView.layer.add(rotateAnimation, forKey: "rotate")
        self.addSubview(loadingView)
        var url = Constant.Configuration.url.Movie
        url.appendPathComponent(self.card.getId() + ".mov")
        Cloud.downloadAsset(id: self.card.getId(), type: "VIDEO") {[weak self] (bool, error) in
            if(bool){
                DispatchQueue.main.async {
                    self?.loadingView.removeFromSuperview()
                    if self != nil{
                        MovieView.decorateCardView(view: self!)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self?.loadingView.setFAIcon(icon: FAType.FARepeat, forState: .normal)
                    self?.loadingView.addTarget(self, action: #selector(self?.loadMovie), for: .touchDown)
                    
                }
            }
        }
    }
    
    func progressBar(didChangeProgress progress: Float) {
        pause()
        player?.seek(to: CMTime(seconds: statusBar.duration * Double(progress), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        if player?.status == .readyToPlay{
            play()
        }
    }
    
    func progressBar(panned progressBar: ProgressBar) {
        pause()
    }
    
    func statusBar(changeStatus status: MovieView.State) {
        if status == .pause{
            pause()
        }else if status == .playing{
            play()
        }
    }
    
    enum State{
        case playing
        case readyToPlay
        case pause
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
            timeLabel.text = "00:00"
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
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        gesture2.numberOfTapsRequired = 2
        self.addGestureRecognizer(gesture2)
        self.addGestureRecognizer(gesture)
        playerButton.isHidden = true
    }
    
    @objc private func tapped(ges:UITapGestureRecognizer){
        if(ges.numberOfTouches == 1){
            if self.statusBar.isHidden{
                self.statusBar.isHidden = false
            }else{
                self.statusBar.isHidden = true
            }
        }
    }
    
    @objc private func doubleTapped(){
        if(delegate != nil){
            delegate?.movieView!(expand: self)
        }
    }
    
    @objc func pause(){
        player?.pause()
        state = .pause
        timer.invalidate()
        self.statusBar.state = .pause
    }
    
    override func share() {
        let alertView = SCLAlertView()
        alertView.addButton("Share the video to other Apps") {
            var url = Constant.Configuration.url.Movie
            url.appendPathComponent(self.card.getId() + ".mov")
            if FileManager.default.fileExists(atPath: url.path){
                let u = NSURL(fileURLWithPath: url.path)
                self.docController = UIDocumentInteractionController.init(url: u as URL)
                self.docController.delegate = self
                self.docController.uti = "public.movie"
                // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                self.docController.presentOpenInMenu(from: CGRect.zero, in: self, animated: true)
                
            }else{
                AlertView.show(alert: "The video file has not been downloaded locally.")
            }
        }
        alertView.showNotice("Sharing", subTitle: "It's nice to have your card shared.")
    }
    
    
}


