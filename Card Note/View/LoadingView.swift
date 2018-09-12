//
//  loadingView.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/19.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

private let kScreenW: CGFloat = UIScreen.main.bounds.width
private let kScreenH: CGFloat = UIScreen.main.bounds.height

private let round1Color = UIColor(red: 81/255, green: 188/255, blue: 62/255,alpha:1)
private let round2Color = UIColor(red: 246/255, green: 201/255, blue: 51/255,alpha:1)
private let round3Color = UIColor(red: 225/255, green: 41/255, blue: 34/255,alpha:1)
private let animTime = 1.5
private let animRepeatTime:Float = 50
private let kRoundW: CGFloat = 10

class LoadingView: UIView {
    
    var round1: UIView!
    var round2: UIView!
    var round3: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        let roundOneView: UIView = {
            let roundOne = UIView.init()
            roundOne.frame.size.width = kRoundW
            roundOne.frame.size.height = kRoundW
            roundOne.layer.cornerRadius = kRoundW / 2
            roundOne.backgroundColor = round1Color
            self.round1 = roundOne
            return roundOne
        }()
        
        let roundTwoView: UIView = {
            let roundTwo = UIView.init()
            roundTwo.frame.size.width = kRoundW
            roundTwo.frame.size.height = kRoundW
            roundTwo.layer.cornerRadius = kRoundW / 2
            roundTwo.backgroundColor = round2Color
            self.round2 = roundTwo
            return roundTwo
        }()
        
        let roundThreeView: UIView = {
            let roundThree = UIView.init()
            roundThree.frame.size.width = kRoundW
            roundThree.frame.size.height = kRoundW
            roundThree.layer.cornerRadius = kRoundW / 2
            roundThree.backgroundColor = round3Color
            self.round3 = roundThree
            return roundThree
        }()
        
        self.addSubview(roundOneView)
        self.addSubview(roundTwoView)
        self.addSubview(roundThreeView)
        
        round2.center.x = self.frame.width/2
        round2.center.y = self.frame.height/2
        
        round1.center.x = round2.center.x - 20
        round1.center.y = round2.center.y
        
        round3.center.x = round2.center.x + 20
        round3.center.y = round2.center.y
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
 
 
    
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("销毁了")
    }
}

extension LoadingView {
    // 加载动画在view上
    class func showLoadingWithView(view: UIView) -> LoadingView {
        let loadingView = LoadingView.init(frame: view.bounds)
        view.addSubview(loadingView)
        return loadingView
    }
    
    // 加载动画在Window上
    class func showLoadingWithWindow() -> LoadingView {
        let lastWindow = UIApplication.shared.windows.last
        let loadingView = LoadingView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        lastWindow?.addSubview(loadingView)
        return loadingView
    }
}

// MARK: - 手动影藏动画
extension LoadingView {
    func hideLoadingView() {
        round1.layer.removeAllAnimations()
        round2.layer.removeAllAnimations()
        round3.layer.removeAllAnimations()
        self.removeFromSuperview()
    }
}

// MARK: - 开始动画
extension LoadingView {
    func waitingAnimation(){
        animationStop()
        let path1 = UIBezierPath.init()
        path1.move(to: CGPoint.init(x: round1.center.x, y: round2.center.y))
        path1.addLine(to: CGPoint.init(x: round1.center.x, y: round2.center.y + 5))
        path1.addLine(to: CGPoint.init(x: round1.center.x, y: round2.center.y - 5))
         path1.addLine(to: CGPoint.init(x: round1.center.x, y: round1.center.y))
        let path2 = UIBezierPath.init()
        path2.move(to: CGPoint.init(x: round2.center.x, y: round2.center.y))
        path2.addLine(to: CGPoint.init(x: round2.center.x, y: round2.center.y - 5))
        path2.addLine(to: CGPoint.init(x: round2.center.x, y: round2.center.y + 5))
         path2.addLine(to: CGPoint.init(x: round2.center.x, y: round2.center.y))
        let path3 = UIBezierPath.init()
        path3.move(to: CGPoint.init(x: round3.center.x, y: round2.center.y))
        path3.addLine(to: CGPoint.init(x: round3.center.x, y: round2.center.y + 5))
        path3.addLine(to: CGPoint.init(x: round3.center.x, y: round2.center.y - 5))
         path3.addLine(to: CGPoint.init(x: round3.center.x, y: round3.center.y))
        
        viewMovePathAnim(view: round1, path: path1, time: animTime)
        
        viewMovePathAnim(view: round2, path: path2, time: animTime)
        
        viewMovePathAnim(view: round3, path: path3, time: animTime)
    }
    
    func startAnimation() {
        animationStop()
        let otherRoundCenter1 = CGPoint.init(x: round1.center.x+10, y: round2.center.y)
        let otherRoundCenter2 = CGPoint.init(x: round2.center.x+10, y: round2.center.y)
        
        //圆1的路径
        let path1 = UIBezierPath.init()
        path1.addArc(withCenter: otherRoundCenter1, radius: 10, startAngle: -CGFloat(M_PI), endAngle: 0, clockwise: true)
        
        let path1_1 = UIBezierPath.init()
        path1_1.addArc(withCenter: otherRoundCenter2, radius: 10, startAngle: -CGFloat(M_PI), endAngle: 0, clockwise: false)
        path1.append(path1_1)
        
        viewMovePathAnim(view: round1, path: path1, time: animTime)
        //添加round1的颜色效果
        viewColorAnim(view: round1, fromColor: round1Color, toColor: round3Color, time: animTime)
        
        //添加round2的轨迹
        let path2 = UIBezierPath.init()
        path2.addArc(withCenter: otherRoundCenter1, radius: 10, startAngle: 0, endAngle: -(CGFloat(M_PI)), clockwise: true)
        //添加round2的轨迹动画
        viewMovePathAnim(view: round2, path: path2, time: animTime)
        //圆2的颜色渐变
        viewColorAnim(view: round2, fromColor: round2Color, toColor: round1Color, time: animTime)
        
        //圆3的路径
        let path3 = UIBezierPath.init()
        path3.addArc(withCenter: otherRoundCenter2, radius: 10, startAngle: 0, endAngle: -CGFloat(M_PI), clockwise: false)
        //轨迹动画
        viewMovePathAnim(view: round3, path: path3, time: animTime)
        //颜色动画
        viewColorAnim(view: round3, fromColor: round3Color, toColor: round2Color, time: animTime)
    }
    
    ///动画停止
    
    func animationStop(){
        round1.layer.removeAllAnimations()
        round2.layer.removeAllAnimations()
        round3.layer.removeAllAnimations()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        /*
        round1.layer.removeAllAnimations()
        round2.layer.removeAllAnimations()
        round3.layer.removeAllAnimations()
        //直接销毁
        self.removeFromSuperview()
        */
        
    }
}

// MARK: - CAAnimationDelegate
extension LoadingView: CAAnimationDelegate {
    ///设置view的移动路线，这样抽出来因为每个圆的只有路径不一样
    func viewMovePathAnim(view:UIView,path:UIBezierPath,time:Double) {
        let anim = CAKeyframeAnimation.init(keyPath: "position")
        anim.path = path.cgPath
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.calculationMode = kCAAnimationCubic
        anim.repeatCount = animRepeatTime
        anim.duration = animTime
        anim.delegate = self
        anim.autoreverses = false
       // anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        view.layer.add(anim, forKey: "animation")
    }
    
    ///设置view的颜色动画
    func viewColorAnim(view:UIView,fromColor:UIColor,toColor:UIColor,time:Double) {
        let colorAnim = CABasicAnimation.init(keyPath: "backgroundColor")
        colorAnim.toValue = toColor.cgColor
        colorAnim.fromValue = fromColor.cgColor
        colorAnim.duration = time
        colorAnim.autoreverses = false
        colorAnim.fillMode = kCAFillModeForwards;
        colorAnim.isRemovedOnCompletion = false;
        colorAnim.repeatCount = animRepeatTime
        view.layer.add(colorAnim, forKey: "backgroundColor")
    }
}

