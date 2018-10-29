//
//  Extension.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/7.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


extension String {
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

extension UITextView{
    enum TextModeType:String{
        case Editing
        case PlaceHolder
        case Non_Editing_Non_PlaceHolder
    }
}

extension UIDevice{
    public func Xdistance() -> Int{
        if UIScreen.main.bounds.height == 812 {
            return 44
        }
        return 20
    }
    
    public func BottomDistance()-> Int{
        if UIScreen.main.bounds.height == 812{
            return 34
        }
        return 0
    }
    
    public func isX()->Bool{
        if UIScreen.main.bounds.height == 812 {
            return true
        }else{
            return false
        }
    }
}

extension UIColor{
    class func colorWithHexString(hex:String) ->UIColor{
        var cString = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            let index = cString.index(cString.startIndex, offsetBy:1)
            cString = cString.substring(from: index)
        }
        if (cString.characters.count != 6) {
            return UIColor.red
        }
        let rIndex = cString.index(cString.startIndex, offsetBy: 2)
        let rString = cString.substring(to: rIndex)
        let otherString = cString.substring(from: rIndex)
        let gIndex = otherString.index(otherString.startIndex, offsetBy: 2)
        let gString = otherString.substring(to: gIndex)
        let bIndex = cString.index(cString.endIndex, offsetBy: -2)
        let bString = cString.substring(from: bIndex)
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

func getCurrentLanguage() -> String{
    
    let defs = UserDefaults.standard
    
    let languages = defs.object(forKey: "AppleLanguages")//获取系统支持的所有语言集合

    let preferredLanguage = (languages! as AnyObject).object(at: 0)
    
    return preferredLanguage as! String
    
}


func cutFullImageWithView(view:UIView)->UIImage{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

func cutFullImageWithView(scrollView:UIScrollView) -> UIImage
{
    scrollView.contentOffset.y = scrollView.contentSize.height
    // 记录当前的scrollView的偏移量和坐标
    let currentContentOffSet:CGPoint = scrollView.contentOffset
    let currentFrame:CGRect = scrollView.frame;
    var image:UIImage? = nil
    // 设置为zero和相应的坐标
    scrollView.contentOffset.y = 0
    scrollView.frame = CGRect.init(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.contentSize.height)
    
    // 参数①：截屏区域  参数②：是否透明  参数③：清晰度
   UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, UIScreen.main.scale)
    scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
    image = UIGraphicsGetImageFromCurrentImageContext()!
    // 重新设置原来的参数
    scrollView.contentOffset = currentContentOffSet
    scrollView.frame = currentFrame
    
    UIGraphicsEndImageContext();
    
    return image!;
}


func writeImageToAlbum(image:UIImage)
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}


func isPremium()->Bool{
    if Constant.Configuration.AccountPlan == Constant.AccountPlan.basic.rawValue || Constant.Configuration.AccountPlan == ""{
        print("AccountPlan is " + Constant.Configuration.AccountPlan)
        return false
    }else if Constant.Configuration.AccountPlan == Constant.AccountPlan.premium.rawValue{
        return true
    }else{
        return false
    }
}


func cropImageWithImageV(imageV:UIImageView,pointArr:[CGPoint])->UIImage{
    
    var rect = CGRect.zero
    rect.size = (imageV.image?.size)!;
    
    UIGraphicsBeginImageContextWithOptions(rect.size,true, 0.0);
    
    UIColor.black.setFill()
    UIRectFill(rect)
    UIColor.white.setFill()
    
    let aPath = UIBezierPath()
    
    //起点
    let v = pointArr[0]
    let p = v
    let m_p = convertCGPoint(p,imageV.frame.size,imageV.frame.size)
    aPath.move(to: m_p)
    
    //其他点
    for i in pointArr {
        let v1 = i
        let p1 = v1
        let m_p = convertCGPoint(p1,imageV.frame.size,imageV.frame.size)
       aPath.addLine(to: m_p)
    }
    
   aPath.close()
   aPath.fill()
    
    //遮罩层
    let mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
    
    UIGraphicsGetCurrentContext()?.clip(to: rect, mask: (mask?.cgImage)!)
    imageV.image?.draw(at: CGPoint.zero)
    
    let maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskedImage!;
}

func convertCGPoint(_ point1:CGPoint,_ rect1:CGSize,_ rect2:CGSize)->CGPoint{
    var point1 = point1
    point1.y = rect1.height - point1.y;
    let result = CGPoint(x:(point1.x*rect2.width)/rect1.width,y:(point1.y*rect2.height)/rect1.height)
    return result
}




func sync(completionHandler:@escaping (Bool)->()){
    let manager = FileManager.default
    var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
    url?.appendPathComponent("card.txt")
    if !manager.fileExists(atPath: (url?.path)!){
        try? manager.createDirectory(atPath: (url?.deletingLastPathComponent().path)!, withIntermediateDirectories: true, attributes: nil)
        manager.createFile(atPath: (url?.path)!, contents: nil, attributes: nil)
        let cardList = [Card]()
        let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
        do{
            try datawrite.write(to: url!)
        }catch{
            print("fail to add")
        }
    }
    
    var ifSuccessArray = [Bool]()
    Cloud.queryAllCard { (cards) in
        //get local cards
        if let dateRead = try? Data.init(contentsOf: url!){
            var locals = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
            var cardCopiedList = locals
            if locals == nil{
                locals = [Card]()
            }
            
            var mutableCards = cards
            var i = 0
            for card in mutableCards{
                var j = 0
                var removed:Bool = false
                for local in locals!{
                    if card.getId() == local.getId(){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let dateIn = NSDate(timeIntervalSince1970: Double(card.getTime())!)
                        let datelo = NSDate(timeIntervalSince1970: Double(local.getTime())!)
                        let result:ComparisonResult = (dateIn.compare(datelo as Date))
                        if result == ComparisonResult.orderedDescending{
                            //update the localCard if Internet is more recent
                            cardCopiedList![j] = card
                        }else if result == ComparisonResult.orderedAscending{
                            //update the internetCard if local is more recent
                            Cloud.updateCard(card: card, completionHandler: { (bool) in
                                ifSuccessArray.append(bool)
                            })
                        }
                        mutableCards.remove(at: i)
                        locals!.remove(at: j)
                        removed = true
                    }
                    if !removed{
                        j+=1
                    }
                }
                if !removed{
                    i+=1
                }
            }
            
            //add rest InterNetCard to local
            cardCopiedList?.append(contentsOf:mutableCards)
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardCopiedList!)
            do{
                try datawrite.write(to: url!)
            }catch{
                print("fail to add")
                ifSuccessArray.append(false)
            }
            //add local Card to InterNet
            for card in locals!{
                Cloud.updateCard(card: card, completionHandler: { (bool) in
                    ifSuccessArray.append(bool)
                })
            }
        }
        if ifSuccessArray.contains(false){
            completionHandler(false)
        }else{
            completionHandler(true)
        }
    }
    
   
    /*deprecated Login/Sign up Function in 8.13.2000
    User.getUserCards(email: loggedemail, completionHandler: { (json:JSON?) in
        if json != nil{
            if !json!["ifSuccess"].boolValue{
                ifSuccessArray.append(false)
            }else{
                ifSuccessArray.append(true)
                let carddata = json!["card"].arrayValue
                //get cards from the dataBase
                var cardArray:[Card] = [Card]()
                for cardJSON in carddata{
                    print("card" + cardJSON.rawString()!)
                    let card = CardParser.JSONToCard(cardJSON.rawString()!)
                    if card != nil{
                        cardArray.append(card!)
                    }
                }
                //get local cards
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent("card.txt")
                if let dateRead = try? Data.init(contentsOf: url!){
                    var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                    var cardCopiedList = cardList
                    if cardList == nil{
                        cardList = [Card]()
                    }
                    var i = 0
                    for interNetCard in cardArray{
                        var j = 0
                        var removed:Bool = false
                        for localCard in cardList!{
                            
                            if interNetCard.getId() == localCard.getId(){
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let dateIn = formatter.date(from: interNetCard.getTime())
                                let datelo = formatter.date(from: localCard.getTime())
                                let result:ComparisonResult = (dateIn?.compare(datelo!))!
                                if result == ComparisonResult.orderedDescending{
                                    //update the localCard if Internet is more recent
                                    cardCopiedList![j] = interNetCard
                                }else if result == ComparisonResult.orderedAscending{
                                    //update the internetCard if local is more recent
                                    User.updateCard(card: localCard, email: loggedemail, completionHandler: { (json:JSON?) in
                                        if json != nil{
                                            let ifSuccess = json!["ifSuccess"].boolValue
                                            if ifSuccess{
                                                print("Success to update card")
                                                ifSuccessArray.append(true)
                                            }else{
                                                ifSuccessArray.append(false)
                                            }
                                        }
                                        
                                    })
                                }
                                cardArray.remove(at: i)
                                cardList?.remove(at: j)
                                removed = true
                            }
                            if !removed{
                                j+=1
                            }
                        }
                        if !removed{
                            i+=1
                        }
                    }
                    
                    //add rest InterNetCard to local
                    cardCopiedList?.append(contentsOf:cardArray)
                    let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardCopiedList!)
                    do{
                        try datawrite.write(to: url!)
                    }catch{
                        print("fail to add")
                        ifSuccessArray.append(false)
                    }
                    //add local Card to InterNet
                    for card in cardList!{
                        User.addCard(email: loggedemail, card: card, completionHandler: { (json:JSON?) in
                            if json != nil{
                                let ifSuccess = json!["ifSuccess"].boolValue
                                if ifSuccess{
                                    print("Sync Success")
                                    ifSuccessArray.append(true)
                                }else{
                                    let error = json!["error"].stringValue
                                    ifSuccessArray.append(false)
                                }
                            }
                        })
                    }
                }
            }
        }
    })
 */
    
}



func resetImgSize(sourceImage : UIImage,maxImageLenght : CGFloat,maxSizeKB : CGFloat) -> Data {
    
    var maxSize = maxSizeKB
    
    var maxImageSize = maxImageLenght
    
    
    
    if (maxSize <= 0.0) {
        
        maxSize = 1024.0;
        
    }
    
    if (maxImageSize <= 0.0)  {
        
        maxImageSize = 1024.0;
        
    }
    
    //先调整分辨率
    
    var newSize = CGSize.init(width: sourceImage.size.width, height: sourceImage.size.height)
    
    let tempHeight = newSize.height / maxImageSize;
    
    let tempWidth = newSize.width / maxImageSize;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        
        newSize = CGSize.init(width: sourceImage.size.width / tempWidth, height: sourceImage.size.height / tempWidth)
        
    }
        
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        
        newSize = CGSize.init(width: sourceImage.size.width / tempHeight, height: sourceImage.size.height / tempHeight)
        
    }
    
    UIGraphicsBeginImageContext(newSize)
    
    sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    var imageData = UIImageJPEGRepresentation(newImage!, 1.0)
    
    var sizeOriginKB : CGFloat = CGFloat((imageData?.count)!) / 1024.0;
    
    //调整大小
    
    var resizeRate = 0.9;
    
    while (sizeOriginKB > maxSize && resizeRate > 0.1) {
        
        imageData = UIImageJPEGRepresentation(newImage!,CGFloat(resizeRate));
        
        sizeOriginKB = CGFloat((imageData?.count)!) / 1024.0;
        
        resizeRate -= 0.1;
        
    }
    
    return imageData!
    
}


func imagePerspective(usingCI image:UIImage, inputVertex:[CGPoint])->UIImage?{
    let perspectiveC = CIFilter(name: "CIPerspectiveCorrection")
    let ciImage = CIImage(cgImage: (image.cgImage)!)
    perspectiveC?.setValue(ciImage, forKey: kCIInputImageKey)
    perspectiveC?.setValue(CIVector(cgPoint: inputVertex[0]), forKey: "inputTopLeft")
    perspectiveC?.setValue(CIVector(cgPoint: inputVertex[3]), forKey: "inputTopRight")
    perspectiveC?.setValue(CIVector(cgPoint: inputVertex[2]), forKey: "inputBottomRight")
    perspectiveC?.setValue(CIVector(cgPoint: inputVertex[1]), forKey: "inputBottomLeft")
    
    
    let context = CIContext()
    let Oimage = perspectiveC?.outputImage
   // let imageRF = context.createCGImage(Oimage!, from: (Oimage?.extent)!)
    
    return UIImage(ciImage: Oimage!)
}

func imagePerspective(image:UIImage,inputVertex:[CGPoint],outputSize:CGSize)->UIImage?{
    let vector10 = inputVertex[1] - inputVertex[0]
    let vector01 = inputVertex[3] - inputVertex[0]
    let vector11 = inputVertex[2] - inputVertex[0]
    let a1 = (vector10.x * vector11.y/vector10.y - vector11.x)/(vector10.x*vector01.y/vector10.y - vector01.x)
    let a0 = (vector11.y - a1 * vector01.y)/vector10.y
    var pixelArray = [PixelData](repeating: PixelData(r: 255, g: 255, b: 255, a: 255), count: Int(outputSize.height * outputSize.width))
    let modeInHeight = Int(outputSize.height) % 2
    let modeInWidth = Int(outputSize.width) % 2
    for height in 1...Int(outputSize.height)/2{
        for width in 1...Int(outputSize.width)/2{
            let (y0,y1) = calculateMap(a0: a0, a1: a1, height: CGFloat(height * 2), width: CGFloat(width * 2), maxHeight: outputSize.height, maxWidth: outputSize.width)
            let coordInOri = y0 * vector10 + y1 * vector01 + inputVertex[0]
            let (r,g,b,a) = image.getPixelColor(pos: CGPoint(x: coordInOri.x, y: coordInOri.y))
            let pixelData = PixelData(r: r, g: g, b: b, a: a)
            pixelArray[(height * 2 - 1) * Int(outputSize.width) - 1 + width * 2] = pixelData
            pixelArray[(height * 2 - 1 - 1) * Int(outputSize.width) - 1 + width * 2] = pixelData
            pixelArray[(height * 2 - 1) * Int(outputSize.width) - 1 + width * 2 - 1] = pixelData
            pixelArray[(height * 2 - 1 - 1) * Int(outputSize.width) - 1 + width * 2 - 1] = pixelData
            if width == Int(outputSize.width)/2 && modeInWidth != 0{
            pixelArray[(height * 2 - 1 - 1) * Int(outputSize.width) - 1 + width * 2 + 1] = pixelData
            pixelArray[(height * 2 - 1) * Int(outputSize.width) - 1 + width * 2 + 1] = pixelData
            
            }
        }
        if height == Int(outputSize.height)/2 && modeInHeight != 0{
            for width in 1...Int(outputSize.width)/2{
                let (y0,y1) = calculateMap(a0: a0, a1: a1, height: CGFloat(height * 2), width: CGFloat(width * 2), maxHeight: outputSize.height, maxWidth: outputSize.width)
                let coordInOri = y0 * vector10 + y1 * vector01 + inputVertex[0]
                let (r,g,b,a) = image.getPixelColor(pos: CGPoint(x: coordInOri.x, y: coordInOri.y))
                let pixelData = PixelData(r: r, g: g, b: b, a: a)
                pixelArray[(height * 2) * Int(outputSize.width) - 1 + width * 2] = pixelData
                pixelArray[(height * 2) * Int(outputSize.width) - 1 + width * 2 - 1] = pixelData
                if width == Int(outputSize.width)/2 && modeInWidth != 0{
                    pixelArray[(height * 2) * Int(outputSize.width) - 1 + width * 2] = pixelData
                    pixelArray[(height * 2) * Int(outputSize.width) - 1 + width * 2 - 1] = pixelData
                    
                }
            }
        }
    }
    
    
    let image = imageFromBitmap(pixels: pixelArray, width: Int(outputSize.width), height: Int(outputSize.height))
    return image
}

func calculateMap(a0:CGFloat,a1:CGFloat,height:CGFloat,width:CGFloat,maxHeight:CGFloat,maxWidth:CGFloat)->(y0:CGFloat,y1:CGFloat){
    let x0 = height/maxHeight
    let x1 = width/maxWidth
    let fenmu = a0 + (a1 - 1) + (1 - a1) * x0 + (1 - a0) * x1
    let y0 = a0 * x0/fenmu
    let y1 = a1 * x1/fenmu
    return (y0,y1)
}

struct PixelData {
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
    var a: UInt8 = 0
}

func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
    assert(width > 0)
    
    assert(height > 0)
    
    let pixelDataSize = MemoryLayout<PixelData>.size
    assert(pixelDataSize == 4)
    
    assert(pixels.count == Int(width * height))
    
    var data = pixels // Copy to mutable []
    guard let providerRef = CGDataProvider(data: NSData(bytes: &data,
                                                        length: data.count * MemoryLayout<PixelData>.size)
        )
        else { return nil }
    
    let cgimage: CGImage! = CGImage(
        width: Int(width),
        height: Int(height),
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        bytesPerRow: Int(width) * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageByteOrderInfo.orderDefault.rawValue),
        provider: providerRef,
        decode: nil,
        shouldInterpolate: true,
        intent: .defaultIntent
    )
    if cgimage == nil {
        print("CGImage is not supposed to be nil")
        return nil
    }
    return UIImage(cgImage: cgimage)
}
func - (left:CGPoint,right:CGPoint)->CGPoint{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func + (left:CGPoint,right:CGPoint)->CGPoint{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func * (left:CGFloat,right:CGPoint)->CGPoint{
    return CGPoint(x: left * right.x, y: left * right.y)
}

func * (left:CGPoint,right:CGFloat)->CGPoint{
    return CGPoint(x: left.x * right, y: left.y * right)
}

func * (left:CGPoint,right:CGPoint)->CGPoint{
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func / (left:CGPoint,right:CGPoint)->CGPoint{
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

extension UIImage{
    
    /**
     获取图片中的像素颜色值
     
     - parameter pos: 图片中的位置
     
     - returns: 颜色值
     */
    func getPixelColor(pos:CGPoint)->(red:UInt8,green:UInt8,blue:UInt8,alpha:UInt8){
        let pixelData = (self.cgImage!).dataProvider?.data
        let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        let r = data[pixelInfo]
        let g = data[pixelInfo+1]
        let b = data[pixelInfo+2]
        let a = data[pixelInfo+3]
        return (r,g,b,a)
    }
    
}

extension UIView{
    func addBottomLine(){
            let underLine:UIView = UIView(frame:CGRect(x:0,y:self.frame.size.height-0.5,width:self.frame.size.width,height:0.5))
            underLine.backgroundColor = Constant.Color.translusentGray
            self.addSubview(underLine)
        
    }
}

func getRightColorFromLeftGradient(left:UIColor)->UIColor{
    if !left.isDistinct(Constant.Color.blueLeft){return Constant.Color.blueRight}
    else if !left.isDistinct(Constant.Color.redLeft){return Constant.Color.redRight}
    else if !left.isDistinct(Constant.Color.greenLeft){return Constant.Color.greenRight}
    else{
        return .white
    }
}


extension UIViewController {
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}







