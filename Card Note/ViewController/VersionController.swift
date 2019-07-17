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
    var textLabel:UILabel!
    var versionLabel:UILabel!
    var whatsNew:UIButton!
    var exitButton:UIButton!
    override func viewDidLoad() {
        
        
        self.view.backgroundColor = .white
        //exit button
        exitButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        exitButton.setFAIcon(icon: .FATimes, iconSize: 30, forState: .normal)
        exitButton.setTitleColor(.black, for: .normal)
        exitButton.addTarget(self, action: #selector(exitVC), for: .touchDown)
        self.view.addSubview(exitButton)
        
        
        //logo
        let image = UIImage(named: "AppIcon")
        logoImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        logoImage.center.x = self.view.bounds.width/2
        logoImage.center.y = self.view.bounds.height/4*1
        logoImage.image = image
        logoImage.layer.cornerRadius = 10
        logoImage.layer.masksToBounds = true
        
        self.view.addSubview(logoImage)
        
        
        //title
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        textLabel.text = "Canote"
        textLabel.textColor = .black
        textLabel.font = UIFont.boldSystemFont(ofSize: 20)
        textLabel.center.x = self.view.bounds.width/2
        textLabel.textAlignment = .center
        textLabel.frame.origin.y = logoImage.frame.origin.y + logoImage.frame.height + 10
        self.view.addSubview(textLabel)
        
        //version
        versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width*0.8, height: 50))
        versionLabel.text = "Version " + app_version
        versionLabel.numberOfLines = 1
        versionLabel.textColor = .gray
        versionLabel.center.x = self.view.bounds.width/2
        versionLabel.frame.origin.y = logoImage.frame.origin.y + logoImage.frame.height + 50
        
        versionLabel.textAlignment = .center
        self.view.addSubview(versionLabel)
        
        whatsNew = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width*0.4, height: 50))
        whatsNew.setTitle("Check Update", for: .normal)
        whatsNew.addTarget(self, action: #selector(openStore), for: .touchDown)
        whatsNew.setTitleColor(.white, for: .normal)
        whatsNew.backgroundColor = Constant.Color.themeColor
        whatsNew.center.x = self.view.bounds.width/2
        whatsNew.frame.origin.y = versionLabel.frame.origin.y + versionLabel.frame.height+50
        whatsNew.layer.cornerRadius = 10
        self.view.addSubview(whatsNew)
    }
    
    @objc private func exitVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func openStore(){
        let url = URL(string:"itms-apps://itunes.apple.com/app/id1410342694")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(string: key), value)})
}
