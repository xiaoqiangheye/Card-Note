//
//  AccountPlanController.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/10.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift


class AccountPlanController:UIViewController,UIScrollViewDelegate{
    private var scrollView:UIScrollView!
    private var titleLabel:UILabel!
    private var backButton:UIButton!
    private var backGround:UIView!
    private var basicView:AccountPlanView!
    private var premiumView:AccountPlanView!
    private var planLabel:UILabel!
    override func viewDidLoad() {
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:100)
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        self.view.backgroundColor = .white
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width * 0.7, height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.center.y = 50
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "Account Plan"
        self.view.addSubview(titleLabel)
        
        planLabel = UILabel(frame: CGRect(x: 0, y:100, width: UIScreen.main.bounds.width, height: 50))
        planLabel.text = "Current Plan: \(Constant.Configuration.AccountPlan.capitalized)"
        planLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.8)
        planLabel.textAlignment = .center
        planLabel.addBottomLine()
        self.view.addSubview(planLabel)
        
        //set up the account plan page
        basicView = AccountPlanView(plan: .basic)
        basicView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        basicView.frame.origin.y = 160
        self.view.addSubview(basicView)
        
        premiumView = AccountPlanView(plan: .premium)
        premiumView.hero.id = "premium"
        premiumView.frame.origin = CGPoint(x: UIScreen.main.bounds.width/2, y: basicView.frame.origin.y + basicView.frame.height + 50)
        premiumView.center.x = UIScreen.main.bounds.width/2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(premiumTaped))
        premiumView.addGestureRecognizer(tapGesture)
        self.view.addSubview(premiumView)
        
        
        backButton = UIButton(frame: CGRect(x: 10, y: 50, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.center.y = 50
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func premiumTaped(){
        let premium = PremiumController()
        self.present(premium, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    var lastContentOffSetY:CGFloat = 0
    var currentContentOffSetY:CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastContentOffSetY = currentContentOffSetY
        currentContentOffSetY = scrollView.contentOffset.y
        if lastContentOffSetY < currentContentOffSetY{
         
        }else if lastContentOffSetY > currentContentOffSetY{
          
        }
    }
    
    func createAnimation (keyPath: String, toValue: CGFloat) -> CABasicAnimation {
        //创建动画对象
        let scaleAni = CABasicAnimation()
        //设置动画属性
        scaleAni.keyPath = keyPath
        
        //设置动画的起始位置。也就是动画从哪里到哪里。不指定起点，默认就从positoin开始
        scaleAni.toValue = toValue
        
        //动画持续时间
        scaleAni.duration = 0.1;
        
        //动画重复次数
        scaleAni.repeatCount = 1
        
        return scaleAni;
    }
    
}
