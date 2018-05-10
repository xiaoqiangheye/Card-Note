//
//  CardViewPanel.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/8.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Spring
import Font_Awesome_Swift
class CardViewPanel:SpringView{
    weak var delegate:CardViewPanelDelegate?
    var controlledView:UIView?
    
   
    @objc func deleteButtonClicked(_ sender:UIButton){
        let panel = sender.superview as! CardViewPanel
        if panel.delegate != nil{
            panel.delegate?.deleteButtonClicked!(sender.superview as! CardViewPanel)
        }
    }
    
    @objc func shareButtonClicked(_ sender:UIButton){
         let panel = sender.superview as! CardViewPanel
        if panel.delegate != nil{
            panel.delegate?.shareButtonClicked!(sender.superview as! CardViewPanel)
        }
    }
    
    class func getSingleCardViewPanel(frame:CGRect)->CardViewPanel{
        let view = CardViewPanel(frame: frame)
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.8
        
        let deleteButton = UIButton()
        deleteButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        deleteButton.center.x = view.frame.width/3
        deleteButton.center.y = view.frame.height/2
        deleteButton.setFAIcon(icon: FAType.FATrashO, forState: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.addTarget(view, action: #selector(deleteButtonClicked), for: .touchDown)
        
        let shareButton = UIButton()
        shareButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        shareButton.center.x = view.frame.width/3 * 2
        shareButton.center.y = view.frame.height/2
        shareButton.setFAIcon(icon: .FAShare, forState: .normal)
        shareButton.setTitleColor(.black, for: .normal)
        shareButton.addTarget(view, action: #selector(shareButtonClicked), for: .touchDown)
        
        view.addSubview(deleteButton)
        view.addSubview(shareButton)
        
        return view
    }
    
   
    
}
