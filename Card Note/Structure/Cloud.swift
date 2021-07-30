//
//  Cloud.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/12.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import CloudKit
import SCLAlertView
import Alamofire

let myContainer = CKContainer.init(identifier: "iCloud.com.wei.cardnote")
let database = myContainer.privateCloudDatabase
let publicData = myContainer.publicCloudDatabase

class Cloud{
    
    class func service(completionHandler:@escaping  (Bool?)->()){
        let query = CKQuery(recordType:"Terms" , predicate: NSPredicate(value: true))
        publicData.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil{
                print("Error Initizing Service" + (error?.localizedDescription)!)
                completionHandler(true)
            }else{
                if(records != nil && !(records?.isEmpty)!){
                    if records![0]["content"] == "0"{
                       completionHandler(false)
                    }else{
                        completionHandler(true)
                    }
                }
            }
        }
    }
    class func getTerms(completionHandler:@escaping (String?)->()){
        let query = CKQuery(recordType:"Terms" , predicate: NSPredicate(value: true))
        publicData.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil{
                print("Error querying terms" + (error?.localizedDescription)!)
                completionHandler(nil)
            }else{
                if(records != nil && !(records?.isEmpty)!){
                    completionHandler(records![0]["content"])
                }
            }
        }
    }
    
    class func addCard(card:Card,completionHandler:@escaping (Bool)->()){
        let cardRecord = CKRecord.init(recordType: "Card", recordID: CKRecord.ID.init(recordName: card.getId()))
        
        cardRecord["cardID"] = card.getId()
        
        let url = Constant.Configuration.url.Card.appendingPathComponent(card.getId() + ".card")
        cardRecord["data"] = CKAsset(fileURL: url)
        creatRecord(record: cardRecord) { (bool) in
            completionHandler(bool)
        }
    }
    
    class func addCards(cards:[Card],completionHandler:@escaping (Bool)->()){
        var array = [Bool]()
        for card in cards{
            addCard(card: card) { (bool) in
                array.append(bool)
            }
        }
        
        while(array.count != cards.count){
            if(array.contains(false)){
                completionHandler(false)
                break
            }
        }
        
        completionHandler(true)
        
    }
    
    
    class func updateCard(card:Card,completionHandler:@escaping (Bool)->()){
        database.fetch(withRecordID: CKRecord.ID.init(recordName: card.getId()), completionHandler: { record, error in
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
                
                var url = Constant.Configuration.url.Card
                url.appendPathComponent(card.getId() + ".card")
                record!["data"] = CKAsset(fileURL: url)
                creatRecord(record: record!, completionHandler: { (bool) in
                    completionHandler(bool)
                })
    }
    })
   
    }
    
    class func updateCards(cards:[Card],completionHandler:@escaping (Bool)->()){
            var successArray = [Int]()
            for card in cards{
                database.fetch(withRecordID: CKRecord.ID.init(recordName: card.getId()), completionHandler: { record, error in
                    if error != nil{
                        print("error fetch card" + (error?.localizedDescription)!)
                        //add Card Again
                        addCard(card: card, completionHandler: { (bool) in
                            successArray.append(0)
                        })
                    }else{
                        // Modify the record
                        record!["cardID"] = card.getId()
                        var url = Constant.Configuration.url.Card
                        url.appendPathComponent(card.getId() + ".card")
                        record!["data"] = CKAsset(fileURL: url)
                        
                        creatRecord(record: record!, completionHandler: { (bool) in
                            if !bool{                                                                                             
                                completionHandler(bool)
                                successArray.append(0);
                                return
                            }else{
                                successArray.append(1);
                            }
                            
                            if successArray.count == cards.count && !successArray.contains(0){
                                completionHandler(true)
                            }else if(successArray.count == cards.count){
                                completionHandler(false)
                            }
                        })
                    }
                })
                
                
            }
        
        
        
    }
    

    class func creatRecord(record:CKRecord,completionHandler:@escaping (Bool)->()) {
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
        //delete the main card task
        
        do{
            let url = Constant.Configuration.url.Card.appendingPathComponent(id + ".card")
            let card = NSKeyedUnarchiver.unarchiveObject(with: try Data.init(contentsOf: url)) as! Card
            database.delete(withRecordID: CKRecord.ID.init(recordName: id)) { (artworkRecord, error) in
                if (error != nil) {
                    print("deleteRecord failure！" + (error?.localizedDescription)!)
                    completionHandler(false)
                } else {
                    print("deleteRecord success！")
                    completionHandler(true)
                }
            }
        }catch(let e){
            print(e.localizedDescription)
            AlertView.show(alert: "Failed.")
        }
        //delete the child card and asset
    }
    
    class func deleteAllRecordData(completion:@escaping (Bool)->()){
        database.delete(withRecordZoneID: .default) { (id, error) in
            if (error != nil){
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    class func fetchCard(id:String){
        database.fetch(withRecordID: CKRecord.ID.init(recordName: id)) { (card, error) in
            if (error != nil) {
                print("selectData failure！" + (error?.localizedDescription)!)
            } else {
                print("selectData success！")
            }
        }
    }
    
    class func queryTags(completionHandler:@escaping (Set<String>?)->()){
        let query = CKQuery(recordType: "Tag", predicate: NSPredicate(value:true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil{
                completionHandler(nil)
            }else{
                var tagSet = Set<String>()
                for record in records!{
                    tagSet.insert(record.recordID.recordName)
                }
                completionHandler(tagSet)
            }
        }
    }
    
    
    //TODO: should return optional type
    class func queryAllCard(completionhandler:@escaping ([Card])->()){
        let query = CKQuery(recordType:"Card" , predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: .default) { (records, error) in
            if error != nil{
                print("Error querying the cards." + (error?.localizedDescription)!)
                let cardArray = [Card]()
                completionhandler(cardArray)
            }else{
                var cardArray = [Card]()
                for record in records!{
                    let cardData = record["data"]! as! CKAsset
                    do{
                        let data = try Data(contentsOf: cardData.fileURL)
                        let card = NSKeyedUnarchiver.unarchiveObject(with: data) as? Card
                        if card != nil{
                            cardArray.append(card!)
                        }else{
                            deleteRecordData(id: record.recordID.recordName, completionHandler: { (bool) in
                                
                            })
                        }
                    }catch{
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
                }else{
                    completionHandler(false,error)
                }
            }else{
                    completionHandler(false,error)
            }
        }
    }
    
    class func downloadAsset(id:String,type:String,completionHandler:@escaping (Bool,Error?)->()){
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: id), action: .none)
      
        let query = CKQuery(recordType: "ASSET", predicate: NSPredicate(format: "recordID = %@ AND type = %@", reference,type))
        queryAssets(query: query,completionHandler:completionHandler)
    }
    
    class func downloadAsset(id:String,type:String)->CKQueryOperation{
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: id), action:.none )
        let query = CKQuery(recordType: "ASSET", predicate: NSPredicate(format: "recordID = %@ AND type = %@", reference,type))
        return downloadOperation(query: query)
    }
    
    class func downloadAllAsset(completionHandler:@escaping (Bool,Error?)->()){
        let query = CKQuery(recordType: "ASSET", predicate: NSPredicate(value: true))
        queryAssets(query: query,completionHandler:completionHandler)
    }
    
   
    
    class func downloadOperation(query:CKQuery)->CKQueryOperation{
        let opr = CKQueryOperation(query: query)
        return opr
    }
    
   
    
    class private func upload(url:URL,type:String,id:String,parentID:String, completionHandler:@escaping (Bool,Error?)->()){
        database.fetch(withRecordID: CKRecord.ID.init(recordName: id)) { (record, error) in
            if(record != nil){
                record!["file"] = CKAsset(fileURL: url)
                creatRecord(record: record!, completionHandler: { (bool) in
                    completionHandler(bool,nil);
                })
            }else{
                let cardRecord = CKRecord.init(recordType: "ASSET", recordID: CKRecord.ID.init(recordName: id))
                cardRecord["file"] = CKAsset(fileURL: url)
                cardRecord["type"] = type
                cardRecord["parent"] = CKReference(recordID: CKRecord.ID.init(recordName: parentID), action: .deleteSelf)
                creatRecord(record: cardRecord) { (bool) in
                    completionHandler(bool,nil)
                }
            }
        }
    }
    
    class func upload(image url:URL,id:String,parentID:String, completionHandler:@escaping (Bool,Error?)->()){
        upload(url: url, type: "IMAGE",id:id,parentID:parentID,completionHandler:completionHandler)
    }
    
    class func upload(video url:URL,id:String,parentID:String, completionHandler:@escaping (Bool,Error?)->()){
        upload(url: url, type: "VIDEO",id:id,parentID:parentID,completionHandler:completionHandler)
    }
    
    class func upload(audio url:URL,id:String,parentID:String, completionHandler:@escaping (Bool,Error?)->()){
        upload(url: url, type: "AUDIO",id:id,parentID:parentID,completionHandler:completionHandler)
    }
    
    class func upload(text url:URL,id:String,parentID:String, completionHandler:@escaping (Bool,Error?)->()){
        upload(url:url,type:"TEXT",id:id,parentID:parentID,completionHandler:completionHandler)
    }
    
    class func createTag(tag:String,completionHandler:@escaping (Bool,Error?)->()){
        let tag = CKRecord(recordType: "Tag", recordID: CKRecord.ID.init(recordName: tag))
        creatRecord(record: tag) { (bool) in
            completionHandler(bool,nil)
        }
    }
    
    class func modifyTag(tag:String, with:String,completionHandler:@escaping (Bool,Error?)->()){
        deleteRecordData(id: tag) { (bool) in
            if bool{
                let new = CKRecord(recordType: "Tag", recordID: CKRecord.ID.init(recordName: with))
                creatRecord(record: new, completionHandler: { (bool) in
                    completionHandler(bool,nil)
                })
            }else{
                completionHandler(false,nil)
            }
        }
    }
    
    class func deleteTag(tag:String, completionHandler:@escaping (Bool, Error?)->()){
        database.delete(withRecordID: CKRecord.ID.init(recordName: tag)) { id, error in
            if(error == nil){
                completionHandler(true, nil)
            } else{
                completionHandler(false, error)
            }
        }
    }
    
    class func queryRestRecognition(completionHandler:@escaping (Int?)->()){
        let query = CKQuery(recordType: "num_recognition", predicate: NSPredicate(value:true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil{
                completionHandler(nil)
            }else{
                if records!.count >= 0{
                    completionHandler(records![0]["num"])
                } else {
                    //add record to query
                    setRecognitionNum { bool in }
                    completionHandler(nil)
                }
            }
        }
    }
    
    class func setRecognitionNum(completionHandler:@escaping (Bool)->()){
        let num = CKRecord(recordType: "num_recognition", recordID: CKRecord.ID.init(recordName: "num_recognition"))
        num["num"] = 10
        creatRecord(record: num) { (bool) in
            completionHandler(bool)
        }
    }

}
