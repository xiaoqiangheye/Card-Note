//
//  SpeechManager.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/21.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Speech

class SpeechManager{
    class func requestForAuth(){
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
    }
    
    }
    
    class func recognizeFile(url:NSURL) {
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: url as URL)
        myRecognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                return
            }
            if result.isFinal {
                // Print the speech that has been recognized so far
                print("Speech in the file is \(result.bestTranscription.formattedString)")
            }
        }
    }
}

