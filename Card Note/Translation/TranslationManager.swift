//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/29.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
class TranslationManager{
    class func translate(text:String,completionHandler:@escaping (String?)->()){
        let yd = YDTranslateInstance.shared()
        yd?.appKey = "0388377d12128473"
        var results = ""
        let translateRequest = YDTranslateRequest()
        let parameters = YDTranslateParameters.targeting()
        parameters?.source = "youdaosw"
        parameters?.from = YDLanguageType.chinese
        parameters?.to = YDLanguageType.english
        translateRequest.translateParameters = parameters
        translateRequest.lookup(text) { (request, response, error) in
            if error == nil{
          let string = response?.translation[0]
                if string != nil{
                DispatchQueue.main.async {
                    results = string as! String
                    completionHandler(results)
                    }
                }else{
                    completionHandler(nil)
                }
            }else{
                    completionHandler(nil)
            }
        }
    }
}
