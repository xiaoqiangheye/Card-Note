//
//  ProgressBar.swift
//  Card Note
//
//  Created by Wei Wei on 2018/9/13.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class ProgressBar:UIProgressView,UIGestureRecognizerDelegate{
    var slideButton:UIButton!
    weak var delegate:ProGressBarDelegate?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        let point = slideButton.convert(point, from: self)
        if self.slideButton.point(inside: point, with: event){
            return self.slideButton
        }
        return result
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        slideButton = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        slideButton.center.y = self.frame.height/2
        slideButton.layer.shadowColor = Constant.Color.translusentGray.cgColor
        slideButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        slideButton.layer.shadowRadius = 5
        slideButton.layer.shadowOpacity = 0.8
        slideButton.backgroundColor = .white
        slideButton.layer.cornerRadius = 5
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        pangesture.delegate = self
        slideButton.addGestureRecognizer(pangesture)
        self.addSubview(slideButton)
    }
    
    
    @objc private func panned(gesture:UIPanGestureRecognizer){
        if delegate != nil{
            delegate?.progressBar!(panned: self)
        }
        
        if gesture.state == .changed{
            let transition = gesture.translation(in: self)
            if slideButton.center.x < self.frame.width && slideButton.center.x > 0{
            slideButton.center.x += transition.x
            gesture.setTranslation(CGPoint.zero, in: self)
            }else if slideButton.center.x == 0 && transition.x > 0{
            slideButton.center.x += transition.x
            gesture.setTranslation(CGPoint.zero, in: self)
            }else if slideButton.center.x == self.frame.width && transition.x < 0{
            slideButton.center.x += transition.x
            gesture.setTranslation(CGPoint.zero, in: self)
            }
        }else if gesture.state == .ended{
            if slideButton.center.x < 0{
                slideButton.frame.origin.x = 0
            }else if slideButton.center.x > self.frame.width{
                slideButton.frame.origin.x = self.frame.width - slideButton.frame.width
            }
            
            let percent = slideButton.center.x/self.frame.width
            self.setProgress(Float(percent), animated: false)
            if delegate != nil{
                delegate?.progressBar?(didChangeProgress: self.progress)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}


@objc protocol ProGressBarDelegate:NSObjectProtocol{
    @objc optional func progressBar(didChangeProgress progress:Float)
    @objc optional func progressBar(panned progressBar:ProgressBar)
}
