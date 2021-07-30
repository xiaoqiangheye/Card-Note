//
//  OCRManager.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/15.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyJSON
import CryptoKit

class OCRManager:NSObject,URLSessionDelegate{
    
    
    class func ocr(image:UIImage,completionhandler:@escaping ([String]?)->()){
        let yd = YDTranslateInstance.shared()
        yd?.appKey = "3af11feba012109e"
        let request = YDOCRRequest.init()
        let param = YDOCRParameter.init()
        param.source = "youdaoocr" //设置源
        param.detectType = "10012" //设置识别类型，10011位片段识别，目前只支持片段识别
        param.langType = "auto"
        request.param = param
        
        // 将图片转化成Data
        let imageData = UIImagePNGRepresentation(image)
        
        // 将Data转化成 base64的字符串
        let imageBase64String = imageData?.base64EncodedString()
       
        request.lookup(imageBase64String) { (request, result, error) in
            if error != nil{
                print(error?.localizedDescription as Any)
                completionhandler(nil)
            }else{
                let results = result!["Result"] as! [AnyHashable : Any]
                let regions = results["regions"] as! Array<[AnyHashable : Any]>
                if regions.count == 0{
                    completionhandler(nil)
                    return
                }
                minusOneRecognition()
                var stringArray = [String]()
                for region in regions{
                    var string = ""
                    let lines = region["lines"] as! Array<[AnyHashable : Any]>
                    if lines.count == 0{continue}
                    for line in lines{
                        let words = line["words"] as! Array<[AnyHashable : Any]>
                        if words.count == 0{continue}
                        for word in words{
                            string.append(word["word"] as! String + " ")
                        }
                        string.append("\n")
                    }
                    if string != ""{
                    string.removeLast()
                    }
                    stringArray.append(string)
                }
                
                completionhandler(stringArray)
            }
        }
    }
    
    
    class func ocr(usingAPI image:UIImage, completionhandler:@escaping (Error?,[String])->()){
        let appKey = "0057f69ba54ea8a4"
        let detectType = "10011"
        let imageType = "1"
        let langType = "auto"
        let docType = "json"
        let signType = "v3"
        let curtime = String(Int(Date().timeIntervalSince1970))
        
        
        let salt = String(19800)
        let key = "JbcBVEIX8Q8YzuAFnAhTJzxoOILIPHV8"
        // 将图片转化成Data
        let imageData = resetImgSize(sourceImage: image, maxImageLenght: 1000, maxSizeKB: 2000)
        // 将Data转化成 base64的字符串
        
        let imageBase64String = imageData.base64EncodedString()
        
        var input = ""
        
        if(imageBase64String.length > 20){
            input = String(imageBase64String.prefix(10)) + String(imageBase64String.length) + String(imageBase64String.suffix(10))
        } else {
            input = imageBase64String
        }
        let string = appKey + input + salt + curtime + key
        let data = Data(string.utf8)
        
        
        let sign = SHA256.hash(data: data)
        
        let hashString = sign.compactMap { String(format: "%02x", $0) }.joined()
        
    
        
        let url = NSURL.init(string:"https://openapi.youdao.com/ocrapi")
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        
        let bodyStr = NSString.init(format: "appKey=%@&img=%@&detectType=%@&imageType=%@&langType=%@&salt=%@&docType=%@&sign=%@&signType=%@&curtime=%@",appKey,imageBase64String,detectType,imageType,langType,salt,docType, hashString,signType, curtime)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        //print(bodyStr)
        let dataTask = session.dataTask(with: request as URLRequest) { (data,response, error) in
            if error != nil{
                print(error?.localizedDescription as Any)
            }else{
                do{
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                let result = try JSON(data: data!)["Result"]
                let regions = result["regions"].arrayValue
                    if regions.count == 0{
                        completionhandler(nil, [String]())
                        return
                    }
                    var stringArray = [String]()
                    for region in regions{
                        var string = ""
                        let lines = region["lines"].arrayValue
                        if lines.count == 0{continue}
                        for line in lines{
                            let words = line["words"].arrayValue
                            if words.count == 0{continue}
                            for word in words{
                                string.append(word["word"].stringValue + " ")
                            }
                            string.append("\n")
                        }
                        if string != ""{
                        string.removeLast()
                        }
                        stringArray.append(string)
                    }
                    completionhandler(error, stringArray)
                    print(stringArray)
                }catch let error
                {
                    completionhandler(error, [String]())
                }
            }
        }
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod
            == (NSURLAuthenticationMethodServerTrust) {
            print("服务端证书认证！")
            let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: serverTrust)
            challenge.sender!.continueWithoutCredential(for: challenge)
            challenge.sender?.use(credential, for: challenge)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,
                              URLCredential(trust: challenge.protectionSpace.serverTrust!))
            
        }
    }
    
    class func md5String(str:String) -> String{
        let cStr = str.cString(using:String.Encoding.utf8)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        
        let md5 = md5String.lowercased
        return md5
    }
    
    class func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
    

}
