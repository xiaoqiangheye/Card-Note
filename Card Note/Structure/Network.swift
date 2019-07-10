//
//  Network.swift
//  Card Note
//
//  Created by Wei Wei on 7/5/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Network{
    static func getVersion(completionHandler:@escaping (String?,String?,Bool)->()){
        Alamofire.request("https://app1.cardnotebook.com/version.php", method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseData { (response) in
                switch response.result{
                    case .success(let value):
                        do{
                            let json = try JSON(data: value)
                            
                            let result = json["result"].boolValue
                            if result{
                                let version = json["version"].stringValue
                                let contents = json["contents"].stringValue
                                completionHandler(version,contents,true)
                            }else{
                                completionHandler(nil,nil,false)
                            }
                            
                        }catch{
                            completionHandler(nil,nil,false)
                        }
                    case .failure(let error):
                        completionHandler(nil,nil,false)
                }
        }
    }
    
    static func get(key:String, completionHandler:@escaping (String?,Error?)->()){
        let parameter = ["key" : key]
        Alamofire.request("https://app1.cardnotebook.com/data.php", method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response) in
                switch response.result{
                    case .success(let value):
                        let dictionary = value as! [String:String]
                        completionHandler(dictionary["value"], nil)
                    case .failure(let error):
                        completionHandler(nil,error)
                }
        }
    }
}
