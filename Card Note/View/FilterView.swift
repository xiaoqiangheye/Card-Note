//
//  FilterView.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/8.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit


class FilterView:UIView,ColorViewDelegate{
    var colors:Set<UIColor> = Set<UIColor>()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func show(from View:UIView){
        let filtedView = FilterView(frame: CGRect(x: 0, y: 0, width: 200, height: 350))
        //color
        let color1 = filtedView.addColorView(color: Constant.Color.blueRight)
        let color2 = filtedView.addColorView(color: Constant.Color.greenRight)
        let color3 = filtedView.addColorView(color: Constant.Color.redRight)
        
        
        
        
        //tag
        
        
        
        //calendar
    }
    
    func addColorView(color:UIColor)->ColorView{
        let colorView = ColorView()
        colorView.frame = CGRect(x: 0, y: 0, width: 30, height:30)
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = colorView.frame.height/2
        colorView.layer.shadowColor = Constant.Color.translusentGray.cgColor
        colorView.layer.shadowOpacity = 0.5
        colorView.layer.shadowOffset = CGSize(width: 0, height: 5)
        colors.insert(color)
        return colorView
    }
    
   
    
    class func getSingleFilterView(){
        
    }
    
    func willBeSelected(colorView: ColorView) {
        colors.insert(colorView.backgroundColor!)
    }
    
    func willBeDeselected(colorView: ColorView) {
        colors.remove(colorView.backgroundColor!)
    }
}


class ColorView:UIView{
    var isSelected:Bool = false
    weak var delegate:ColorViewDelegate?
    convenience init(color:UIColor){
        self.init(frame: CGRect(x: 0, y: 0, width: 30, height:30))
        self.backgroundColor = color
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(colorViewTapped)))
    }
    
    @objc private func colorViewTapped(){
        if isSelected{
            //un selected
            self.isSelected = false
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0
            if delegate != nil{delegate?.willBeDeselected?(colorView: self)}
        }else{
            //select
            self.isSelected = true
            self.layer.borderColor = Constant.Color.blueRight.cgColor
            self.layer.borderWidth = 1
            if delegate != nil{delegate?.willBeSelected?(colorView: self)}
        }
    }
    
}

@objc protocol ColorViewDelegate:NSObjectProtocol{
    @objc optional func willBeSelected(colorView:ColorView)
    @objc optional func willBeDeselected(colorView:ColorView)
}
