//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/22.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
class CardParser{
    static var queue = OperationQueue()
    class func filter(_ string:String)->String{
      // let string1 = string.replacingOccurrences(of: "\\", with: "")
      // let string5 = string4.replacingOccurrences(of: "\b", with: "")
       let string2 = string.replacingOccurrences(of: "\n", with: "\\n")
       let string3 = string2.replacingOccurrences(of: "\r", with: "\\r")
       let string4 = string3.replacingOccurrences(of: "\t", with: "\\t")
        return string4
    }
    
   
    
    class func CardToJson(bycoder card:Card)->Data?{
        let coder = JSONEncoder()
        do{
        let data = try coder.encode(card)
            return data
        }catch let error{
            print(error.localizedDescription)
            return nil
        }
    }
    
    class func JSONToCard(_ json:String)->Card?{
        var card:Card!
        queue.maxConcurrentOperationCount = 1
        do{ 
            let json = try JSON(data: json.data(using: String.Encoding.utf8)!)
            let title = json["title"].stringValue
            let tagsJson = json["tag"].arrayValue
            var tags = [String]()
            for tag in tagsJson{
               tags.append(tag.stringValue)
            }
            let id = json["id"].stringValue
            let definition = json["definition"].stringValue
            let description = json["description"].stringValue
            let type = json["type"].stringValue
            let colorString = json["color"].arrayValue
            var color:UIColor?
            if colorString.count >= 4{
                color = UIColor(red: CGFloat(colorString[0].float!), green: CGFloat(colorString[1].float!), blue: CGFloat(colorString[2].float!), alpha: CGFloat(colorString[3].float!))
            }else{
            color = nil
            }
            let modifytime = json["time"].stringValue
            if type == "card"{
                card = Card(title: title, tag: tags, description: description, id: id, definition: definition, color: color, cardType: type, modifytime: modifytime)
                var locals = UserDefaults.standard.array(forKey: Constant.Key.Tags) as! [String]
                for tag in tags{
                    if !locals.contains(tag){
                        locals.append(tag)
                    }
                }
                UserDefaults.standard.set(locals, forKey: Constant.Key.Tags)
                UserDefaults.standard.synchronize()
                
                let manager = FileManager.default
                var url = Constant.Configuration.url.attributedText
                url.appendPathComponent(card.getId() + "_DEFINITION.rtf")
                if !manager.fileExists(atPath: url.path){
                    //download
                   // let opr = Cloud.downloadDefinition(id: card.getId())
                   // queue.addOperation(opr)
                   // queue.waitUntilAllOperationsAreFinished()
                }
            }else if type == "example"{
                card = ExampleCard(id: id, title: title)
                card.setDefinition(definition)
                card.updateTime(modifytime)
                let manager = FileManager.default
                var url = Constant.Configuration.url.attributedText
                url.appendPathComponent(card.getId() + ".rtf")
                if !manager.fileExists(atPath: url.path){
                    let opr = Cloud.downloadAsset(id: card.getId(), type: "TEXT")
                    queue.addOperation(opr)
                    queue.waitUntilAllOperationsAreFinished()
                }
            }else if type == "text"{
                card = TextCard(id: id)
                card.updateTime(modifytime)
                  let manager = FileManager.default
                var url = Constant.Configuration.url.attributedText
                url.appendPathComponent(card.getId() + ".rtf")
                if !manager.fileExists(atPath: url.path){
                    let opr = Cloud.downloadAsset(id: card.getId(), type: "TEXT")
                    queue.addOperation(opr)
                    queue.waitUntilAllOperationsAreFinished()
                }
            }else if type == "picture"{
                let manager = FileManager.default
                var url = Constant.Configuration.url.PicCard
                url.appendPathComponent(id + ".jpg")
                if manager.fileExists(atPath: (url.path)){
                    // manager.createDirectory(atPath: url?.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                   let image = UIImage(contentsOfFile: (url.path))
                    if image != nil{
                        card = PicCard(image!)
                    }else{
                    card = PicCard(#imageLiteral(resourceName: "icon_compass_background@2x.png"))
                    }
                }else{
                    card = PicCard(#imageLiteral(resourceName: "searchBar"))
                    let opr = Cloud.downloadAsset(id: card.getId(), type: "IMAGE")
                   
                    queue.addOperation(opr)
                    queue.waitUntilAllOperationsAreFinished()
                }
                card.setId(id)
                card.setDescription(description)
                card.updateTime(modifytime)
                
            }else if type == "voice"{
                card = VoiceCard(id: id,title:title)
                let manager = FileManager.default
                var url = Constant.Configuration.url.Audio
                url.appendPathComponent(id + ".wav")
                if !manager.fileExists(atPath:(url.path)){
                    let opr = Cloud.downloadAsset(id: card.getId(), type: "AUDIO")
                    
                    queue.addOperation(opr)
                    queue.waitUntilAllOperationsAreFinished()
                }
                /*
                User.downloadAudioUsingQCloud(cardID: id) { (bool, error) in
                    //
                }
 */
               
                let state = json["state"].stringValue
                if state == RecordManager.State.willRecord.rawValue || state == RecordManager.State.recording.rawValue{
                    (card as! VoiceCard).voiceManager?.state = RecordManager.State.willRecord
                }else{
                 (card as! VoiceCard).voiceManager?.state = RecordManager.State.haveRecord
                }
            }else if type == "movie"{
                card = MovieCard(id: id)
                let opr = Cloud.downloadAsset(id: card.getId(), type: "VIDEO")
                queue.addOperation(opr)
                queue.waitUntilAllOperationsAreFinished()
            }
            
            let subCardsArray = json["subcard"].array
            if subCardsArray != nil{
            var subcards:[Card] = [Card]()
            for subcard in subCardsArray!{
                let string = subcard.rawString()!
                let card = JSONToCard(string)
                subcards.append(card!)
            }
                card.addChildNotes(subcards)
            }
            queue.waitUntilAllOperationsAreFinished()
        return card
    }catch let error{
        print(error.localizedDescription)
        return nil
    }
    }
    
    class func CardToJSON(_ card:Card)->String?{
     var string = "{"
        string.append("\"title\":" + "\"" + card.getTitle() + "\"" + ", ")
        string.append("\"tag\":[")
        for tag in card.getTag(){
            string.append("\"" + tag + "\",")
        }
        if card.getTag().count > 0{
        string.removeLast()
        }
        string.append("],")
        string.append("\"id\":" + "\"" + card.getId() + "\"" + ", ")
        string.append("\"definition\":" + "\"" + card.getDefinition() + "\"" + ", ")
        string.append("\"description\":" + "\"" + card.getDescription() + "\"" + ", ")
        string.append("\"type\":" + "\"" + card.getType() + "\"" + ", ")
        string.append("\"time\":" + "\"" + card.getTime() + "\"")
        if card.getType() == "example"{
           //do nothing
        }else if card.getType() == "text"{
           //do nothing
        }else if card.getType() == "picture"{
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(card.getId() + ".jpg")
            let im = UIImage(named: (url?.path)!)
            if im != nil{
            (card as! PicCard).pic = im
            //User.upLoadImage(email: loggedemail, pic: (card as! PicCard))
                //User.uploadImageWithAF(email: loggedemail, image: im!, cardID: card.getId())
            }
        }else if card.getType() == "voice"{
            string.append(",")
            let voiceCard = (card as! VoiceCard)
            let state = voiceCard.voiceManager?.state.rawValue
            string.append("\"state\":" + "\"" + state! + "\"")
        }else if card.getType() == Card.CardType.movie.rawValue{
            // do nothing
        }
        else if card.getType() == Card.CardType.card.rawValue{
        string.append(",")
        //string.append("\"color\":" + card.getColor() + ", ")
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        card.getColor().getRed(&r, green: &g, blue: &b, alpha: &a)
        string.append("\"color\":" + "[\(r),\(g),\(b),\(a)]")
        }
        
        if card.ifHasChild(){
         string.append(",")
         string.append("\"subcard\":[" )
        for card in card.getChilds(){
            string.append(CardToJSON(card)!)
            string.append(",")
        }
            if card.getChilds().count > 0{
            string.removeLast()
            }
            string.append("]" )
        }
        
        string.append("}")
       // for card.getChilds()
        let filterd = filter(string)
        let json = JSON(filterd)
        if json != JSON.null{
        return json.rawString()
        }else{
        return nil
        }
     }
 
}
