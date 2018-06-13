//
//  Card.swift
//  Card Note
//
//  Created by 强巍 on 2018/3/28.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class Card:NSObject,NSCoding{
    private var id:String
    private var title:String
    private var tag:String
    private var descriptions:String
    private var childCards  = [Card]()
    private var parentCard:Card?
    private var definition:String
    private var type:String
    private var modifyTime:String
    //private var examples:[String]
    public var color:UIColor?
    
    enum CardType:String{
        case card = "card"
        case map = "map"
        case example = "example"
        case picture = "picture"
        case text = "text"
        case movie = "movie"
        case orderedList = "OrderedList"
        case nonorderedList = "nonOrderedList"
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
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.tag = aDecoder.decodeObject(forKey: "tag") as! String
        self.definition = aDecoder.decodeObject(forKey: "definition") as! String
        self.descriptions = aDecoder.decodeObject(forKey: "description") as! String
        self.parentCard = aDecoder.decodeObject(forKey: "parentCard") as? Card
        self.childCards = aDecoder.decodeObject(forKey: "childCards") as! [Card]
        self.color = aDecoder.decodeObject(forKey: "color") as? UIColor
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.type = aDecoder.decodeObject(forKey: "type") as! String
        self.modifyTime = aDecoder.decodeObject(forKey: "modifytime") as! String
       // self.type = aDecoder.decodeObject(forKey: "type") as! CardType
        //self.examples = aDecoder.decodeObject(forKey: "examples") as! [String]
    }
    
    
    init(title:String,tag:String,description:String,id:String,definition:String,color:UIColor?, cardType:String, modifytime:String) {
        self.title = title
        self.tag = tag
        self.descriptions = description
        self.id = id
        self.definition = definition
       // self.examples = examples
        self.color = color
        self.type = cardType
        self.modifyTime = modifytime
    }
    
    func setTag(_ tag:String){self.tag = tag}
    func getTag()->String{return tag}
    func setId(_ id:String){
        self.id = id
    }
    func getTitle()->String{return title}
    func setTitle(_ title:String){self.title = title}
    func getDescription()->String{return descriptions}
    func setDescription(_ des:String){self.descriptions = des}
    func setChilds(_ childs:[Card]){self.childCards = childs}
    func getChilds()->[Card]{return childCards}
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
    
    func addExample(_ string:String){
        self.childCards.append(ExampleCard(example: string))
    }
    
   
    
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


