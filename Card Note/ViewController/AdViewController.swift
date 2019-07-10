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
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent("card.txt")
        if !manager.fileExists(atPath: (url?.path)!){
            try? manager.createDirectory(atPath: (url?.deletingLastPathComponent().path)!, withIntermediateDirectories: true, attributes: nil)
            if !manager.createFile(atPath: (url?.path)!, contents: nil, attributes: nil){print("false to create Directory")}
            let cardList = [Card]()
            let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
            do{
                try datawrite.write(to: url!)
            }catch{
                print("fail to add")
            }
        }
        performSegue(withIdentifier: "main", sender: nil)
    }
    
   
}
