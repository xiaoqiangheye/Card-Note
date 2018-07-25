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
    var image:UIImage
    var neibourAddress:String
    internal var latitude:CGFloat?
    internal var longitude:CGFloat?
    internal var imagePath:String?
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
        let manager = FileManager.default
        var url = Constant.Configuration.url.Map
        url.appendPathComponent(loggedID)
        url.appendPathComponent("mapPic")
        url.appendPathComponent(id + ".jpg")
        self.imagePath = (url?.path)!
        if self.imagePath == nil{
            self.image = #imageLiteral(resourceName: "searchBar")
        }else{
            
            self.image = UIImage(contentsOfFile: imagePath!)!
        }
        super.init(title: "", tag: "", description: "", id: id, definition: "", color: .white, cardType: "map", modifytime: "")
    }
    
    init(id:String, formalAddress:String, neighbourAddress:String,longitude:CGFloat, latitude:CGFloat){
        self.neibourAddress = neighbourAddress
        self.formalAddress = formalAddress
        self.longitude = longitude
        self.latitude = latitude
        self.image = #imageLiteral(resourceName: "searchBar")
        super.init(title: "", tag: "", description: "", id: id, definition: "", color: .white, cardType: "map", modifytime: "")
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("mapPic")
        url?.appendPathComponent(id + ".jpg")
        
        if manager.fileExists(atPath: (url?.path)!)
        {
            let image = UIImage(contentsOfFile: (url?.path)!)
            if image != nil{
                self.image = image!
            }
        }
        self.imagePath = (url?.path)!
    }
    
    init(id:String,placeMark:Placemark){
        self.neibourAddress = placeMark.name
        self.formalAddress = placeMark.address == nil ? "" : placeMark.address!
        self.latitude = CGFloat((placeMark.location?.coordinate.latitude)!)
        self.longitude = CGFloat((placeMark.location?.coordinate.longitude)!)
        self.image = #imageLiteral(resourceName: "searchBar")
        super.init(title: "", tag: "", description: "", id: id, definition: "", color: .white, cardType: "map", modifytime: "")
        let url = Constant.Configuration.url.Map.appendingPathComponent(id + ".jpg")
         let manager = FileManager.default
        if manager.fileExists(atPath: (url.path))
        {
            let image = UIImage(contentsOfFile: (url.path))
            if image != nil{
                self.image = image!
            }
        }
        self.imagePath = url.path
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        self.image = #imageLiteral(resourceName: "searchBar")
        self.formalAddress = aDecoder.decodeObject(forKey: "formalAddress") as! String
        //self.imagePath = aDecoder.decodeObject(forKey: "imagePath") as? String
        self.longitude = aDecoder.decodeObject(forKey:"longitude") as? CGFloat
        self.latitude = aDecoder.decodeObject(forKey:"latitude") as? CGFloat
        self.neibourAddress = aDecoder.decodeObject(forKey: "neighbourAddress") as! String
        super.init(coder: aDecoder)
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("mapPic")
        url?.appendPathComponent(self.getId() + ".jpg")
        self.imagePath = url?.path
        if manager.fileExists(atPath: imagePath!){
            let image = UIImage(contentsOfFile: imagePath!)
            if image != nil{
            self.image = image!
            
            }
        }else{
            self.image = #imageLiteral(resourceName: "searchBar")
        }
       
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(formalAddress, forKey: "formalAddress")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(neibourAddress, forKey: "neighbourAddress")
    }
}
