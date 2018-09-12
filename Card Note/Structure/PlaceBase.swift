//
//  Map.swift
//  Card Note
//
//  Created by 强巍 on 2018/9/6.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyJSON
class Place{
    private var findPlaceUrl:URL = URL(string: "https://maps.googleapis.com/maps/api/place/findplacefromtext")!
    private var nearBySearch:URL = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch")!
    private var textSearch:URL = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch")!
    private var server:URL = URL(string: "https://app.cardnotebook.com/googleapis/place.php")!
    
    func findPlaceSearch(text:String,options:PlaceSearchFindPlaceOptions,completionHandler:@escaping (PlaceSearchResult?,PlaceSearchError?)->()){
        if options.key == nil{
            let error = PlaceSearchError()
            error.errorMessage = "key is null"
            completionHandler(nil, error)
            return
        }
        if options.inputtype == nil{
            let error = PlaceSearchError()
            error.errorMessage = "input Type is null"
            completionHandler(nil, error)
            return
        }
        if text == ""{
            let error = PlaceSearchError()
            error.errorMessage = "String is empty"
            completionHandler(nil, error)
            return
        }
        
        var table = Dictionary<String,String>()
        table["key"] = options.key
        table["inputtype"] = options.inputtype?.rawValue
        table["input"] = text
        table["fields"] = options.fields
        if options.languageCode != nil{
        table["language"] = options.languageCode
        }
        
        var urlReqest = URLRequest(url: server)
        urlReqest.httpMethod = "POST"
        for (key,value) in table{
            urlReqest.addValue(key, forHTTPHeaderField: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        let dataTask = URLSession.shared.dataTask(with: urlReqest) { (data, response, error) in
            if error != nil{
                let e = PlaceSearchError()
                e.errorMessage = error?.localizedDescription
                completionHandler(nil, e)
                return
            }
            
            if data == nil{
                let e = PlaceSearchError()
                e.errorMessage = "No data received."
                completionHandler(nil, e)
                return
            }
            
            let json = JSONDecoder()
            let result = try? json.decode(PlaceSearchResult.self, from: data!)
            
        }
        dataTask.resume()
    }
}


func textSearch(text:String,options:PlaceSearchTextSearchOptions,completionHandler:@escaping (PlaceSearchResult?,PlaceSearchError?)->()){
    
    
    
    
}

class PlaceSearchFindPlaceOptions:PlaceSearchOptions{
    var inputtype:InputType?
    var languageCode:String?
}


class PlaceSearchTextSearchOptions:PlaceSearchOptions{
    var location:Location?
    var languageCode:String?
    var radius:Int?
    struct Location{
        var latitude:CGFloat
        var longitude:CGFloat
    }
}



class PlaceSearchOptions{
    var searchType:SearchType?
    var key:String?
    var outputType:OutputType?
    var fields = "name,formatted_address,geometry/location"
    enum InputType:String{
        case textquery = "textquery"
        case phonenumber = "phonenumber"
    }
    
    enum OutputType:String{
        case json = "json"
        case xml = "xml"
    }
    
    enum SearchType:String{
        case findPlace
        case textSearch
        case nearBySearch
    }
    
    init() {
        
    }
}


class PlaceSearchResult:Decodable{
    required public init(from decoder: Decoder) throws {
        
    }
    var status:Status?
    var results:[PlaceInfo]?
    struct PlaceInfo:Decodable{
        var name:String?
        var formattedAddress:String?
        var geometry:Geometry?
        struct Geometry:Decodable{
            public init(from decoder: Decoder) throws {
                
            }
            var location:Location?
            var viewport:ViewPort?
            
            struct Location{
            var latitude:CGFloat?
            var longitude:CGFloat?
                enum CodingKeys:String,CodingKey{
                   case latitude = "lat"
                   case longitude = "lng"
                }
            }
            
            struct ViewPort{
                var northeast:Location?
                var southwest:Location?
            }
            
            enum CodingKeys:String,CodingKey{
                case location = "location"
                case viewport = "viewport"
            }
        }
        
        enum CodingKeys:String,CodingKey{
            case geometry = "geometry"
            case name = "name"
            case formattedAddress = "formatted_address"
        }
      }
    
    enum CodingKeys: String, CodingKey {
       case status = "status"
       case results = "results"
    }
    
    enum Status:String,Codable{
        case OK = "OK"
        case ZERO_RESULTS = "ZERO_RESULTS"
        case OVER_QUERY_LIMIT = "OVER_QUERY_LIMIT"
        case REQUEST_DENIED = "REQUEST_DENIED"
        case INVALID_REQUEST = "INVALID_REQUEST"
        case UNKNOWN_ERROR = "UNKNOWN_ERROR"
    }
}


class PlaceSearchError{
    var errorMessage:String?
}
