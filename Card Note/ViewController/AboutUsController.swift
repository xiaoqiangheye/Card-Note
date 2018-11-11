//
//  AboutUsController.swift
//  Card Note
//
//  Created by Wei Wei on 11/11/18.
//  Copyright © 2018 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class AboutUsController:UIViewController{
    private var header:UILabel!
    private var footer:UILabel!
    private var textView:UITextView!
    
    override func viewDidLoad() {
        let topBackGround = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/6))
        topBackGround.backgroundColor = Constant.Color.themeColor
        header = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        header.font = UIFont(name: "Farah", size: 20)
        header.textColor = .white
        header.text = "Canote"
        header.sizeToFit()
        header.center.x = self.view.center.x
        header.center.y = topBackGround.frame.height/2
        topBackGround.addSubview(header)
        
        
        let middleBackGround = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.9, height: self.view.frame.height/3*2))
        middleBackGround.layer.shadowOpacity = 0.7
        middleBackGround.layer.shadowOffset = CGSize(width: 5, height: 5)
        middleBackGround.layer.shadowColor = Constant.Color.translusentGray.cgColor
        middleBackGround.layer.cornerRadius = 10
        
        textView = UITextView(frame: CGRect(x: 0, y: self.view.frame.height/6, width: self.view.frame.width, height: self.view.frame.height/3*2))
        Cloud.getTerms { [unowned self](string) in
            if string != nil{
                DispatchQueue.main.async {
                self.textView.text = string
                }
            }else{
                DispatchQueue.main.async {
                    self.textView.text = "Something wrong with the Internet."
                    self.textView.textAlignment = .center
                }
            }
        }
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 18)
        middleBackGround.addSubview(textView)
        
        
        let footerBackGround = UIView(frame: CGRect(x: 0, y: self.view.frame.height - self.view.frame.height/6, width: self.view.frame.width, height: self.view.frame.height/6))
        footerBackGround.backgroundColor = Constant.Color.themeColor
        footer = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        footer.font = UIFont.systemFont(ofSize: 20)
        footer.textColor = .white
        footer.text = "© 2018 Canote"
        footer.sizeToFit()
        footer.center.x = self.view.center.x
        footerBackGround.addSubview(footer)
        
        self.view.addSubview(topBackGround)
        self.view.addSubview(middleBackGround)
        self.view.addSubview(footerBackGround)
        
        let exitButton = UIButton(frame: CGRect(x: 20, y: 30, width: 50, height: 50))
        exitButton.setFAIcon(icon: .FATimes, iconSize: 30, forState: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.addTarget(self, action: #selector(exit), for: .touchDown)
        self.view.addSubview(exitButton)
    }
    
    
    @objc private func exit(){
        self.dismiss(animated: true, completion: nil)
    }
}
