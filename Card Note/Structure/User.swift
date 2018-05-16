//
//  User.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/14.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Alamofire
import RebekkaTouch
class User:NSObject,URLSessionDelegate{
    private var username:String!
    private var password:String!
    private var email:String!
    static var session:Session!
    init(username:String,password:String,email:String) {
        self.username = username
        self.password = password
        self.email = email
        
    }
    
    
    static func connectServer(){
        var configuration = SessionConfiguration()
        configuration.host = "sk509.webcname.net"
        configuration.username = "ftp6107825"
        configuration.password = "741852963Aa"
        session = Session(configuration: configuration)
    }
    
    
    static func showList(path: String) {
        session.list(path) {
            (resources, error) -> Void in
            for item in resources!{
                print("文件类型：\(item.type)   文件名称：\(item.name)")
            }
        }
    }
    
    
    static func uploadPhotoUsingQCloud(email:String,url:URL){
        let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
        print("userImage/"  + email + "/" + url.lastPathComponent)
        put.object =  "userImage/"  + email + "/" + url.lastPathComponent
        put.bucket = "cardnote-1253464939"
        put.body = NSURL(fileURLWithPath: url.path)
        put.sendProcessBlock = {(bytesSent,totalBytesSent,totalBytesExpectedToSend) in
             NSLog("upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }
        
        put.setFinish { (result, error) in
             print("finish Upload")
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put)

    }
    
    static func uploadAudioUsingQCloud(email:String,url:URL){
        let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
        put.object = "userAudio/"  + email + "/" + url.lastPathComponent
        put.bucket = "cardnote-1253464939"
        put.body = NSURL(fileURLWithPath: url.path)
        put.sendProcessBlock = {(bytesSent,totalBytesSent,totalBytesExpectedToSend) in
            NSLog("upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }
        
        put.setFinish { (result, error) in
            print("finish Upload")
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put)
    }
    
    static func uploadMovieUsingQCloud(email:String,url:URL){
        let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
        put.object = "userMobie/"  + email + "/" + url.lastPathComponent
        put.bucket = "cardnote-1253464939"
        put.body = NSURL(fileURLWithPath: url.path)
        put.sendProcessBlock = {(bytesSent,totalBytesSent,totalBytesExpectedToSend) in
            NSLog("upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }
        
        put.setFinish { (result, error) in
            print("finish Upload")
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put)
    }
    
    
    
    
    static func downloadPhotosUsingQCloud(email:String,cardID:String,completionHandler:@escaping (Bool,Error?)->()){
        let request = QCloudGetObjectRequest()
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
         try? manager.createDirectory(at: url!, withIntermediateDirectories: true, attributes: nil)
        url?.appendPathComponent(cardID + ".jpg")
        request.downloadingURL = url
        request.bucket = "cardnote-1253464939"
        request.object = "userImage/" + email + "/" + cardID + ".jpg"
        request.finishBlock = {(outputObject,error) in
            if error == nil{
                completionHandler(true,nil)
            print("download successfully, Object ID\(outputObject)")
            }else{
                completionHandler(false,error)
            }
        }
        request.sendProcessBlock = {(bytesDownload,totalBytesDownload,totalBytesExpectedToDownload) in
             NSLog("upload %lld totalDownLoad %lld aim %lld", bytesDownload, totalBytesDownload, totalBytesExpectedToDownload);
        }
        QCloudCOSXMLService.defaultCOSXML().getObject(request)
    }
    
    static func downloadMapUsingQCloud(email:String,cardID:String,completionHandler:@escaping (Bool,Error?)->()){
        let request = QCloudGetObjectRequest()
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("mapPic")
         try? manager.createDirectory(at: url!, withIntermediateDirectories: true, attributes: nil)
        url?.appendPathComponent(cardID + ".jpg")
        request.downloadingURL = url
        request.bucket = "cardnote-1253464939"
        request.object = "userImage/" + email + "/" + cardID + ".jpg"
        request.finishBlock = {(outputObject,error) in
            if error == nil{
                completionHandler(true,nil)
                print("download successfully, Object ID\(outputObject)")
            }else{
                completionHandler(false,error)
            }
        }
        request.sendProcessBlock = {(bytesDownload,totalBytesDownload,totalBytesExpectedToDownload) in
            NSLog("upload %lld totalDownLoad %lld aim %lld", bytesDownload, totalBytesDownload, totalBytesExpectedToDownload);
        }
         QCloudCOSXMLService.defaultCOSXML().getObject(request)
    }
    
    static func downloadAudioUsingQCloud(email:String,cardID:String,completionHandler:@escaping (Bool,Error?)->()){
        let request = QCloudGetObjectRequest()
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("audio")
         try? manager.createDirectory(at: url!, withIntermediateDirectories: true, attributes: nil)
        url?.appendPathComponent(cardID + ".wav")
        request.downloadingURL = url
        request.bucket = "cardnote-1253464939"
        request.object = "userAudio/" + email + "/" + cardID + ".wav"
        request.finishBlock = {(outputObject,error) in
            if error == nil{
            print("download successfully, Object ID\(outputObject)")
                completionHandler(true,nil)
            }else{
                 completionHandler(false,error)
            }
        }
        request.sendProcessBlock = {(bytesDownload,totalBytesDownload,totalBytesExpectedToDownload) in
            NSLog("upload %lld totalDownLoad %lld aim %lld", bytesDownload, totalBytesDownload, totalBytesExpectedToDownload);
        }
         QCloudCOSXMLService.defaultCOSXML().getObject(request)
    }
    
    static func downloadMovieUsingQCloud(email:String,cardID:String,completionHandler:@escaping (Bool,Error?)->()){
        let request = QCloudGetObjectRequest()
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("movie")
         try? manager.createDirectory(at: url!, withIntermediateDirectories: true, attributes: nil)
        url?.appendPathComponent(cardID + ".mp4")
        request.downloadingURL = url
        request.bucket = "cardnote-1253464939"
        request.object = "userMovie/" + email + "/" + cardID + ".mp4"
        request.finishBlock = {(outputObject,error) in
            if error == nil{
            completionHandler(true,nil)
            print("download successfully, Object ID\(outputObject)")
            }else{
            completionHandler(false,error)
            }
        }
        request.sendProcessBlock = {(bytesDownload,totalBytesDownload,totalBytesExpectedToDownload) in
            NSLog("upload %lld totalDownLoad %lld aim %lld", bytesDownload, totalBytesDownload, totalBytesExpectedToDownload);
        }
         QCloudCOSXMLService.defaultCOSXML().getObject(request)
    }
    
   
    
    static func uploadPhotoUsingFTP(url:URL){
         connectServer()
          showList(path: "/")
            print("Data/\(loggedemail)/userImage/" + url.lastPathComponent)
            session.upload(url, path: "/Data/\(loggedemail)/userImage/" + url.lastPathComponent) {
            (result, error) -> Void in
            print("Upload file with result:\n\(result), error: \(error?.localizedDescription)\n\n")
            if result{
                
            }
        }
    }
    
   
    static func uploadAudioUsingFTP(url:URL){
        connectServer()
        showList(path: "/")
        session.upload(url, path: "/Data/\(loggedemail)/userAudio/" + url.lastPathComponent) {
            (result, error) -> Void in
            print("Upload file with result:\n\(result), error: \(error?.localizedDescription)\n")
            if error == nil{
            
            }else{
                print("Sync failed")
            }
        }
    }
    
    
    func alamofireCertificateConfig(){
        let manager = SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            //认证服务器证书
            if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodServerTrust {
                print("服务端证书认证！")
                let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
                let credential = URLCredential(trust: serverTrust)
                challenge.sender!.continueWithoutCredential(for: challenge)
                challenge.sender?.use(credential, for: challenge)
            }
            return (URLSession.AuthChallengeDisposition.useCredential,
                    URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod
            == (NSURLAuthenticationMethodServerTrust) {
            print("服务端证书认证！")
            let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
            
            let credential = URLCredential(trust: serverTrust)
            challenge.sender!.continueWithoutCredential(for: challenge)
            challenge.sender?.use(credential, for: challenge)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,
                              URLCredential(trust: challenge.protectionSpace.serverTrust!))
            
        }
    }
    
    static func follow(email:String,follow:String){
        let url = NSURL.init(string: NSString.init(format: "https://%@/follow.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let bodyStr = NSString.init(format: "email=%@followEmail=%@",email,follow)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error == nil{
                if data == nil{print("Fail to access data")}else{
                    let json = try? JSON(data:data!)
                    if json != nil{
                        if json!["ifSuccess"].boolValue{
                            print("succees to share card")
                        }else{print(json!["error"].stringValue)}
                    }
                }
            }else{
                print("Connection Error")
            }
        }
    }
    
    
    static func shareCard(card:Card,states:[String]){
        //let json = JSON(arrayLiteral: states)
        let json = JSON(states)
        let string = json.rawString()
        print(string)
    let url = NSURL.init(string: NSString.init(format: "https://%@/share.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let bodyStr = NSString.init(format: "userID=%@&cardID=%@&states=%@",loggedID,card.getId(),string!)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let dataTask = session.dataTask(with: request as URLRequest) { (data,response, error) in
            if error == nil{
                if data == nil{print("Fail to Access data")}else{
                    let string = resultHandler(data: NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String)
                    let json = try? JSON(data: string.data(using: String.Encoding.utf8)!)
                    if json != nil{
                        if json!["ifSuccess"].boolValue{
                            print("succees to share card")
                        }else{print(json!["error"].stringValue)}
                    }else{
                        print("Data Error")
                    }
                }
            }else{
                print("Connection Error")
            }
        }
        dataTask.resume()
    }
    
    
    
    static func getImage(email:String,cardID:String,completionHandler:@escaping (UIImage?)->()){
        let url = NSURL.init(string: NSString.init(format: "https://%@/getPhoto.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 120
        let bodyStr = NSString.init(format: "email=%@&picId=%@&type=%@",email,cardID,"image")
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            if error == nil{
            if data != nil{
                let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(string)
                let image = UIImage(data: data!)
                if image != nil{
                    let manager = FileManager.default
                    var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                    url?.appendPathComponent(loggedID)
                    url?.appendPathComponent(cardID + ".jpg")
                    if !manager.fileExists(atPath: (url?.path)!){
                       // manager.createDirectory(atPath: url?.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                    try? data?.write(to: url!)
                    }
                    completionHandler(image)
                }else{
                    completionHandler(nil)
                }
            }else{
                completionHandler(nil)
                }
            }else{
                completionHandler(nil)
                print(error?.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    static func getAudio(email:String,cardID:String,completionHandler:@escaping (String?)->()){
        let url = NSURL.init(string: NSString.init(format: "https://%@/getPhoto.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        session.configuration.timeoutIntervalForResource = 120
        session.configuration.timeoutIntervalForRequest = 120
        let bodyStr = NSString.init(format: "email=%@&picId=%@&type=%@",email,cardID,"audio")
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            
            if data != nil{
                   let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print(string)
                    let manager = FileManager.default
                    var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                    url?.appendPathComponent(loggedID)
                    url?.appendPathComponent("audio")
                    url?.appendPathComponent(cardID + ".wav")
                    if !manager.fileExists(atPath: (url?.path)!){
                       try? manager.createDirectory(atPath: (url?.deletingLastPathComponent().path)!, withIntermediateDirectories: true, attributes: nil)
                }
                    
                    do{
                   try data?.write(to: url!)
                        completionHandler((url?.path)!)
                    }catch let err{
                        completionHandler(nil)
                        print(err.localizedDescription)
                    }
            }else{
                completionHandler(nil)
            }
            
            }
        dataTask.resume()
    }
    
    
    static func uploadAudioWithAF(email:String,filePath:String,cardID:String){
        let data = NSData(contentsOfFile: filePath)
        print("音频长度：\(data?.length)")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data as! Data, withName: "file", fileName: "\(cardID).wav", mimeType: "audio/x-wav")
            multipartFormData.append(email.data(using: String.Encoding.utf8)!, withName: "userEmail")
            multipartFormData.append("audio".data(using: String.Encoding.utf8)!, withName: "type")
        }, to: NSString.init(format: "https://%@/uploadPhoto.php","app.cardnotebook.com/cardnote") as String) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                //连接服务器成功后，对json的处理
                upload.responseData(completionHandler: { (data) in
                    guard let result = data.data else {return}
                    print("response" + (NSString(data: result, encoding: String.Encoding.utf8.rawValue) as! String))
                })
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    print("json:\(result)")
                }
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("音频上传进度: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                //打印连接失败原因
                print(encodingError)
            }
        }
    }
    
    static func uploadImageWithAF(email:String,image:UIImage,cardID:String){
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                //采用post表单上传
                // 参数解释：
                //withName:和后台服务器的name要一致 ；fileName:可以充分利用写成用户的id，但是格式要写对； mimeType：规定的，要上传其他格式可以自行百度查一下
                multipartFormData.append(imageData!, withName: "file", fileName: "\(cardID).jpg", mimeType: "image/jpeg")
                //如果需要上传多个文件,就多添加几个
                multipartFormData.append(email.data(using: String.Encoding.utf8)!, withName: "userEmail")
                multipartFormData.append("image".data(using: String.Encoding.utf8)!, withName: "type")
                
                //......
        },to: NSString.init(format: "https://%@/uploadPhoto.php","app.cardnotebook.com/cardnote") as String,encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //连接服务器成功后，对json的处理
                upload.responseData(completionHandler: { (data) in
                    guard let result = data.data else {return}
                    print(NSString(data: result, encoding: String.Encoding.utf8.rawValue))
                })
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    print("json:\(result)")
                }
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("图片上传进度: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                //打印连接失败原因
                print(encodingError)
            }
        })
    }
    
    
    
    static func upLoadImage(email:String,pic:PicCard){
        let url = NSURL.init(string: NSString.init(format: "https://%@/uploadPhoto.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let data = UIImagePNGRepresentation(pic.pic)
        let boundary = "-----222222221212121212"
        let contentType = "multipart/form-data;boundary="+boundary
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        
        body.append(NSString(format:"\r\n--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition:form-data;name=\"userEmail\"\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Type:text/plain;charset=utf-8\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:email as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"\r\n--\(boundary)" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        ///////
        body.append(NSString(format:"\r\n--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition:form-data;name=\"file\";filename=\"\(pic.getId()).png\"\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Type:application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(data!)
        body.append(NSString(format:"\r\n--\(boundary)" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        request.httpBody = body as Data
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            if data != nil{
                let string = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                print(string)
            }
        }
        dataTask.resume()
    }

    
    static func getTime(completionHandler:@escaping (String?)->()){
        let url = NSURL.init(string: NSString.init(format: "https://%@/getTime.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            if error == nil{
            let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                if str != nil{
                    DispatchQueue.main.async {
                        completionHandler(str as! String)
                    }
                }
            }
        }
        dataTask.resume()
        
    }
    
    static func getUserCards(email:String,completionHandler:@escaping (JSON?)->()){
        let url = NSURL.init(string: NSString.init(format: "https://%@/getCards.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let bodyStr = NSString.init(format: "email=%@",email)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            if error == nil{
                let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(str)
                if str != nil{
                    let trimmedstr:String = resultHandler(data:str as! String)
                    if trimmedstr != ""{
                        let json = try? JSON(data: trimmedstr.data(using: String.Encoding.utf8)!)
                        
                        if json != nil{
                            DispatchQueue.main.async(){
                                completionHandler(json)
                            }
                            let success = json!["ifSuccess"].boolValue
                            if success{
                                print("get Card success")
                            }else{
                                let error = json!["error"].stringValue
                                print(error)
                            }
                        }else{
                            DispatchQueue.main.async() {
                                completionHandler(nil)
                            }
                        }
                    }else{
                        DispatchQueue.main.async() {
                            completionHandler(nil)
                        }
                    }
                }else{
                    DispatchQueue.main.async() {
                        completionHandler(nil)
                    }
                }
            }else{
                DispatchQueue.main.async() {
                    completionHandler(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    static func login(email:String, password:String, completionHandler:@escaping (JSON?)->()){
        let url = NSURL.init(string: NSString.init(format: "https://%@/login.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
         request.httpMethod = "POST"
        let bodyStr = NSString.init(format: "email=%@&password=%@",email,password)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.init(), completionHandler: {(response: URLResponse?, data: Data?, connectionError: Error?)-> Void in
            if connectionError == nil{
                let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(str)
                if (str?.hasSuffix("(result)"))!{
                    let string:String = String(describing: str)
                    let index = string.positionOf(sub:"(result)",backwards:false)
                    let lefttrimmedstring = string.substring(from: string.index(string.startIndex, offsetBy: index+8))
                    let righttrimmedstring = lefttrimmedstring.substring(to: string.index(lefttrimmedstring.endIndex, offsetBy:-9))
                    print("trimmed string" + righttrimmedstring)
                let json = try? JSON(data:righttrimmedstring.data(using: String.Encoding.utf8)!)
                if json != nil{
                    DispatchQueue.main.async() {
                        completionHandler(json)
                    }
                let ifSuccess = json!["ifSuccess"]
                if ifSuccess.boolValue{
                    ifloggedin = true
                    loggedemail = email
                    loggedusername = ((json!["userInfo"].dictionaryValue)["username"]?.stringValue)!
                }else{
                    ifloggedin = false
                    loggedemail = ""
                    loggedusername = ""
                }
                }else{
                    DispatchQueue.main.async() {
                        completionHandler(nil)
                    }
                    }
                }
            }else
            {
                DispatchQueue.main.async() {
                    completionHandler(nil)
                }
            }
        })
    }
    
    static func verification(email:String, username:String, password:String, completionhandler:@escaping (JSON)->()){
        let url = NSURL.init(string: NSString.init(format: "http://%@/verification.php","47.95.205.243/cardnote") as String)
        var authCode = ""
        for _ in 0...5{
        authCode += String(arc4random_uniform(10))
        }
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let bodyStr = NSString.init(format: "email=%@&password=%@&username=%@&code=%@&language=%@",email,password,username,authCode,"english")
        print(bodyStr)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.init(), completionHandler: {(response: URLResponse?, data: Data?, connectionError: Error?)-> Void in
            if connectionError == nil{
                let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(str)
                if (str?.hasSuffix("(result)"))!{
                    let string:String = String(describing: str)
                    let index = string.positionOf(sub:"(result)",backwards:false)
                    let lefttrimmedstring = string.substring(from: string.index(string.startIndex, offsetBy: index+8))
                    let righttrimmedstring = lefttrimmedstring.substring(to: string.index(lefttrimmedstring.endIndex, offsetBy:-9))
                    print("trimmed string" + righttrimmedstring)
                    let json = try? JSON(data:righttrimmedstring.data(using: String.Encoding.utf8)!)
                    if json != nil{
                        DispatchQueue.main.async() {
                            completionhandler(json!)
                        }
                        emailVerification = json!["verification"].stringValue
                        print("emailVerification" + emailVerification)
                    }
                }
            }else{
                print(connectionError)
            }
        })
    }
    
    
    static func addCard(email:String,card:Card,completionHandler:@escaping (JSON?)->()){
        let cardData = CardParser.CardToJSON(card)
        print("cardData" + cardData)
        let url = NSURL.init(string: NSString.init(format: "https://%@/addCard.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let bodyStr = NSString.init(format: "email=%@&card=%@",email,cardData)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            if error == nil{
                let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(str)
                if str != nil{
                    let trimmedstr:String = resultHandler(data:str as! String)
                    if trimmedstr != ""{
                        let json = try? JSON(data: trimmedstr.data(using: String.Encoding.utf8)!)
                        
                        if json != nil{
                            DispatchQueue.main.async() {
                                completionHandler(json)
                            }
                            let success = json!["ifSuccess"].boolValue
                            if success{
                                print("add Card success")
                            }else{
                                let error = json!["error"].stringValue
                                print(error)
                            }
                        }else{
                            DispatchQueue.main.async() {
                                completionHandler(nil)
                            }
                        }
                    }else{
                        DispatchQueue.main.async() {
                            completionHandler(nil)
                        }
                    }
                }else{
                    DispatchQueue.main.async() {
                        completionHandler(nil)
                    }
                }
            }else{
                DispatchQueue.main.async() {
                    completionHandler(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    static func resultHandler(data:String)->String{
        if (data.hasSuffix("(result)")){
            let string:String = String(describing: data)
            let index = string.positionOf(sub:"(result)",backwards:false)
            let lefttrimmedstring = string.substring(from: string.index(string.startIndex, offsetBy: index+8))
            let righttrimmedstring = lefttrimmedstring.substring(to: string.index(lefttrimmedstring.endIndex, offsetBy:-8))
            print("trimmed string" + righttrimmedstring)
            return righttrimmedstring
        }
        return ""
    }
    
    static func updateCard(card:Card,email:String,completionHandler:@escaping (JSON?)->()){
            let cardData = CardParser.CardToJSON(card)
            let url = NSURL.init(string: NSString.init(format: "https://%@/updateCard.php","app.cardnotebook.com/cardnote") as String)
            let request = NSMutableURLRequest.init(url: url! as URL)
            request.httpMethod = "POST"
            let bodyStr = NSString.init(format: "email=%@&card=%@",email,cardData)
            request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?) in
                if error == nil{
                    let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print(str)
                    if str != nil{
                        let trimmedstr:String = resultHandler(data:str as! String)
                        if trimmedstr != ""{
                            let json = try? JSON(data: trimmedstr.data(using: String.Encoding.utf8)!)
                            if json != nil{
                                DispatchQueue.main.async() {
                                    completionHandler(json)
                                }
                                let success = json!["ifSuccess"].boolValue
                                if success{
                                    print("card Update success")
                                }else{
                                    let error = json!["error"].stringValue
                                    print(error)
                                }
                            }else{
                                DispatchQueue.main.async() {
                                    completionHandler(nil)
                                }
                            }
                        }else{
                            DispatchQueue.main.async() {
                                completionHandler(nil)
                            }
                        }
                    }else{
                        DispatchQueue.main.async() {
                            completionHandler(nil)
                        }
                    }
                }else{
                    DispatchQueue.main.async() {
                        completionHandler(nil)
                    }
                }
            }
            dataTask.resume()
    }
    
    static func verifyEmail(auth:String, completionHandler:@escaping (JSON?)->()){
        let url = NSURL.init(string: NSString.init(format: "https://%@/verifyEmail.php","app.cardnotebook.com/cardnote") as String)
        let request = NSMutableURLRequest.init(url: url! as URL)
        request.httpMethod = "POST"
        let bodyStr = NSString.init(format: "verification=%@&code=%@&email=%@",emailVerification,auth,signUpEmail)
        request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data:Data?, response:URLResponse?, error:Error?)->Void in
            if error == nil{
                    let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print(str)
                if (str?.hasSuffix("(result)"))!{
                    let string:String = String(describing: str)
                    let index = string.positionOf(sub:"(result)",backwards:false)
                    let lefttrimmedstring = string.substring(from: string.index(string.startIndex, offsetBy: index+8))
                    let righttrimmedstring = lefttrimmedstring.substring(to: string.index(lefttrimmedstring.endIndex, offsetBy:-9))
                    print("trimmed string" + righttrimmedstring)
                    let json = try? JSON(data:righttrimmedstring.data(using: .utf8)!)
                    if json != nil{
                        DispatchQueue.main.async() {
                            completionHandler(json)
                        }
                        let success = json!["ifSuccess"].boolValue
                        if success{
                            print("verification success")
                        }else{
                            let error = json!["error"].stringValue
                            print(error)
                        }
                    }else{
                        DispatchQueue.main.async() {
                            completionHandler(nil)
                        }
                    }
                }
            }else{
                DispatchQueue.main.async() {
                    completionHandler(nil)
                }
            }
        }
        
        dataTask.resume()
        
    }
    
    static func signUp(email:String, username:String, password:String,auth:String, completionHandler:@escaping (JSON?)->()){
            let url = NSURL.init(string: NSString.init(format: "https://%@/signUp.php","app.cardnotebook.com/cardnote") as String)
            let request = NSMutableURLRequest.init(url: url! as URL)
            request.httpMethod = "POST"
            let bodyStr = NSString.init(format: "email=%@&password=%@&username=%@&verification=%@&code=%@",email,password,username,emailVerification,auth)
            request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.init(), completionHandler: {(response: URLResponse?, data: Data?, connectionError: Error?)-> Void in
                let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(str)
                if connectionError == nil{
                    if (str?.hasSuffix("(result)"))!{
                        let string:String = String(describing: str)
                        let index = string.positionOf(sub:"(result)",backwards:false)
                        let lefttrimmedstring = string.substring(from: string.index(string.startIndex, offsetBy: index+8))
                        let righttrimmedstring = lefttrimmedstring.substring(to: string.index(lefttrimmedstring.endIndex, offsetBy:-9))
                        print("trimmed string" + righttrimmedstring)
                        let json = try? JSON(data:righttrimmedstring.data(using: .utf8)!)
                    if json != nil{
                        DispatchQueue.main.async() {
                            completionHandler(json)
                        }
                    let success = json!["ifSuccess"].boolValue
                    if success{
                        print("Sign Up Success")
                    }else{
                        let error = json!["error"].stringValue
                        print(error)
                    }
                    }else{
                        DispatchQueue.main.async() {
                            completionHandler(nil)
                        }
                        }
                    }
                }
            })
        }
    
    static func loginWithToken(completionHandler:@escaping (JSON?)->()){
        
        if UserDefaults.standard.string(forKey: "userToken") != ""{
            let url = NSURL.init(string: NSString.init(format: "https://%@/loginwithtoken.php","app.cardnotebook.com/cardnote") as String)
            let request = NSMutableURLRequest.init(url: url! as URL)
            request.httpMethod = "POST"
            let bodyStr = NSString.init(format: "token=%@",UserDefaults.standard.string(forKey: "userToken")!)
            request.httpBody = bodyStr.data(using: String.Encoding.utf8.rawValue)
             NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.init(), completionHandler: {(response: URLResponse?, data: Data?, connectionError: Error?)-> Void in
              
               // print(str)
                if connectionError == nil{
                     let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    if (str?.hasSuffix("(result)"))!{
                        let string:String = String(describing: str)
                        let index = string.positionOf(sub:"(result)",backwards:false)
                        let lefttrimmedstring = string.substring(from: string.index(string.startIndex, offsetBy: index+8))
                        let righttrimmedstring = lefttrimmedstring.substring(to: string.index(lefttrimmedstring.endIndex, offsetBy:-9))
                        print("trimmed string" + righttrimmedstring)
                        let json = try? JSON(data:righttrimmedstring.data(using: .utf8)!)
                        if json != nil{
                            DispatchQueue.main.async() {
                                completionHandler(json)
                            }
                        let success = json!["ifSuccess"].boolValue
                            if success{
                                print("login Success")
                            }else{
                                let error = json!["error"].stringValue
                                print(error)
                            }
                        }else
                         {
                            DispatchQueue.main.async() {
                                completionHandler(nil)
                            }
                         }
                    }else{
                        completionHandler(nil)
                    }
                }else{
                    DispatchQueue.main.async() {
                        completionHandler(nil)
                    }
                }
            })
       
        }else{
            completionHandler(nil)
        }
    }
    

}
