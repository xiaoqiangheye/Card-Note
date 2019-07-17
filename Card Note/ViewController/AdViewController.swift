//
//  AddViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/19.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class AdViewController:UIViewController{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performSegue(withIdentifier: "main", sender: nil)
    }
    
   
}
