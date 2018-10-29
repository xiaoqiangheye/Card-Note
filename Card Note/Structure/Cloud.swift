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
    class func addCard(card:Card,completionHandler:@escaping (Bool)->()){
        let cardRecord = CKRecord.init(recordType: "Card", recordID: CKRecordID.init(recordName: card.getId()))
        if card.getId() != cardRecord["cardID"]{
        cardRecord["cardID"] = card.getId()
        }
        
        let string = CardParser.CardToJSON(card)
        if string != nil{
            cardRecord["content"] = string
        }
        creatRecord(record: cardRecord) { (bool) in
            completionHandler(bool)
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
    
    
}
