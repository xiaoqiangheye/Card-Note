//
//  LoadingViewController.swift
//  Card Note
//
//  Created by Wei Wei on 2018/9/16.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit


class LoadingViewController:UIViewController{
    private var alertLabel:UILabel = UILabel()
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.5)
        alertLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.height * 0.8, height: 100)
        alertLabel.numberOfLines = 2
        if alertLabel.text == nil || alertLabel.text == ""{
        alertLabel.text = "Processing..."
       }
        alertLabel.textColor = .white
        alertLabel.textAlignment = .center
        alertLabel.font = UIFont.boldSystemFont(ofSize: 20)
        alertLabel.center.x = self.view.frame.width/2
        alertLabel.center.y = self.view.frame.height/2
        self.view.addSubview(alertLabel)
    }
    
    func setAlert(_ alert:String){
        alertLabel.text = alert
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
}
