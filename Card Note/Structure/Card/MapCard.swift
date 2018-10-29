//
//  MapCard.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/22.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import MapboxGeocoder
class MapCard:Card{
    var poi:AMapPOI?
    var formalAddress:String
    var neibourAddress:String
    internal var latitude:CGFloat?
    internal var longitude:CGFloat?
    internal var imagePath:String?
    
    
    private enum CodingKeys:String,CodingKey{
        case formalAddress
        case neibourAddress
        case latitude
        case longitude
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy:CodingKeys.self)
        try container.encode(formalAddress, forKey: MapCard.CodingKeys.formalAddress)
        try container.encode(neibourAddress, forKey: .neibourAddress)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    
        
    }
    
   
    init(poi:AMapPOI?,formalAddress:String,id:String) {
        self.poi = poi
        if poi == nil{
            neibourAddress = formalAddress
        }else{
            neibourAddress = (poi?.name)!
        }
        
        self.formalAddress = formalAddress
        self.latitude = poi?.location.latitude
        self.longitude = poi?.location.longitude
        var url = Constant.Configuration.url.Map
        url.appendPathComponent(id + ".jpg")
        self.imagePath = (url.path)
        super.init(title: "", tag: nil, description: "", id: id, definition: "", color: .white, cardType: "map", modifytime: "")
    }
    
    init(id:String, formalAddress:String, neighbourAddress:String,longitude:CGFloat, latitude:CGFloat){
        self.neibourAddress = neighbourAddress
        self.formalAddress = formalAddress
        self.longitude = longitude
        self.latitude = latitude
        super.init(title: "", tag: nil, description: "", id: id, definition: "", color: .white, cardType: "map", modifytime: "")
        var url = Constant.Configuration.url.Map
        url.appendPathComponent(id + ".jpg")
        self.imagePath = (url.path)
    }
    
    init(id:String,placeMark:Placemark){
        self.neibourAddress = placeMark.name
        self.formalAddress = placeMark.address == nil ? "" : placeMark.address!
        self.latitude = CGFloat((placeMark.location?.coordinate.latitude)!)
        self.longitude = CGFloat((placeMark.location?.coordinate.longitude)!)
        super.init(title: "", tag: nil, description: "", id: id, definition: "", color: .white, cardType: "map", modifytime: "")
        let url = Constant.Configuration.url.Map.appendingPathComponent(id + ".jpg")
        self.imagePath = url.path
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        self.formalAddress = aDecoder.decodeObject(forKey: "formalAddress") as! String
        //self.imagePath = aDecoder.decodeObject(forKey: "imagePath") as? String
        self.longitude = aDecoder.decodeObject(forKey:"longitude") as? CGFloat
        self.latitude = aDecoder.decodeObject(forKey:"latitude") as? CGFloat
        self.neibourAddress = aDecoder.decodeObject(forKey: "neighbourAddress") as! String
        super.init(coder: aDecoder)
        var url = Constant.Configuration.url.Map
        url.appendPathComponent(self.getId() + ".jpg")
        self.imagePath = url.path
    }
    
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(formalAddress, forKey: "formalAddress")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(neibourAddress, forKey: "neighbourAddress")
    }
}
