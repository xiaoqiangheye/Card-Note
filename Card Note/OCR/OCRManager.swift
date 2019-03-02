//
//  OCRManager.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/15.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyJSON
class OCRManager:NSObject,URLSessionDelegate{
    class func ocr(image:UIImage,completionhandler:@escaping (YDOCRResult?)->()){
        let yd = YDTranslateInstance.shared()
        yd?.appKey = "0388377d12128473"
        let request = YDOCRRequest.init()
        let param = YDOCRParameter.init()
        param.source = "youdaoocr" //设置源
        param.detectType = "10011" //设置识别类型，10011位片段识别，目前只支持片段识别
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
                completionhandler(result)
            }
        }
    }
    
    class func ocr(usingAPI image:UIImage, completionhandler:@escaping (Error?,[String])->()){
       // var url = "https://openapi.youdao.com/ocrapi"
        let appKey = "2d2825c13e5826fe"
        let detectType = "10012"
        let imageType = "1"
        let langType = "auto"
        let docType = "json"
        let salt = String(19800)
        // 将图片转化成Data
        let imageData = resetImgSize(sourceImage: image, maxImageLenght: 1000, maxSizeKB: 2000)
        // 将Data转化成 base64的字符串
        let imageBase64String = imageData.base64EncodedString()
        let sign = md5String(str: appKey + imageBase64String + salt + "mhsFOp6A1xfbvrjHuuhOxkiBsHpPSXLv")
        let url = NSURL.init(string:"https://openapi.youdao.com/ocrapi")
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        let img = imageBase64String.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let bodyStr = NSString.init(format: "appKey=%@&img=%@&detectType=%@&imageType=%@&langType=%@&salt=%@&docType=%@&sign=%@",appKey,img,detectType,imageType,langType,salt,docType,sign)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        //print(bodyStr)
        let dataTask = session.dataTask(with: request as URLRequest) { (data,response, error) in
            if error != nil{
                print(error?.localizedDescription as Any)
            }else{
                do{
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
        print("md5" + md5)
        return md5
    }
    
}
