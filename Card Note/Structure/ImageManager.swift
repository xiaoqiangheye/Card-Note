//
//  ImageManager.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/27.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import SwiftMessages
class ImageManager:NSObject{
    static func writeImageToAlbum(image:UIImage, completionhandler:((Bool)->())?)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc static func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer)
    {
        if let e = error as NSError?
        {
            print(e)
        }
        
        else
        {
            /*
            UIAlertController.init(title: nil,
                                   message: "保存成功！",
                                   preferredStyle: UIAlertControllerStyle.alert).show(viewController, sender: nil);
    */
            
            var config = SwiftMessages.Config()
            
            // Slide up from the bottom.
            config.presentationStyle = .top

            let view = MessageView.viewFromNib(layout: .cardView)
            
            // Theme message elements with the warning style.
            view.configureTheme(.success)
            
            // Add a drop shadow.
            view.configureDropShadow()
            
            // Set message title, body, and icon. Here, we're overriding the default warning
            // image with an emoji character.
        
            view.configureContent(title: "Success", body: "Succeed to Save", iconText: "")
            
            view.button?.isHidden = true
            // Show the message.
            SwiftMessages.show(view: view)
        }
    }
}
