//
//  Card.swift
//  Card Note
//
//  Created by 强巍 on 2018/3/28.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class Card:NSObject,NSCoding,Codable{
    private var id:String
    private var title:String
    private var tag:[String]
    private var descriptions:String
    private var childCards  = [Card]()
    private var parentCard:Card?
    private var definition:String
    private var type:String
    private var modifyTime:String
    private var _color:Color?

    struct Color:Codable{
        var a:CGFloat
        var r:CGFloat
        var g:CGFloat
        var b:CGFloat
        enum CodingKeys:String,CodingKey{
            case a
            case r
            case g
            case b
        }
    }
    
    //private var examples:[String]
      var color:UIColor?{
        set{
            if newValue != nil{
                var a:CGFloat = 0
                var b:CGFloat = 0
                var r:CGFloat = 0
                var g:CGFloat = 0
                newValue?.getRed(&r, green: &g, blue: &b, alpha: &a)
                _color = Color(a: a, r: r, g: g, b: b)
            }else{
                _color = nil
            }
        }
        
        get{
            if _color == nil{
                return nil
            }else{
                return UIColor(red: (_color?.r)!, green:(_color?.g)!, blue: (_color?.b)!, alpha: (_color?.a)!)
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
        case id
        case title
        case tag
        case descriptions = "description"
        case childCards = "subcards"
        case parentCard = "parentcard"
        case definition = "definition"
        case type
        case modifyTime = "time"
        case color
    }
    
    func getType()->String{
        return type
    }
    
    func encode(with aCoder: NSCoder) {
         aCoder.encode(tag, forKey: "tag")
         aCoder.encode(id, forKey: "id")
         aCoder.encode(descriptions, forKey: "description")
         aCoder.encode(definition, forKey: "definition")
         aCoder.encode(color, forKey: "color")
         aCoder.encode(parentCard, forKey: "parentCard")
         aCoder.encode(childCards, forKey: "childCards")
         aCoder.encode(title, forKey: "title")
         aCoder.encode(type, forKey: "type")
         aCoder.encode(modifyTime, forKey: "modifytime")
        // aCoder.encode(examples, forKey: "examples")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do{
        try container.encode(title, forKey: .title)
        try container.encode(descriptions, forKey: .descriptions)
        try container.encode(definition, forKey: .definition)
        try container.encodeIfPresent(_color, forKey: .color)
        try container.encode(id,forKey:.id)
        try container.encodeIfPresent(parentCard, forKey: .parentCard)
        try container.encode(childCards,forKey:.childCards)
        try container.encode(tag,forKey:.tag)
        try container.encode(modifyTime,forKey:.modifyTime)
        try container.encode(type,forKey:.type)
        }catch let e{
            print(e.localizedDescription)
        }
    }
    
    required init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           id = try container.decode(String.self,forKey:.id)
           title = try container.decode(String.self, forKey: .title)
           descriptions = try container.decode(String.self, forKey: .descriptions)
           definition = try container.decode(String.self,forKey:.definition)
           _color = try container.decodeIfPresent(Color.self, forKey: .color)
           childCards = try container.decode([Card].self, forKey: .childCards)
           parentCard = try container.decodeIfPresent(Card.self, forKey: .parentCard)
           tag = try container.decode([String].self,forKey:.tag)
           type = try container.decode(String.self,forKey:.tag)
           modifyTime = try container.decode(String.self,forKey:.tag)
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
            _color = Color(a: a, r: r, g: g, b: b)
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
        let color = color?.getRed(&r, green: &g, blue: &b, alpha: &a)
        _color = Color(a: a, r: r, g: g, b: b)
        self.type = cardType
        self.modifyTime = modifytime
    }
    
    func setTag(_ tag:[String]){self.tag = tag}
    func getTag()->[String]{return tag}
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


