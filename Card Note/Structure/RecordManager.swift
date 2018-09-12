//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/27.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Foundation
import AVFoundation

class RecordManager {
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var file_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    var canPlay:Bool = false
    var time:Int = 0
    var state:State = State.willRecord
    var maxTime = 60
    enum State:String{
        case willRecord = "willRecord"
        case haveRecord = "haveRecord"
        case recording = "recording"
        case pausedRecording = "pausedRecording"
        case playing = "playing"
        case stopplaying = "stopplaying"
    }
    
    private var timer:Timer?
  
    
    init(userID:String,fileName:String) {
        file_path?.append("/audio/\(fileName)")
    }
    
    //开始录音
    func beginRecord() {
        let session = AVAudioSession.sharedInstance()
        //设置session类型
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
        //录音设置，注意，后面需要转换成NSNumber，如果不转换，你会发现，无法录制音频文件，我猜测是因为底层还是用OC写的原因
        let recordSetting: [String: Any] = [AVSampleRateKey: NSNumber(value:16000),//采样率
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
            AVLinearPCMBitDepthKey: NSNumber(value:16),//采样位数
            AVNumberOfChannelsKey: NSNumber(value:2),//通道数
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue//录音质量
        ];
        //开始录音
        do {
            state = .recording
            let manager = FileManager.default
            let url = URL(fileURLWithPath: file_path!)
            let direct = url.deletingLastPathComponent()
            if !manager.fileExists(atPath: direct.path){
               try? manager.createDirectory(at: direct,withIntermediateDirectories: true, attributes: nil)
            }
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder?.isMeteringEnabled = true
            recorder!.prepareToRecord()
            recorder!.record()
            print("开始录音")
            /*
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                if (self.recorder!.currentTime) >= TimeInterval(self.maxTime){
                    self.stopRecord()
                }
            }
            */
        } catch let err {
            print("录音失败:\(err.localizedDescription)")
        }
        
    }
    
    
    //结束录音
    func stopRecord() {
        timer?.invalidate()
        if let recorder = self.recorder {
            if recorder.isRecording {
                self.state = State.haveRecord
                print("正在录音，马上结束它，文件保存到了：\(file_path!)")
                canPlay = true
            }else {
                print("没有录音，但是依然结束它")
            }
            recorder.stop()
            self.recorder = nil
        }else {
            print("没有初始化")
        }
    }
    
    func pauseRecord(){
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("正在录音，马上暂停它")
            }else {
                print("没有录音，但是依然结束它")
            }
            recorder.pause()
            self.state = .pausedRecording
            self.recorder = nil
        }else {
            print("没有初始化")
        }
    }
    
    func continueRecord(){
        if let recorder = self.recorder {
            recorder.record()
        }
    }
    
    //播放
    func play()->Bool{
        do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                try AVAudioSession.sharedInstance().setActive(true)
                try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
         //  print(FileManager.default.fileExists(atPath: URL(fileURLWithPath: file_path!).path))
            state = State.playing
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file_path!))
            print("歌曲长度：\(player!.duration)")
            player!.play()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                if Double((self.player?.currentTime)!) >= Double((self.player?.duration)!){
                    self.state = State.haveRecord
                    timer.invalidate()
                }
            }
            return true
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
            return false
        }
    }
    
    func pause(){
        if player != nil{
            if (player?.isPlaying)!{
                player?.pause()
                state = State.stopplaying
            }
        }
    }
    
    func continuePlaying(){
        if player != nil{
            if !(player?.isPlaying)!{
                player?.play()
               state = State.playing
            }
        }
    }
    
    static func play(filePath:String)->Bool
    {
        do {
            var player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            print("歌曲长度：\(player.duration)")
            player.prepareToPlay()
            player.play()
            return true
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
            return false
        }
    }
    
    func playWithAVPlayer()->Bool{
        do{
            var player = AVPlayer(url: URL(fileURLWithPath: file_path!))
            player.play()
            return true
        }catch let err{
            return false
        }
    }
    
}

