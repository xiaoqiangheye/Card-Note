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
    //var backGround:UIView!
    private var cumulatedHeight:CGFloat = 0
    
    override func viewDidLoad() {
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:100);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        self.view.backgroundColor = .white
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.center.y = 50
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = ""
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
