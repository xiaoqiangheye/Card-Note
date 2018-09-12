//
//  AccountSettingController.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/12.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class AccountSettingController:UIViewController,UIScrollViewDelegate{
    var titleLabel:UILabel!
    var backButton:UIButton!
    var scrollView:UIScrollView!
    override func viewDidLoad() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
        
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50))
        self.view.addSubview(scrollView)
        setting()
    }
    
    func setting(){
        
    }
    
    func addSetting(name:String,clicked:()->()){
        
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
