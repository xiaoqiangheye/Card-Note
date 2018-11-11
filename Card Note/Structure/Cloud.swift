//
//  Cloud.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/12.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import CloudKit


let myContainer = CKContainer.default()
//2、创建数据库
let database = myContainer.publicCloudDatabase
class Cloud{
    
    
    class func getTerms(completionHandler:@escaping (String?)->()){
        let query = CKQuery(recordType:"Terms" , predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil{
                print("Error querying terms" + (error?.localizedDescription)!)
                completionHandler(nil)
            }else{
                if(records != nil && !(records?.isEmpty)!){
                    completionHandler(records![0]["content"] as! String)
                }
            }
        }
    }
    
    class func addCard(card:Card,completionHandler:@escaping (Bool)->()){
        let cardRecord = CKRecord.init(recordType: "Card", recordID: CKRecordID.init(recordName: card.getId()))
        
        cardRecord["cardID"] = card.getId()
        
        
        let string = CardParser.CardToJSON(card)
        if string != nil{
            cardRecord["content"] = string
        }
        creatRecord(record: cardRecord) { (bool) in
            completionHandler(bool)
        }
    }
    
    class func addCards(cards:[Card],completionHandler:@escaping (Bool)->()){
        var ifTrue = true
        var times = 0
        for card in cards{
            addCard(card: card) { (bool) in
                if !bool{
                    completionHandler(false)
                    ifTrue = false
                }
                if times == cards.count && ifTrue == true{
                    completionHandler(true)
                }
                times += 1
            }
        }
        
    }
    
    
    class func updateCard(card:Card,completionHandler:@escaping (Bool)->()){
        database.fetch(withRecordID: CKRecordID.init(recordName: card.getId()), completionHandler: { record, error in
            if error != nil{
            print("error fetch card" + (error?.localizedDescription)!)
            //add Card Again
            addCard(card: card, completionHandler: { (bool) in
                    completionHandler(bool)
                    return
                })
            }else{
    // Modify the record
                record!["cardID"] = card.getId()
                let string = CardParser.CardToJSON(card)
                if string != nil{
                record!["content"] = string
                }
             creatRecord(record: record!, completionHandler: { (bool) in
                    completionHandler(bool)
                })
    }
    })
   
    }
    
    class func updateCards(cards:[Card],completionHandler:@escaping (Bool)->()){
        var successArray = [Int]()
        for card in cards{
        database.fetch(withRecordID: CKRecordID.init(recordName: card.getId()), completionHandler: { record, error in
            if error != nil{
                print("error fetch card" + (error?.localizedDescription)!)
                //add Card Again
                addCard(card: card, completionHandler: { (bool) in
                    completionHandler(bool)
                    return
                })
            }else{
                // Modify the record
                    record!["cardID"] = card.getId()
                    let string = CardParser.CardToJSON(card)
                    if string != nil{
                        record!["content"] = string
                    }
                    
                    creatRecord(record: record!, completionHandler: { (bool) in
                        if !bool{
                            completionHandler(bool)
                            successArray.append(0);
                            return
                        }else{
                            successArray.append(1);
                        }
                        
                        if successArray.count == cards.count{
                            completionHandler(true)
                        }
                    })
                
            }
        })
            
        }
    }
    
  
    
    class func creatRecord(record:CKRecord,completionHandler:@escaping (Bool)->()) {
        //将记录保存在数据库
        database.save(record) { (record, error) in
            if (error != nil) {
                print("creatRecord failure！" + (error?.localizedDescription)!)
                completionHandler(false)
            } else {
                print("creatRecord success！")
                completionHandler(true)
            }
        }
    }
    
    class func deleteRecordData(id:String,completionHandler:@escaping (Bool)->()) {
        //将记录保存在数据库
        database.delete(withRecordID: CKRecordID.init(recordName: id)) { (artworkRecord, error) in
            if (error != nil) {
                print("deleteRecord failure！" + (error?.localizedDescription)!)
                completionHandler(false)
            } else {
                print("deleteRecord success！")
                completionHandler(true)
            }
        }
        
    }
    
    class func fetchCard(id:String){
        //在代码中获取我们保存好的内容
        database.fetch(withRecordID: CKRecordID.init(recordName: id)) { (card, error) in
            if (error != nil) {
                print("selectData failure！" + (error?.localizedDescription)!)
            } else {
                print("selectData success！")
            }
        }
    }
    
    class func queryAllCard(completionhandler:@escaping ([Card])->()){
        let query = CKQuery(recordType:"Card" , predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil{
              print("Error querying the cards." + (error?.localizedDescription)!)
                
                let cardArray = [Card]()
                completionhandler(cardArray)
            }else{
                var cardArray = [Card]()
                for record in records!{
                    print(record["content"]!)
                    if let card = CardParser.JSONToCard(record["content"]!){
                        cardArray.append(card)
                    }
                }
                completionhandler(cardArray)
            }
        }
    }
    
    
    class private func queryAssets(query:CKQuery,completionHandler:@escaping (Bool,Error?)->()){
        database.perform(query, inZoneWith: nil) { (records, error) in
            if (error == nil){
                if(records != nil){
                    for record in records!{
                        if let asset = record["file"] as? CKAsset{
                            let type = record["type"] as! String
                            do{
                                let data = try Data(contentsOf: asset.fileURL)
                                switch type{
                                case "IMAGE":
                                    try data.write(to: Constant.Configuration.url.PicCard.appendingPathComponent(record.recordID.recordName + ".jpg"))
                                    break
                                case "VIDEO":
                                    try data.write(to: Constant.Configuration.url.Movie.appendingPathComponent(record.recordID.recordName + ".mov"))
                                    break
                                case "AUDIO":
                                    try data.write(to: Constant.Configuration.url.Audio.appendingPathComponent(record.recordID.recordName + ".wav"))
                                    break
                                case "TEXT":
                                    try data.write(to: Constant.Configuration.url.attributedText.appendingPathComponent(record.recordID.recordName + ".rtf"))
                                    break
                                default:
                                    break
                                }
                            }catch{
                                
                            }
                        }
                        
                    }
                    completionHandler(true,nil)
                }
                    completionHandler(false,error)
            }else{
                    completionHandler(false,error)
            }
        }
    }
    
    class func downloadAsset(id:String,type:String,completionHandler:@escaping (Bool,Error?)->()){
        let reference = CKReference(recordID: CKRecordID(recordName: id), action: CKReferenceAction.none)
        let query = CKQuery(recordType: "ASSET", predicate: NSPredicate(format: "recordID = %@ AND type = %@", reference,type))
        queryAssets(query: query,completionHandler:completionHandler)
    }
    
    class func downloadAllAsset(completionHandler:@escaping (Bool,Error?)->()){
        let query = CKQuery(recordType: "ASSET", predicate: NSPredicate(value: true))
        queryAssets(query: query,completionHandler:completionHandler)
    }
    
    class private func upload(url:URL,type:String,id:String,completionHandler:@escaping (Bool,Error?)->()){
        let cardRecord = CKRecord.init(recordType: "ASSET", recordID: CKRecordID.init(recordName: id))
        cardRecord["file"] = CKAsset(fileURL: url)
        cardRecord["type"] = type
        creatRecord(record: cardRecord) { (bool) in
            if bool{
                completionHandler(true,nil)
               
            }else{
                completionHandler(false,nil)
            }
            
        }
        
    }
    
    class func upload(image url:URL,id:String,completionHandler:@escaping (Bool,Error?)->()){
        upload(url: url, type: "IMAGE",id:id,completionHandler:completionHandler)
    }
    
    class func upload(video url:URL,id:String,completionHandler:@escaping (Bool,Error?)->()){
        upload(url: url, type: "VIDEO",id:id,completionHandler:completionHandler)
    }
    
    class func upload(audio url:URL,id:String,completionHandler:@escaping (Bool,Error?)->()){
        upload(url: url, type: "AUDIO",id:id,completionHandler:completionHandler)
    }
    
    class func upload(text url:URL,id:String,completionHandler:@escaping (Bool,Error?)->()){
        upload(url:url,type:"TEXT",id:id,completionHandler:completionHandler)
    }
}
