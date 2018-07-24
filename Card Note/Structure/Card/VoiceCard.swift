//
//  VoiceCard.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/27.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit


class VoiceCard:Card{
    var voicepath = Constant.Configuration.url.Audio.absoluteString
    var voiceManager:RecordManager?
    init(id:String) {
        super.init(title: "", tag: "", description: "", id: id, definition: "", color: UIColor.white, cardType: "voice", modifytime: "")
        voicepath.append(contentsOf: "/\(id).wav")
        voiceManager = RecordManager(userID: loggedID, fileName: "\(id).wav")
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
       // aCoder.encode(voicepath, forKey: "voicePath")
        aCoder.encode(voiceManager?.state.rawValue, forKey: "state")
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      //  self.voicepath = (aDecoder.decodeObject(forKey: "voicePath") as? String)!
        self.voiceManager = RecordManager(userID: loggedID, fileName: "\(self.getId()).wav")
        let state = aDecoder.decodeObject(forKey: "state") as? String
        if state != nil{
            self.voiceManager?.state = RecordManager.State(rawValue:state!)!
        }else{
          self.voiceManager?.state = RecordManager.State.willRecord
        }
        // fatalError("init(coder:) has not been implemented")
    }
    
  
}
