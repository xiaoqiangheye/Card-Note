//
//  AlertView.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/20.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class AlertView:UIView{
    static var currentView:AlertView?
    
    @objc func dismiss(_ sender:UIButton){
        sender.superview?.removeFromSuperview()
    }
    
    class func show(_ target: UIView,alert:String){
        var targetView:UIView = target
        while targetView.superview != nil{
            targetView = targetView.superview!
        }
        
        let alertView = AlertView()
        alertView.backgroundColor = .white
        alertView.frame.size = CGSize(width:UIScreen.main.bounds.width,height:100)
        alertView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        let label = UILabel()
        label.frame.size = CGSize(width:UIScreen.main.bounds.width,height:30)
        label.center = CGPoint(x: alertView.frame.width/2, y: alertView.frame.height/2)
        label.text = alert
        label.textColor = .red
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        alertView.addSubview(label)
        let exitButton = UIButton()
        exitButton.setTitle("X", for: .normal)
        exitButton.setTitleColor(.gray, for: .normal)
        exitButton.frame.size = CGSize(width:30,height:30)
        exitButton.addTarget(alertView, action: #selector(dismiss), for: .touchDown)
        alertView.addSubview(exitButton)
        targetView.addSubview(alertView)
        currentView = alertView
    }
    
   
   
}
