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
    
    class func JSONToCard(_ json:String)->Card?{
        var card:Card!
        let json = try? JSON(data: json.data(using: String.Encoding.utf8)!)
        if json == nil{
            return nil
        }else{
            let title = json!["title"].stringValue
            let tag = json!["tag"].stringValue
            let id = json!["id"].stringValue
            let definition = json!["definition"].stringValue
            let description = json!["description"].stringValue
            let type = json!["type"].stringValue
            let colorString = json!["color"].array
            let color:UIColor = UIColor(red: CGFloat(colorString![0].float!), green: CGFloat(colorString![1].float!), blue: CGFloat(colorString![2].float!), alpha: CGFloat(colorString![3].float!))
            let modifytime = json!["time"].stringValue
            if type == "card"{
                card = Card(title: title, tag: tag, description: description, id: id, definition: definition, color: color, cardType: type, modifytime: modifytime)
            }else if type == "example"{
                let example = json!["example"].stringValue
                card = ExampleCard(example: example)
                card.updateTime(modifytime)
            }else if type == "text"{
                let text = json!["text"].stringValue
                card = TextCard(text: text)
                card.updateTime(modifytime)
            }else if type == "picture"{
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent(id + ".jpg")
                if manager.fileExists(atPath: (url?.path)!){
                    // manager.createDirectory(atPath: url?.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                   let image = UIImage(contentsOfFile: (url?.path)!)
                    if image != nil{
                        card = PicCard(image!)
                    }else{
                    card = PicCard(#imageLiteral(resourceName: "searchBar"))
                    }
                }else{
                    card = PicCard(#imageLiteral(resourceName: "searchBar"))
                    /*deprecated at May 7th
                    User.getImage(email: loggedemail, cardID: id, completionHandler: { (image) in
                        if image != nil{
                            print("get pic success")
                        }
                    })
                    */
                    User.downloadPhotosUsingQCloud(email: loggedemail, cardID: id) { (bool, error) in
                        //
                    }
                }
                card.setId(id)
                card.updateTime(modifytime)
                
            }else if type == "voice"{
                card = VoiceCard(id: id)
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent("audio")
                url?.appendPathComponent(id + ".wav")
                if !manager.fileExists(atPath:(url?.path)!){
                    /* deprecated at May.7th
                User.getAudio(email: loggedemail, cardID: id, completionHandler: { (path) in
                    print("get audio success")
                })
                    */
                }
                User.downloadAudioUsingQCloud(email: loggedemail, cardID: id) { (bool, error) in
                    //
                }
                let state = json!["state"].stringValue
                if state == RecordManager.State.willRecord.rawValue || state == RecordManager.State.recording.rawValue{
                    (card as! VoiceCard).voiceManager?.state = RecordManager.State.willRecord
                }else{
                 (card as! VoiceCard).voiceManager?.state = RecordManager.State.haveRecord
                }
            }else if type == "map"{
                card = MapCard(id: id, formalAddress: json!["formalAddress"].stringValue, neighbourAddress: json!["neighbourAddress"].stringValue, longitude: CGFloat(json!["longitude"].floatValue), latitude: CGFloat(json!["latitude"].floatValue))
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent("mapPic")
                try? manager.createDirectory(atPath: (url?.path)!, withIntermediateDirectories: true, attributes: nil)
                url?.appendPathComponent(id + ".jpg")
                if !manager.fileExists(atPath:(url?.path)!){
                    /* deprecated at May.7th
                    User.getImage(email: loggedemail, cardID: id, completionHandler: { (image) in
                        if image != nil{
                        let imageData = UIImageJPEGRepresentation(image!, 0.5)
                            do{ try imageData?.write(to:url!)
                            }catch let err{
                               print(err.localizedDescription)
                            }
                            
                            print("get map Success")
                            print(manager.fileExists(atPath:(url?.path)!))
                        }else{
                             print("get map fail")
                        }
                        
                    })
                  */
                    User.downloadMapUsingQCloud(email: loggedemail, cardID: id) { (bool, error) in
                        if error != nil{
                            //
                        }
                    }
                }
            }
            
            
            
            let subCardsArray = json?["subcard"].array
            if subCardsArray != nil{
            var subcards:[Card] = [Card]()
            for subcard in subCardsArray!{
                let card = JSONToCard(subcard.rawString()!)
                subcards.append(card!)
            }
                card.addChildNotes(subcards)
            }
            
    }
        return card
    }
    
    class func CardToJSON(_ card:Card)->String{
     var string = "{"
        string.append("\"title\":" + "\"" + card.getTitle() + "\"" + ", ")
        string.append("\"tag\":" + "\"" + card.getTag() +  "\"" + ", ")
        string.append("\"id\":" + "\"" + card.getId() + "\"" + ", ")
        string.append("\"definition\":" + "\"" + card.getDefinition() + "\"" + ", ")
        string.append("\"description\":" + "\"" + card.getDescription() + "\"" + ", ")
        string.append("\"type\":" + "\"" + card.getType() + "\"" + ", ")
        string.append("\"time\":" + "\"" + card.getTime() + "\"" + ", ")
        if card.getType() == "example"{
            string.append("\"example\":" + "\"" + (card as! ExampleCard).getExample() + "\"" + ", ")
        }else if card.getType() == "text"{
            string.append("\"text\":" + "\"" + (card as! TextCard).getText() + "\"" + ", ")
        }else if card.getType() == "picture"{
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent(card.getId() + ".jpg")
            let im = UIImage(named: (url?.path)!)
            if im != nil{
            (card as! PicCard).pic = im
            //User.upLoadImage(email: loggedemail, pic: (card as! PicCard))
                //User.uploadImageWithAF(email: loggedemail, image: im!, cardID: card.getId())
            }
        }else if card.getType() == "voice"{
            let voiceCard = (card as! VoiceCard)
            let state = voiceCard.voiceManager?.state.rawValue
            string.append("\"state\":" + "\"" + state! + "\"" + ", ")
        }else if card.getType() == "map"{
            let mapCard = (card as! MapCard)
            string.append("\"formalAddress\":" + "\"" + mapCard.formalAddress + "\"" + ", ")
            string.append("\"neighbourAddress\":" + "\"" + mapCard.neibourAddress + "\"" + ", ")
            string.append("\"longitude\":" + "\"" + "\(mapCard.longitude!)" + "\"" + ", ")
            string.append("\"latitude\":" + "\"" + "\(mapCard.latitude!)" + "\"" + ", ")
        }
        //string.append("\"color\":" + card.getColor() + ", ")
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(0)
        card.getColor().getRed(&r, green: &g, blue: &b, alpha: &a)
        string.append("\"color\":" + "[\(r),\(g),\(b),\(a)]" + "")
        if card.ifHasChild(){
         string.append(",")
         string.append("\"subcard\":[" )
        for card in card.getChilds(){
            string.append(CardToJSON(card))
            string.append(",")
        }
            string.removeLast()
            string.append("]" )
        }
        
        string.append("}")
       // for card.getChilds()
        return string
     }
 
}
