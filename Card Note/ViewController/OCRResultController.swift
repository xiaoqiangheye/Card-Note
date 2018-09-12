//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/15.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
class OCRResultController:UIViewController{
    var textView:UITextView!
    var backButton:UIButton!
    var strings = [String]()
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
        titleLabel.text = "Result"
        self.view.addSubview(titleLabel)
        
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
    
        self.textView = UITextView(frame: CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height - 80))
        self.textView.text = ""
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .black
        loadText(strings: strings)
        self.view.addSubview(textView)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadText(strings:[String]){
        for string in strings{
            textView.text.append(string)
            textView.text.append("\n\n")
        }
    }
    
    
    
    
    
    
    
    
    
}
