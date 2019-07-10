//
//  VersionController.swift
//  Card Note
//
//  Created by Wei Wei on 7/10/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit



class VersionController:UIViewController{
    //--------Logo------------
    //version:--------
    //What's New:----------
    
    
    var logoImage:UIImageView!
    var versionLabel:UILabel!
    var whatsNew:UIButton!
    
    override func viewDidLoad() {
        
        
        self.view.backgroundColor = .white
        
        //logo
        let image = UIImage(named: "logo")
        logoImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        logoImage.center.x = self.view.bounds.width/2
        logoImage.center.y = self.view.bounds.height/4*1
        logoImage.image = image
        self.view.addSubview(logoImage)
        
        versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width*0.8, height: 50))
        versionLabel.text = "Version" + app_version
        versionLabel.numberOfLines = 1
        versionLabel.textColor = .gray
        versionLabel.center.x = self.view.bounds.width/2
        versionLabel.frame.origin.y = logoImage.frame.origin.y + logoImage.frame.height + 50
        self.view.addSubview(versionLabel)
        
        whatsNew = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width*0.8, height: 50))
        whatsNew.setTitle("Check Update", for: .normal)
        whatsNew.addTarget(self, action: #selector(openStore), for: .touchDown)
    }
    
    @objc private func openStore(){
        let url = URL(string:"itms-apps://itunes.apple.com/app/id444934666")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}
