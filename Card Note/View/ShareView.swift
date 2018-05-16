//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/10.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Spring
import UIKit

class ShareView:SpringView{
    var shareBlock = {
        
    }
    var state:[String] = [SharedCard.State.readable.rawValue]
    var branchable = false
    var reprintable = false
    
    @objc private func branch(_ sender:UISwitch){
        if sender.isOn{
        branchable = true
        }else{
        branchable = false
        }
    }
    
    @objc private func reprintable(_ sender:UISwitch){
        if sender.isOn{
        reprintable = true
        }else{
        reprintable = false
        }
    }
    
    @objc private func share(){
        if reprintable{
            state.append(SharedCard.State.reprintable.rawValue)
        }
        if branchable{
            state.append(SharedCard.State.branchable.rawValue)
        }
        shareBlock()
    }
    
    class func show(target:UIView, card:Card)->ShareView{
        var targetView:UIView = target
        while targetView.superview != nil{
            targetView = targetView.superview!
        }
        let view = ShareView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.8))
        view.center.x = UIScreen.main.bounds.width/2
        view.center.y = UIScreen.main.bounds.height/2
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        let title = UILabel(frame: CGRect(x: 0, y: 0, width:100, height: 30))
        title.center.x = view.bounds.width/2
        title.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        title.text = "Share"
        view.addSubview(title)
        title.textAlignment = .center
        
        
        let cardView = CardView.getSingleCardView(card: card)
        cardView.frame.origin.y = 40
        cardView.center.x = view.frame.width/2
        view.addSubview(cardView)
        
        let branchableTitle = UILabel(frame: CGRect(x: 20, y: 40 + cardView.frame.height + 10, width: 300, height: 30))
        branchableTitle.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
        branchableTitle.text = "Allow others to create branches"
        branchableTitle.textColor = .black
        let checkBoxOfBranchable = UISwitch(frame: CGRect(x: 0, y: branchableTitle.frame.origin.y + branchableTitle.frame.height + 10, width: 70, height: 50))
        checkBoxOfBranchable.center.x = view.frame.width/2
        checkBoxOfBranchable.isOn = false
        checkBoxOfBranchable.addTarget(view, action: #selector(branch(_:)), for: UIControlEvents.valueChanged)
        
        let reprintableTitle = UILabel(frame: CGRect(x: 20, y: checkBoxOfBranchable.frame.origin.y + checkBoxOfBranchable.frame.height + 10, width: 300, height: 30))
        reprintableTitle.font = UIFont(name: "ChalkboardSE-Bold", size: 15)
        reprintableTitle.text = "Allow others to reprint"
        reprintableTitle.textColor = .black
        
        let checkBoxOfReprintable = UISwitch(frame: CGRect(x: 20, y: reprintableTitle.frame.origin.y + reprintableTitle.frame.height + 10, width: 70, height: 50))
        checkBoxOfReprintable.isOn = false
        checkBoxOfReprintable.center.x = view.frame.width/2
        checkBoxOfReprintable.addTarget(view, action: #selector(reprintable(_:)), for: .valueChanged)
        
        view.addSubview(branchableTitle)
        view.addSubview(checkBoxOfBranchable)
        view.addSubview(reprintableTitle)
        view.addSubview(checkBoxOfReprintable)
        
        let button = UIButton()
        button.frame = CGRect(x: view.frame.width/2, y:checkBoxOfReprintable.frame.origin.y + checkBoxOfReprintable.frame.height + 10 , width: 100, height: 100)
        button.center.x = view.frame.width/2
        button.setFAIcon(icon: .FAShare, forState: .normal)
        button.setFATitleColor(color: .black)
        button.addTarget(view, action: #selector(share), for: .touchDown)
        view.addSubview(button)
        targetView.addSubview(view)
        
        return view
    }
    
    func cancel(){
        if self.superview != nil{
            self.removeFromSuperview()
        }
    }
    
   
}
