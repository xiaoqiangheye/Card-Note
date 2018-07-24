//
//  SwitchSetting.swift
//  Card Note
//
//  Created by 强巍 on 2018/6/24.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import RAMPaperSwitch
import UIKit

class SwitchSetting:UIView{
    var onSwitch = {}
    var offSwitch = {}
    var title:String
    var titleLabel:UILabel
    var descrptionLabel:UITextView
    var color:UIColor
    var paperSwitch:RAMPaperSwitch!
    init(title:String,description:String,tintColor:UIColor,onSwitch:(()->())?,offSwitch:(()->())?) {
        self.title = title
        self.color = tintColor
        if onSwitch != nil{
            self.onSwitch = onSwitch!
        }
        if offSwitch != nil{
            self.offSwitch = offSwitch!
        }
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = title
        
        descrptionLabel = UITextView(frame: CGRect(x: 50, y: 50, width: UIScreen.main.bounds.width-100, height: 100))
        descrptionLabel.backgroundColor = .clear
        descrptionLabel.textAlignment = .center
        descrptionLabel.textColor = .black
        descrptionLabel.text = description
        descrptionLabel.center.x = UIScreen.main.bounds.width/2
        descrptionLabel.isEditable = false
        descrptionLabel.isSelectable = false
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        paperSwitch = RAMPaperSwitch(view: self, color: color)
        paperSwitch.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        paperSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        self.addSubview(titleLabel)
        self.addSubview(descrptionLabel)
        self.addSubview(paperSwitch)
    }
    
    @objc func switchValueChanged(){
        if paperSwitch.isOn{
            onSwitch()
            titleLabel.textColor = .white
            descrptionLabel.textColor = .white
        }else{
            offSwitch()
             titleLabel.textColor = .black
             descrptionLabel.textColor = .black
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
