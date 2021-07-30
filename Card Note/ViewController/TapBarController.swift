//
//  TapBarController.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/8.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
import ChameleonFramework
class TapBarController:UITabBarController{
    override func viewDidLoad() {
        self.tabBar.barTintColor = .white
       // self.tabBar.items![0].setFAIcon(icon: FAType.FAWindowRestore)
       // self.tabBar.items![1].setFAIcon(icon: FAType.FAUsers)
        self.tabBar.items![0].setFAIcon(icon: .FAWindowRestore, size: nil, orientation: .up, textColor: .darkGray, backgroundColor: .clear, selectedTextColor: Constant.Color.blueLeft, selectedBackgroundColor: .clear)
       // self.tabBar.items![1].setFAIcon(icon: FAType.FASearch, size: nil, orientation: .up, textColor: .darkGray, backgroundColor:.clear, selectedTextColor: Constant.Color.blueLeft, selectedBackgroundColor: .clear)
        self.tabBar.items![1].setFAIcon(icon: FAType.FAUser, size: nil, orientation: .up, textColor: .darkGray, backgroundColor:.clear, selectedTextColor: Constant.Color.blueLeft, selectedBackgroundColor: .clear)
    }
}
