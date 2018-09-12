//
//  AlertView.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/20.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages
class AlertView:UIView{
    static var currentView:AlertView?
    class func show(_ target: UIView,alert:String){
        let view = MessageView.viewFromNib(layout: .cardView)
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.button?.removeFromSuperview()
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: "Error", body: alert, iconText: "")
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    class func show(error message:String){
        let view = MessageView.viewFromNib(layout: .cardView)
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.button?.removeFromSuperview()
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: "Error", body: message, iconText: "")
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    class func show(alert message: String){
        let view = MessageView.viewFromNib(layout: .cardView)
        // Theme message elements with the warning style.
        view.configureTheme(.warning)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.button?.removeFromSuperview()
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: "Alert", body: message, iconText: "")
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    class func show(success message:String){
        let view = MessageView.viewFromNib(layout: .cardView)
        // Theme message elements with the warning style.
        view.configureTheme(.success)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.button?.removeFromSuperview()
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: "Success", body: message, iconText: "")
        
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
   
   
}
