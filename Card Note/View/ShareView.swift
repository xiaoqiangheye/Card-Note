//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/10.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Spring
import UIKit

class ShareView:SpringView{
    var shareBlock = ()->()
    class func show(target:UIView){
        var targetView:UIView = target
        while targetView.superview != nil{
            targetView = targetView.superview!
        }
        let view = ShareView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.center.x = UIScreen.main.bounds.width/2
        view.center.y = UIScreen.main.bounds.height/2
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        let title = UILabel(frame: CGRect(x: 0, y: 0, width:100, height: 30))
        title.center.x = view.bounds.width/2
        title.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        title.text = "Share"
        view.addSubview(title)
        
        let checkBoxOfBranchable = UISwitch(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
        checkBoxOfBranchable.isOn = false
        
        
        let checkBoxOfReprintable = UISwitch(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
        checkBoxOfReprintable.isOn = false
    }
    
    func cancel(){
        if self.superview != nil{
            self.removeFromSuperview()
        }
    }
    
    func share(){
        shareBlock()
    }
}
