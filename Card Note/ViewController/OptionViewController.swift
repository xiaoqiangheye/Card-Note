//
//  OptionViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/20.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
class OptionViewController:UIViewController,UIScrollViewDelegate{
    private var scrollView = UIScrollView()
    private var titleLabel:UILabel = UILabel()
    private var backButton:UIButton!
    private var cumulatedY:CGFloat = 0
    private var backGround:UIView!
    private var completionHandler = {(string:String) in}
    weak var delegate:OptionViewControllerDelegate?
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        backGround = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        backGround.backgroundColor = Constant.Color.themeColor
        self.view.addSubview(backGround)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        
        backButton = UIButton(frame: CGRect(x: 20, y: UIDevice.current.Xdistance(), width: 50, height: 50))
        backButton.setFAIcon(icon: FAType.FATimes, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        
       
        self.view.addSubview(titleLabel)
        self.view.addSubview(backButton)
        
        scrollView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 100)
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        self.view.addSubview(scrollView)
    }
    
    func setTitle(string:String){
        titleLabel.text = string
    }
    
    func loadOptions(strings:[String],completionHandler:@escaping (String)->()){
        self.completionHandler = completionHandler
        for string in strings{
            let label = UILabel(frame: CGRect(x: 0, y: cumulatedY, width: self.view.frame.width, height: 50))
            label.text = string
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .black
            label.backgroundColor = .white
            label.isUserInteractionEnabled = true
            label.addBottomLine()
            self.scrollView.addSubview(label)
            self.scrollView.contentSize.height += label.frame.height
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            label.addGestureRecognizer(gestureRecognizer)
            cumulatedY += label.frame.height
        }
    }
    
   
    
    
    
    @objc private func tapped(gesture: UITapGestureRecognizer){
        let view = gesture.view as! UILabel
        if delegate != nil{
            delegate?.optionViewController?(optionClicked:view.text as Any)
        }
        completionHandler(view.text!)
        dismissView()
    }
    
    @objc func dismissView(){
        dismiss(animated: true, completion: nil)
    }
}

@objc protocol OptionViewControllerDelegate:NSObjectProtocol{
    @objc optional func optionViewController(optionClicked option:Any)
}
