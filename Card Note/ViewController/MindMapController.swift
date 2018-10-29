//
//  MindMapController.swift
//  Card Note
//
//  Created by Wei Wei on 10/5/18.
//  Copyright © 2018 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class MindMapController:UIViewController{
    private var scrollView:UIScrollView!

    override func viewDidLoad() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
}
