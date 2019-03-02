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
        titleLabel = UILabel(frame: CGRect(x: 0, y: UIDevice.current.Xdistance(), width: Int(UIScreen.main.bounds.width), height: 50))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = "Account Plan"
        titleLabel.addBottomLine(width:2,color:.black)
        self.view.addSubview(titleLabel)
        
        backButton = UIButton(frame: CGRect(x: 10, y: UIDevice.current.Xdistance(), width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FAChevronCircleLeft, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        self.view.bringSubview(toFront: backButton)
        
        planLabel = UILabel(frame: CGRect(x: 0, y:titleLabel.frame.origin.y + titleLabel.frame.height, width: UIScreen.main.bounds.width, height: 50))
        planLabel.textColor = .black
        planLabel.backgroundColor = .white
        planLabel.textAlignment = .center
        planLabel.addBottomLine(width:2,color:.black)
        self.view.addSubview(planLabel)
        
        
        let resoreButton = UIButton(frame: CGRect(x: 0, y:planLabel.frame.origin.y + planLabel.frame.height, width: UIScreen.main.bounds.width, height: 50))
        resoreButton.setTitle("RESTORE", for: .normal)
        resoreButton.titleLabel?.textAlignment = .left
        resoreButton.backgroundColor = .white
        resoreButton.setTitleColor(.black, for: .normal)
        resoreButton.setTitleColor(Constant.Color.translusentGray, for: .focused)
        resoreButton.addTarget(self, action: #selector(restore), for: .touchDown)
        resoreButton.addBottomLine(width: 2, color: .black)
        self.view.addSubview(resoreButton)
        
        let premium = UIButton(frame: CGRect(x: 0, y:resoreButton.frame.origin.y + resoreButton.frame.height, width: UIScreen.main.bounds.width, height: 50))
        premium.setTitle("PREMIUM", for: .normal)
        premium.backgroundColor = .white
        premium.setTitleColor(.black, for: .normal)
        premium.setTitleColor(Constant.Color.translusentGray, for: .focused)
        premium.addTarget(self, action: #selector(premiumTaped), for: .touchDown)
        self.view.addSubview(premium)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        planLabel.text = "CURRENT:   \(Constant.Configuration.AccountPlan.uppercased())"
    }
    
    @objc func restore(){
        PurchaseManager.restore()
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
