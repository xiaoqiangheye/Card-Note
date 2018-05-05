//
//  OrientationController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/19.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class OrientationController:UIViewController{
    
    override func viewDidLoad() {
        let signUpView = UserView.signUpView()
        self.view.addSubview(signUpView)
    }
}
