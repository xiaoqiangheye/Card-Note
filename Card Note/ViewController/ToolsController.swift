//
//  ToolsController.swift
//  Card Note
//
//  Created by Wei Wei on 7/13/21.
//  Copyright © 2021 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
import MobileCoreServices

class ToolsControllerCell: UIView{
    private var label: UILabel
    private var image: UIImageView
    init(size: CGSize, label:String, icon: FAType) {
        self.label = UILabel(frame: CGRect(x: 60, y: 0, width: size.width - 60, height: 50))
        self.label.center.y = size.height/2
        self.label.textColor = .white
        self.label.text = label
        self.label.textAlignment = .center
        self.image = UIImageView(image: UIImage(icon: icon, size: CGSize(width: 50, height: 50)))
        self.image.setFAIconWithName(icon: icon, textColor: .white)
        image.frame = CGRect(x: 10, y: 0, width: 50, height: 50)
        image.center.y = size.height/2
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.addSubview(self.label)
        self.addSubview(self.image)
        self.backgroundColor = UIColor.init(red: 100/255, green: 176/255, blue: 236/255, alpha: 0.8)
        self.layer.cornerRadius = 10
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToolsController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    private var ocr: ToolsControllerCell!
    private var translate: ToolsControllerCell!
    private var voice: ToolsControllerCell!
    
    
    override func viewDidLoad() {
        /*background*/
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:CGFloat(UIDevice.current.Xdistance()) + 60);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        
        
        self.view.backgroundColor = .white
        let size = CGSize(width: self.view.frame.width/3*2, height: 70)
        ocr = ToolsControllerCell(size: size, label: NSLocalizedString("OCR", comment: ""), icon:FAType.FASearch)
        translate = ToolsControllerCell(size: size, label: NSLocalizedString("Translate", comment: ""), icon:FAType.FALanguage)
        voice = ToolsControllerCell(size: size, label: NSLocalizedString("Voice Translate", comment: ""), icon:FAType.FAMicrophone)
        
        
        translate.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        ocr.center = CGPoint(x: self.view.frame.width/2, y: translate.center.y - 120)
        voice.center = CGPoint(x:self.view.frame.width/2,y: translate.center.y + 120)
        
        self.view.addSubview(ocr)
        self.view.addSubview(translate)
        self.view.addSubview(voice)
        
        let OCRgesture = UITapGestureRecognizer(target: self, action: #selector(addPic))
        ocr.addGestureRecognizer(OCRgesture)
        
        let Trgesture = UITapGestureRecognizer(target: self, action: #selector(goTranslate))
        translate.addGestureRecognizer(Trgesture)
        
        let voiceGesture = UITapGestureRecognizer(target: self, action: #selector(goVoice))
        voice.addGestureRecognizer(voiceGesture)
    }
    
    @objc private func addPic(){
        //check rest recognition
        if(!checkRestRecognition()) {
            popOutWindow()
            return
        }
        
        let alertSheet = UIAlertController(title: "Select From", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromalbum = UIAlertAction(title: "Album", style: .default) { (action) in
            print("Choose from Album")
        
            let vc = self.presentHGImagePicker(maxSelected:1) {[unowned self] (assets) in
                //结果处理
                print("共选择了\(assets.count)张图片，分别如下：")
                for asset in assets {
                    asset.getImage(completionHandler: { (image) in
                        self.goOcr(image: image)
                    })
                }
            }
            
          
        }
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.mediaTypes = [kUTTypeImage as String]
             self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    @objc func goOcr(image: UIImage){
        //check rest recognition
        if(!checkRestRecognition()) {
            popOutWindow()
            return
        }
       
        let vc = OCRController()
        vc.modalPresentationStyle = .fullScreen
        vc.image = image
        self.present(vc, animated: true) {}
    }
    
    @objc func goTranslate(){
        //check rest recognition
        if(!checkRestRecognition()) {
            popOutWindow()
            return
        }
       
        
        let vc = TranslationController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func goVoice(){
        
    }
    
    
    func checkRestRecognition()->Bool{
        let num = UserDefaults.standard.integer(forKey: "num")
        return num > 0
    }
    
    private func popOutWindow(){
        let alertController = UIAlertController(title: NSLocalizedString("used_up", comment: ""),
                                message: NSLocalizedString("used_up_message", comment: ""), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: NSLocalizedString("VIP", comment: ""), style: .default, handler: { action in
                    // go to vip page
                })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
