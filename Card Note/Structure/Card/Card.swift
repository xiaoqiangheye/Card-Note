//
//  Card.swift
//  Card Note
//
//  Created by 强巍 on 2018/3/28.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class Card:NSObject,NSCoding,Encodable{
    private var id:String
    private var title:String
    private var tag:[String]
    private var descriptions:String
    private var childCards = [Card]()
    private var parentCard:Card?
    private var definition:String
    private var type:String
    private var modifyTime:String
    private var _color:[CGFloat]

   
    
    //private var examples:[String]
    var color:UIColor?{
        set{
            if newValue != nil{
                var a:CGFloat = 0
                var b:CGFloat = 0
                var r:CGFloat = 0
                var g:CGFloat = 0
                newValue?.getRed(&r, green: &g, blue: &b, alpha: &a)
                _color = [r,g,b,a]
            }else{
                _color = [CGFloat]()
            }
        }
        
        get{
            if _color.count == 0{
                return Constant.Color.blueLeft
            }else{
                return UIColor(red: (_color[0]), green:(_color[1]), blue: (_color[2]), alpha: (_color[3]))
            }
        }
    }
    
    enum CardType:String{
        case card = "card"
        case map = "map"
        case example = "example"
        case picture = "picture"
        case text = "text"
        case movie = "movie"
        case plain = "plain"
        case voice = "voice"
    }
    
    private enum CodingKeys:String,CodingKey{
        case id = "id"
        case title = "title"
        case tag = "tag"
        case descriptions = "description"
        case childCards = "subcard"
        case definition = "definition"
        case type = "type"
        case modifyTime = "time"
        case color = "color"
    }
    
    func getType()->String{
        return type
    }
    
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(descriptions, forKey: .descriptions)
            try container.encode(definition, forKey: .definition)
            try container.encode(_color, forKey: .color)
            try container.encode(id,forKey:.id)
            try container.encode(childCards,forKey:.childCards)
            try container.encode(tag,forKey:.tag)
            try container.encode(modifyTime,forKey:.modifyTime)
            try container.encode(type,forKey:.type)
    }
    
    func encode(with aCoder: NSCoder) {
         aCoder.encode(tag, forKey: "tag")
         aCoder.encode(id, forKey: "id")
         aCoder.encode(descriptions, forKey: "description")
         aCoder.encode(definition, forKey: "definition")
         aCoder.encode(color, forKey: "color")
        //aCoder.encode(parentCard, forKey: "parentCard")
         aCoder.encode(childCards, forKey: "childCards")
         aCoder.encode(title, forKey: "title")
         aCoder.encode(type, forKey: "type")
         aCoder.encode(modifyTime, forKey: "modifytime")
        //aCoder.encode(examples, forKey: "examples")
    }
    
    
   
    
    
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.tag = aDecoder.decodeObject(forKey: "tag") as! [String]
        self.definition = aDecoder.decodeObject(forKey: "definition") as! String
        self.descriptions = aDecoder.decodeObject(forKey: "description") as! String
        self.parentCard = aDecoder.decodeObject(forKey: "parentCard") as? Card
        self.childCards = aDecoder.decodeObject(forKey: "childCards") as! [Card]
        let color = aDecoder.decodeObject(forKey: "color") as? UIColor
        if color != nil{
            var a:CGFloat = 0
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            color?.getRed(&r, green: &g, blue: &b, alpha: &a)
            _color = [r,g,b,a]
        }else{
            _color = [CGFloat]()
        }
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.type = aDecoder.decodeObject(forKey: "type") as! String
        self.modifyTime = aDecoder.decodeObject(forKey: "modifytime") as! String
       // self.type = aDecoder.decodeObject(forKey: "type") as! CardType
        //self.examples = aDecoder.decodeObject(forKey: "examples") as! [String]
    }
    
    
    init(title:String,tag:[String]?,description:String,id:String,definition:String,color:UIColor?, cardType:String, modifytime:String) {
        self.title = title
        self.tag = tag != nil ? tag! : [String]()
        self.descriptions = description
        self.id = id
        self.definition = definition
       // self.examples = examples
       // self.color = color
        var a:CGFloat = 0
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        color?.getRed(&r, green: &g, blue: &b, alpha: &a)
        _color = [r,g,b,a]
        self.type = cardType
        self.modifyTime = modifytime
    }
    
    func getText()->NSAttributedString?{
        var url = Constant.Configuration.url.attributedText
        url.appendPathComponent(self.getId() + ".rtf")
        do{
            let data = try Data(contentsOf: url)
            var ducumentAttribute:NSDictionary?
            let attr = try NSAttributedString(data: data, options: [ NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.rtf], documentAttributes: &ducumentAttribute)
            return attr
        }catch let error{
            print(error.localizedDescription)
            return nil
        }
    }
    
    func setText(attr:NSAttributedString){
        var url = Constant.Configuration.url.attributedText
        url.appendPathComponent(self.getId() + ".rtf")
        let range = NSRange(location: 0, length: attr.length)
        do{
            let data = try attr.data(from: range, documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf])
            try data.write(to: url)
        }catch let error{
            print(error.localizedDescription)
        }
        
    }
    
    
    func setTag(_ tag:[String]){
        let tags = UserDefaults.standard.array(forKey: Constant.Key.Tags) as! [String]
        var new = [String]()
        for t in tags{
            if tag.contains(t){
                new.append(t)
            }
        }
        self.tag = new
    }
    
    func getTag()->[String]{
        let tags = UserDefaults.standard.array(forKey: Constant.Key.Tags) as! [String]
        var new = [String]()
        for tag in tags{
            if self.tag.contains(tag){
            new.append(tag)
            }
        }
        return new
    }
    func setId(_ id:String){
        self.id = id
    }
    func getTitle()->String{return title}
    func setTitle(_ title:String){self.title = title}
    func getDescription()->String{return descriptions}
    func setDescription(_ des:String){self.descriptions = des}
    func setChilds(_ childs:[Card]){
        for child in childs{
            child.parentCard = self
        }
         self.childCards = childs
    }
    func getChilds()->[Card]{return childCards}
    func getChild(by id:String)->Card?{
        for child in childCards
        {
            if child.getId() == id{
                return child
            }
        }
        return nil
    }
    func getParentCard()->Card{return parentCard!}
    
    func getId()->String{return id}
    
    func getDefinition()->String{return definition}
    func setDefinition(_ def:String){self.definition = def}
    
    func setColor(_ color:UIColor){self.color = color}
    func getColor()->UIColor{return color!}
    func removeChild(at:Int){childCards.remove(at: at)}
    
    func removeChild(byId:String){
        var index = 0
        for child in childCards{
            if child.id == byId{
               childCards.remove(at: index)
            }
            index+=1
        }
    }
    func getTime()->String{
        return modifyTime
    }
    func updateTime(_ time:String){
        self.modifyTime = time
    }
    /*
    func getExamples()->[String]{
        return examples
    }
    func setExamples(_ examples:[String]){
        self.examples = examples
    }
    */
    
    
    
   
    
    func addChildNote(_ child:Card){
    child.parentCard = self
    childCards.append(child)
    }
    
    func addChildNotes(_ childs:[Card]){
    for child in childs{
        child.parentCard = self
    }
    childCards.append(contentsOf: childs)
    }
    
    func ifHasChild()->Bool{
        return !self.childCards.isEmpty
    }
    
    
}


