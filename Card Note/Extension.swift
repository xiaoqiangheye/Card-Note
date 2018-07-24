//
//  Extension.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/7.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit



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
        return false
    }else if Constant.Configuration.AccountPlan == Constant.AccountPlan.premium.rawValue{
        return true
    }else{
        return false
    }
}






