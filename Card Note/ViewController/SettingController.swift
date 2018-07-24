//
//  SettingController.swift
//  Card Note
//
//  Created by 强巍 on 2018/6/24.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Font_Awesome_Swift

class SettingController:UIViewController{
    var scrollView:UIScrollView!
    var titleLabel:UILabel!
    var backButton:UIButton!
    private var cumulatedHeight:CGFloat = 0
    
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
        
    }
    
    @objc private func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setTitle(_ title:String){
        if titleLabel != nil{
            titleLabel.text = title
        }
    }
    
    func addSettingView(view:UIView){
        view.frame.origin.y = cumulatedHeight
         cumulatedHeight += view.bounds.height
        self.scrollView.addSubview(view)
    }
}
