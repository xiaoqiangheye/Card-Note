//
//  ImageController.swift
//  Card Note
//
//  Created by Wei Wei on 10/9/18.
//  Copyright © 2018 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class ImageController:UIViewController{
    var image:UIImage!
    private var imageView:UIImageView!
    private var isViewDidLoadCalled:Bool = false
    private var selectButton:UIButton!
    private var recognizeTextButton:UIButton!
    private var cancelButton:UIButton!
    var imageBlock:((UIImage)->())?
    override func viewDidLoad() {
        self.view.backgroundColor = Constant.Color.translusentGray
        imageView = UIImageView()
        imageView.hero.id = "image"
        imageView.center = self.view.center
        isViewDidLoadCalled = true
        
        //button
        selectButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        selectButton.setFAIcon(icon: .FACheck, iconSize:30, forState: .normal)
        selectButton.setTitleColor(Constant.Color.themeColor, for: .normal)
        selectButton.layer.cornerRadius = 25
        selectButton.backgroundColor = .white
        selectButton.center.x = self.view.center.x/4*1
        selectButton.center.y = self.view.center.y * 1.2
        selectButton.addTarget(self, action: #selector(loadBlock), for: .touchDown)
        
        //cancelButton
        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        cancelButton.setFAIcon(icon: .FATimes, iconSize:30, forState:.normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.cornerRadius = 25
        cancelButton.backgroundColor = .white
        cancelButton.center.x = self.view.center.x/4*2
        cancelButton.center.y = self.view.center.y * 1.2
        
        //recognizeButton
        recognizeTextButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        recognizeTextButton.setFAIcon(icon: .FASearch, iconSize:30, forState: .normal)
        recognizeTextButton.setTitleColor(Constant.Color.themeColor, for: .normal)
        recognizeTextButton.layer.cornerRadius = 25
        recognizeTextButton.backgroundColor = .white
        recognizeTextButton.center.x = self.view.center.x/4*3
        recognizeTextButton.center.y = self.view.center.y * 1.2
        recognizeTextButton.addTarget(self, action: #selector(loadOCR), for: .touchDown)
        
        
        self.view.addSubview(imageView)
        self.view.addSubview(selectButton)
        self.view.addSubview(cancelButton)
        self.view.addSubview(recognizeTextButton)
    }
    
    
    func loadImage(OKClicked:@escaping (UIImage)->()){
        if !isViewDidLoadCalled{
            print("Unload View")
            return
        }
        
        imageBlock = OKClicked
        
        let width = image.size.width
        let height = image.size.height
        let widthRatioToView = width/(self.view.frame.width * 0.9)
        let heightRatioToView = height/(self.view.frame.height * 0.9)
        if widthRatioToView > 1 || heightRatioToView > 1{
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width / max(widthRatioToView, heightRatioToView), height: image.size.height / max(widthRatioToView, heightRatioToView))
        }else{
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }
        
        imageView.image = image
    }
    
    @objc private func loadBlock(){
        if imageBlock != nil{
            imageBlock!(imageView.image!)
        }
    }
    
    @objc private func loadOCR(){
        let vc = OCRController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true){[unowned self] in
            vc.loadPic(pic: self.image)
        }
    }
}
