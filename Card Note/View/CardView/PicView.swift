//
//  PicView.swift
//  Card Note
//
//  Created by Wei Wei on 7/6/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class PicView:CardView{
    var image:UIImageView = UIImageView()
    var commentView:UITextField = UITextField()
    var ifCommentShowed = false
    var loadingView:LoadingView!
    
    
    override init(card: Card) {
        super.init(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width * 0.8,height: UIScreen.main.bounds.width * 0.8))
        self.card = card
        
        PicView.decorateCardView(view: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func decorateCardView(view:PicView){
        let pic = view.card as! PicCard
        
        view.loadingView = LoadingView(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width * 0.8,height: UIScreen.main.bounds.width * 0.8))
        view.addSubview(view.loadingView)
        view.image.layer.cornerRadius = 15
        view.image.frame.origin = CGPoint(x:0,y:0)
        view.image.frame.size = view.frame.size
        view.image.backgroundColor = .clear
        view.image.alpha = 1
        view.addSubview(view.image)
        
        view.layer.cornerRadius = 15
        view.backgroundColor = .clear
        
        if pic.pic != nil{
            let x = pic.pic.size.width
            let y = pic.pic.size.height
            let ratio = UIScreen.main.bounds.width*0.8/x
            let changedy = y * ratio
            view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: changedy)
            view.image.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width * 0.8, height: changedy)
            view.image.image = pic.pic
        }
        
        view.center.x = UIScreen.main.bounds.width/2
        view.layer.shadowColor = Constant.Color.translusentGray.cgColor
        view.image.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.image.layer.shadowOpacity = 0.5
        view.commentView.frame = CGRect(x: 0, y: view.image.frame.height, width:  UIScreen.main.bounds.width * 0.8, height: 40)
        view.commentView.backgroundColor = .clear
        view.commentView.font = UIFont.systemFont(ofSize: 20)
        view.commentView.textColor = .black
        view.commentView.text = pic.getDescription()
        view.commentView.textAlignment  = .center
        view.addSubview(view.commentView)
        if pic.getDescription() == ""{
            view.commentView.isHidden = true
            view.ifCommentShowed = false
        }else{
            view.frame.size.height += 20
            view.ifCommentShowed = true
        }
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.addTarget(view, action: #selector(view.menuController))
        view.addGestureRecognizer(longTapGesture)
    }
    
    
    
    
    
    
    
    @objc override func share() {
        let alertView = SCLAlertView()
        var url = Constant.Configuration.url.PicCard
        url.appendPathComponent(self.card.getId() + ".jpg")
        if !FileManager.default.fileExists(atPath: url.path){
            AlertView.show(alert: "Picture has not been loaded or is damaged.")
            return
        }
        alertView.addButton("Generate Picture") {
            let shareView = SCLAlertView()
            shareView.addButton("To Other Apps", action: {
                self.docController = UIDocumentInteractionController.init(url:url)
                self.docController.uti = "public.jpeg"
                self.docController.delegate = self
                // controller.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
                self.docController.presentOpenInMenu(from: CGRect.zero, in: self, animated: true)
            })
            
            shareView.addButton("To Album", action: {
                ImageManager.writeImageToAlbum(image: self.image.image!, completionhandler: nil)
            })
            shareView.showSuccess("Success", subTitle: "Let's share!")
        }
        alertView.showNotice("Sharing", subTitle: "It's nice to share!")
    }
    
    @objc override func menuController(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            self.becomeFirstResponder()
            uimenu = UIMenuController.shared
            uimenu.arrowDirection = .default
            uimenu.menuItems = [UIMenuItem(title: "Move", action: #selector(self.editMode)),UIMenuItem(title: "FootNote", action: #selector(self.addComment)),UIMenuItem(title: "Hide FootNote", action: #selector(self.hideComment)),UIMenuItem(title: "Delete", action: #selector(self.deleteCard)),UIMenuItem(title: "Extract Text", action: #selector(self.extractText)),UIMenuItem(title: "Share", action: #selector(self.share))]
            uimenu.setTargetRect(self.bounds, in: self)
            uimenu.setMenuVisible(true, animated: true)
            
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(self.deleteCard)){
            return true
        }else if(action == #selector(self.addComment)) && !ifCommentShowed{
            return true
        }else if (action == #selector(self.hideComment)) && ifCommentShowed{
            return true
        }else if (action == #selector(self.extractText)){
            return true
        }else if action == #selector(self.editMode){
            return true
        }else if action == #selector(self.share){
            return true
        }else{
            return false
        }
    }
    
    @objc func extractText(){
        delegate?.picView!(extractText:self)
    }
    
    @objc func addComment(){
        ifCommentShowed = true
        self.frame.size.height += 20
        commentView.isHidden = false
        if delegate != nil{
            delegate?.cardView!(commentShowed: self)
        }
        
    }
    
    @objc func hideComment(){
        ifCommentShowed = false
        self.frame.size.height -= 20
        commentView.isHidden = true
        if delegate != nil{
            delegate?.cardView!(commentHide: self)
        }
    }
    
    func loadPic(){
        var url = Constant.Configuration.url.PicCard
        url.appendPathComponent(self.card.getId() + ".jpg")
        self.loadingView.isHidden = false
        self.loadingView.startAnimation()
        /*
         User.downloadPhotosUsingQCloud(cardID: self.card.getId()) { (bool, error) in
         if bool{
         DispatchQueue.main.async {
         (self.card as! PicCard).pic = UIImage(contentsOfFile: (url.path))
         self.image.image = UIImage(contentsOfFile: (url.path))
         }
         print("load picture success; cardId\(self.card.getId())")
         }
         }
         */
        Cloud.downloadAsset(id: self.card.getId(), type: "IMAGE") { [weak self](bool, error) in
            if bool{
                self?.loadingView.isHidden = false
                DispatchQueue.main.async {
                    if(self != nil){
                        let image = UIImage(contentsOfFile: url.path)
                        print("load picture success, cardId\(self!.card.getId())")
                        let x = image!.size.width
                        let y = image!.size.height
                        let ratio = UIScreen.main.bounds.width*0.8/x
                        let changedy = y * ratio
                        self!.frame.size = CGSize(width: UIScreen.main.bounds.width * 0.8, height: changedy)
                        self!.image.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: changedy)
                        self?.image.image = image
                        self!.center.x = UIScreen.main.bounds.width/2
                    }else{
                        print("image UI delocated.")
                        DispatchQueue.main.async {
                            AlertView.show(error: "Failed to load the picture.")
                        }
                    }
                }
            }
        }
    }
    
}
