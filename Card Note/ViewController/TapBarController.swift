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
        let fatype = FAType.init(rawValue: 0)
       // self.tabBar.items![0].setFAIcon(icon: FAType.FAWindowRestore)
       // self.tabBar.items![1].setFAIcon(icon: FAType.FAUsers)
        self.tabBar.items![0].setFAIcon(icon: .FAWindowRestore, size: nil, orientation: .up, textColor: .black, backgroundColor: .clear, selectedTextColor: .red, selectedBackgroundColor: .clear)
       // self.tabBar.items![1].setFAIcon(icon: .FAUsers, size: nil, orientation: .up, textColor: .black, backgroundColor: .clear, selectedTextColor: .red, selectedBackgroundColor: .clear)
        self.tabBar.items![1].setFAIcon(icon: FAType.FAUser, size: nil, orientation: .up, textColor: .black, backgroundColor:.clear, selectedTextColor: UIColor.red, selectedBackgroundColor: .clear)
    
        
    }
}
