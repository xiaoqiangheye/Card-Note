//
//  Palette.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/9.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class Palette: UIView{
    var palette:UIView = UIView()
    var selectedColor:UIColor?
    var parentView:UIView?
    var viewController:UIViewController?
    weak var delegate:PaletteProtocal?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        palette.backgroundColor = .clear
        palette.frame.size = self.frame.size
        palette.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        palette.layer.cornerRadius = palette.frame.height/2
        self.addSubview(palette)
    }
    
    func addColors(_ colors: [UIColor]){
        let radius = Double(self.palette.frame.height/2)/2
        var radian:Double = 0.0
        let eachR = 2 * .pi / Double(colors.count)
        for color in colors{
            let x = radius * cos(radian)
            let y = radius * sin(radian)
            radian += eachR
            let colorView = UIView()
            colorView.frame = CGRect(x: Double(self.palette.frame.width/2) + x, y: Double(self.palette.frame.height/2) + y, width: Double(self.palette.frame.width/4), height: Double(self.palette.frame.width/4))
            colorView.center = CGPoint(x: Double(self.palette.frame.width/2) + x, y: Double(self.palette.frame.height/2) + y)
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = colorView.frame.height/2
            colorView.layer.shadowColor = UIColor.black.cgColor
            colorView.layer.shadowOpacity = 0.5
            colorView.layer.shadowOffset = CGSize(width: 1, height: 1)
            let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.addTarget(self, action: #selector(selectColor))
            colorView.addGestureRecognizer(tapGesture)
            self.palette.addSubview(colorView)
        }
    }
    
    @objc private func selectColor(_ sender:UIGestureRecognizer){
        selectedColor = sender.view?.backgroundColor
        self.isHidden = true
        if parentView != nil{
            parentView?.backgroundColor = selectedColor
        }
        if delegate != nil{
            delegate?.palette?(didSelectColor: (sender.view?.backgroundColor)!)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@objc protocol PaletteProtocal:NSObjectProtocol{
    @objc optional func palette(didSelectColor:UIColor)
}
