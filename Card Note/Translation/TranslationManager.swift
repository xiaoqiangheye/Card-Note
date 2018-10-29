//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/29.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyJSON
class TranslationManager{
    class func gTranslate(text:String,toLanguage:String,fromLanguage:String,completionHandler:@escaping (String?)->()){
        var url = "https://translation.googleapis.com/language/translate/v2?"
        let q = text.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let target = toLanguage
        let format = "text"
        let source = fromLanguage
        let model = "nmt"
        let key = "AIzaSyDp4psXj4wq5o3lMW64o-qjI_YynH8scIQ"
        
        url.append("q=\(q)&")
        url.append("key=\(key)&")
        if fromLanguage != "auto"{
        url.append("source=\(source)&")
        }
        url.append("format=\(format)&")
        url.append("model=\(model)&")
        url.append("target=\(target)")
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil{
                do{
                    let json = try JSON(data: data!)
                    print(String(data: data!, encoding: String.Encoding.utf8))
                    let list = json["data"]
                    let translations = list["translations"].arrayValue
                    if translations.count > 0{
                        let text = translations[0]["translatedText"].stringValue
                        completionHandler(text)
                    }else{
                        completionHandler(nil)
                    }
                }catch let error{
                    print(error.localizedDescription)
                    completionHandler(nil)
                }
            }else{
                completionHandler(nil)
            }
        }
        dataTask.resume()
    }
    
    
    class func translate(text:String,from:String,to:String,completionHandler:@escaping (String?)->()){
        let yd = YDTranslateInstance.shared()
        yd?.appKey = "0388377d12128473"
        var results = ""
        let translateRequest = YDTranslateRequest()
        let parameters = YDTranslateParameters.targeting()
        parameters?.source = "youdaosw"
        if from.contains("zh"){
            parameters?.from = .chinese
        }else if from.contains("en"){
            parameters?.from = .english
        }
        else if from.contains("fr"){
            parameters?.from = .french
        }
        else if from.contains("pt"){
            parameters?.from = .portuguese
        }
        else if from.contains("ja"){
            parameters?.from = .japanese
        }
        else if from.contains("ko"){
            parameters?.from = .korean
        }
        else if from.contains("ru"){
            parameters?.from = .russian
        }
        else if from.contains("es"){
            parameters?.from = .spanish
        }
        else if from.contains("vi"){
            parameters?.from = .vietnamese
        }else{
            parameters?.from = .auto
        }
        
    
        if to.contains("zh"){
            parameters?.to = .chinese
        }else if to.contains("en"){
            parameters?.to = .english
        }
        else if to.contains("fr"){
            parameters?.to = .french
        }
        else if to.contains("pt"){
            parameters?.to = .portuguese
        }
        else if to.contains("ja"){
            parameters?.to = .japanese
        }
        else if to.contains("ko"){
            parameters?.to = .korean
        }
        else if to.contains("ru"){
            parameters?.to = .russian
        }
        else if to.contains("es"){
            parameters?.to = .spanish
        }
        else if to.contains("vi"){
            parameters?.to = .vietnamese
        }else{
            parameters?.to = .english
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
