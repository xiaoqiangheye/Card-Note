//
//  FilterView.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/8.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
@objc protocol FilterViewDelegate:NSObjectProtocol{
    @objc func filterViewFilterClicked(constraints:[Constraint])
    @objc optional func filterViewDidExit()
}

class FilterView:UIView,ColorViewDelegate,TagInputViewDelegate{
    private var colors:Set<UIColor>
    private var tags:Set<String>
    weak var delegate:FilterViewDelegate?
    override init(frame: CGRect) {
        colors = Set<UIColor>()
        tags = Set<String>()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color:Set<UIColor>,tag:Set<String>){
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.7))
        self.colors = Set<UIColor>(color)
        self.tags = Set<String>(tag)
        decorate()
    }
    
    convenience init(){
        self.init(frame: CGRect(x: 0, y: 0, width: 300, height: 350))
        decorate()
    }
    
    private func decorate(){
        self.layer.cornerRadius = 20
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
        
        //exit
        let exit = UIButton(frame: CGRect(x: self.bounds.width - 50, y: 0, width: 50, height: 50))
        exit.setFAIcon(icon: .FATimes, iconSize: 30, forState: .normal)
        exit.setTitleColor(.black, for: .normal)
        exit.addTarget(self, action: #selector(hide), for: .touchDown)
        self.addSubview(exit)
        
        //color
        let color1 = self.addColorView(color: Constant.Color.blueRight)
        color1.center = CGPoint(x: self.frame.width/6, y: 50)
        let color2 = self.addColorView(color: Constant.Color.greenRight)
        color2.center = CGPoint(x: self.frame.width/6*3, y: 50)
        let color3 = self.addColorView(color: Constant.Color.redRight)
        color3.center = CGPoint(x: self.frame.width/6*5, y: 50)
        let colorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        colorLabel.font = UIFont.boldSystemFont(ofSize: 20)
        colorLabel.text = "Color"
        colorLabel.center.x = 100
        colorLabel.textAlignment = .center
       //self.addSubview(colorLabel)
        self.addSubview(color1)
        self.addSubview(color2)
        self.addSubview(color3)
        
        
        //tag
        let tagLabgel = UILabel(frame: CGRect(x: 10, y: 100, width: 100, height: 30))
        tagLabgel.font = UIFont.boldSystemFont(ofSize: 20)
        tagLabgel.text = "Tags"
        tagLabgel.textAlignment = .left
        self.addSubview(tagLabgel)
        
        let tag = TagInputView(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width * 0.6, height: 50), tags: [String]())
        tag.center.x = self.bounds.width/2
        tag.delegate = self
        tag.plusButton.setTitleColor(Constant.Color.blueLeft, for: .normal)
        self.addSubview(tag)
        
        //filter
        let filter = UIButton(frame: CGRect(x: 0, y: 250, width: 50, height: 50))
        filter.backgroundColor = Constant.Color.blueRight
        filter.setFAIcon(icon: .FASearch, iconSize: 30, forState: .normal)
        filter.addTarget(self, action: #selector(filterClicked), for: .touchDown)
        filter.setTitleColor(.white, for: .normal)
        filter.center.x = self.bounds.width/2
        filter.layer.cornerRadius = 25
        self.addSubview(filter)
    }
    
    @objc private func filterClicked(){
        var constraints = [Constraint]()
        for color in colors{
            let constraint = Constraint(.color, color)
            constraints.append(constraint)
        }
        
        for tag in tags{
            let constraint = Constraint(.tag, tag)
            constraints.append(constraint)
        }
        
        if delegate != nil{
            delegate?.filterViewFilterClicked(constraints: constraints)
        }
        
        self.isHidden = true
    }
    
    @objc private func hide(){
        self.isHidden = true
        if (delegate != nil){
            delegate?.filterViewDidExit!()
        }
    }
    
    private func addColorView(color:UIColor)->ColorView{
        let colorView = ColorView(color: color)
        colorView.layer.cornerRadius = colorView.frame.height/2
        colorView.layer.shadowColor = Constant.Color.translusentGray.cgColor
        colorView.layer.shadowOpacity = 0.5
        colorView.layer.shadowOffset = CGSize(width: 0, height: 5)
        colorView.delegate = self
        return colorView
    }
    
    func getColors()->Set<UIColor>{
        return colors
    }
    
    func getTags()->Set<String>{
        return tags
    }
    
    func getConstrait()->[Constraint]{
        var constraints = [Constraint]()
        for value in colors{
            constraints.append(Constraint(.color, value))
        }
        
        for value in tags{
             constraints.append(Constraint(.tag, value))
        }
        return constraints
    }
    
    class func getSingleFilterView(){
        
    }
    
    func willBeSelected(colorView: ColorView) {
        colors.insert(colorView.backgroundColor!)
    }
    
    func willBeDeselected(colorView: ColorView) {
        colors.remove(colorView.backgroundColor!)
    }
    
    func tagDidFinishAdding(tag: String) {
        tags.insert(tag)
    }
    
    func tagDidFinishRemoving(tag: String) {
        tags.remove(tag)
    }
    
    
}


class ColorView:UIView{
    var isSelected:Bool = false
    weak var delegate:ColorViewDelegate?
    
    convenience init(color:UIColor){
        self.init(frame: CGRect(x: 0, y: 0, width: 30, height:30))
        self.backgroundColor = color
        let gesture = UITapGestureRecognizer(target: self, action: #selector(colorViewTapped(gesture:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(gesture)
    }
    
    //change the status of the colorview when tapped
    @objc private func colorViewTapped(gesture:UITapGestureRecognizer){
        if gesture.state == .recognized{
           changeStatus()
        }
    }
    
    //change the status of the color view, will be selected if unslected and vice versa.
    private func changeStatus()
    {
        if isSelected{
            //un selected
            self.isSelected = false
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 1
            if delegate != nil{delegate?.willBeDeselected?(colorView: self)}
        }else{
            //select
            self.isSelected = true
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 2
            if delegate != nil{delegate?.willBeSelected?(colorView: self)}
        }
    }
    
    //@param:null
    //select the given colors
    func select(){
        changeStatus()
    }
    
    //diselect the given colors
    //@param:color
    //select the given color
    func diSelect(color:UIColor){
        changeStatus()
    }
    
}

@objc protocol ColorViewDelegate:NSObjectProtocol{
    @objc optional func willBeSelected(colorView:ColorView)
    @objc optional func willBeDeselected(colorView:ColorView)
}
