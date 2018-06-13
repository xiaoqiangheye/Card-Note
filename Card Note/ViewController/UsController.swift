//
//  UsController.swift
//  Card Note
//
//  Created by 强巍 on 2018/6/8.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class UsController:UIViewController,UITextFieldDelegate{
    var searchTextView = SearchBar()
    override func viewDidLoad() {
    let y:Int = UIDevice.current.Xdistance()
    searchTextView.frame = CGRect(x: 40, y: y, width: Int(UIScreen.main.bounds.width-80), height: 40)
    self.view.addSubview(searchTextView)
    self.view.bringSubview(toFront: searchTextView)
    searchTextView.searchTextView.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
