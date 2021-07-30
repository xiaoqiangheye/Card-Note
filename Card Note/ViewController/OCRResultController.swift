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
    var copyButton:UIButton!
    var strings = [String]()
    override func viewDidLoad() {
        let gl = CAGradientLayer.init()
        var height:CGFloat = 100
        if UIDevice.current.isX(){height = 120}
        self.view.backgroundColor = .white
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:height)
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        self.view.backgroundColor = .white
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.center.y = height/2
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "Result"
        self.view.addSubview(titleLabel)
        
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.center.y = height/2
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        
        copyButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 30 - 10, y: 50, width: 30, height: 30))
        copyButton.center.y = height/2
        copyButton.setFAIcon(icon: .FACopy, iconSize:20, forState: .normal)
        copyButton.setTitleColor(.black, for: .normal)
        copyButton.backgroundColor = .white
        copyButton.addTarget(self, action: #selector(copyText), for: .touchDown)
        copyButton.layer.cornerRadius = 15
        
    
        self.textView = UITextView(frame: CGRect(x: 0, y: height, width: self.view.frame.width, height: self.view.frame.height - 80))
        self.textView.text = ""
        self.textView.backgroundColor = .white
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .black
        loadText(strings: strings)
        self.view.addSubview(textView)
        self.view.addSubview(backButton)
        self.view.addSubview(copyButton)
        self.view.bringSubview(toFront: backButton)
    }
    
    @objc func copyText(){
         UIPasteboard.general.string = textView.text
         AlertView.show(success: "Text Copied.")
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
