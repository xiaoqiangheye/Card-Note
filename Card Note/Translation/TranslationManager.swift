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
      //  parameters?.from = YDLanguageType.chinese
        let language = getCurrentLanguage()
        if language.contains("zh"){
            parameters?.to = .chinese
        }else if language.contains("en"){
            parameters?.to = .english
        }
        else if language.contains("fr"){
            parameters?.to = .french
        }
        else if language.contains("pt"){
            parameters?.to = .portuguese
        }
        else if language.contains("ja"){
            parameters?.to = .japanese
        }
        else if language.contains("ko"){
            parameters?.to = .korean
        }
        else if language.contains("ru"){
            parameters?.to = .russian
        }
        else if language.contains("es"){
            parameters?.to = .spanish
        }
        else if language.contains("vi"){
            parameters?.to = .vietnamese
        }else{
             parameters?.to = .chinese
        }
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
