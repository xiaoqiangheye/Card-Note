//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/24.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit


class FloatButton:UIButton{
    weak var delegate:FloatButtonDelegate?
    private var _yBottomOffSet:CGFloat = 0
    var yBottomOffSet:CGFloat{
        get{
            return _yBottomOffSet
        }
        set{
            _yBottomOffSet = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        self.addGestureRecognizer(pan)
    }
    
    
    @objc private func panGesture(gesture:UIPanGestureRecognizer){
        if gesture.state == .began{
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.superview!)
        }else if gesture.state == .changed{
            let transition = gesture.translation(in: self.superview!)
            self.center.x += transition.x
            self.center.y += transition.y
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.superview!)
        }
        else if gesture.state == .cancelled || gesture.state == .ended{
        let fromTop = self.center.y
        let fromBottom = UIScreen.main.bounds.height - self.center.y
        let fromLeft = self.center.x
        let fromRight = UIScreen.main.bounds.width - self.center.x
        var array: Array<CGFloat> = [fromTop,fromBottom,fromLeft,fromRight]
        array.sort(by: {$0 < $1})
            switch array[0]{
            case fromTop:
                UIView.setAnimationCurve(.easeOut)
                UIView.animate(withDuration: 0.2) {
                    self.frame.origin.y = CGFloat(UIDevice.current.Xdistance())
                }
            case fromBottom:
                UIView.setAnimationCurve(.easeOut)
                UIView.animate(withDuration: 0.2) {
                    self.frame.origin.y = UIScreen.main.bounds.height - self.frame.height - self._yBottomOffSet
                }
            case fromLeft:
                UIView.setAnimationCurve(.easeOut)
                UIView.animate(withDuration: 0.2) {
                    self.frame.origin.x = 0
                }
            case fromRight:
                UIView.setAnimationCurve(.easeOut)
                UIView.animate(withDuration: 0.2) {
                     self.frame.origin.x = UIScreen.main.bounds.width - self.frame.width
                    
                }
            default:
                break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        self.addGestureRecognizer(pan)
    }
    
}

@objc protocol FloatButtonDelegate {
    @objc optional func FloatButton(did Move:FloatButton, to: CGPoint, in SuperView:UIView)
}
