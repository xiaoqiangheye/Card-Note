//
//  ClassController.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/31.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
import Spring
class ClassController:UIViewController,UIScrollViewDelegate{
    var scrollView:UIScrollView!
    var tagList = [TagView]()
    override func viewDidAppear(_ animated: Bool) {
        loadTags()
    }
    
    override func viewDidLoad() {
        
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:CGFloat(UIDevice.current.Xdistance()) + 60);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.view.layer.addSublayer(gl)
        
        loadTopBar()
        loadTags()
    }
    
    private func loadTopBar(){
       let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width*0.7, height: (CGFloat(UIDevice.current.Xdistance() + 60)/2)))
        titleLabel.center.x = UIScreen.main.bounds.width/2
        titleLabel.center.y = 50
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.text = "TAGS"
        self.view.addSubview(titleLabel)
        
       let addButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 50, y: 50, width: 30, height: 30))
        addButton.center.y = 50
        addButton.setFAIcon(icon: .FAPlus, iconSize: 30, forState: .normal)
        addButton.setFATitleColor(color: .white)
        addButton.addTarget(self, action: #selector(addTag), for: .touchDown)
        self.view.addSubview(addButton)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 100))
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        
        self.view.addSubview(scrollView)
    }
    
    
    func reload(){
        var cumulatedHeight:CGFloat = 20
         UIView.animate(withDuration: 0.2) {
            for tag in self.tagList{
            tag.frame.origin.y = cumulatedHeight
            cumulatedHeight += 100 + 20
            self.scrollView.contentSize.height = tag.frame.origin.y + tag.frame.height + 20
            }
         }
    }
    
    func loadTags(){
        if scrollView.subviews.count > 0{
            for subView in scrollView.subviews{
                subView.removeFromSuperview()
            }
        }
    
        let tags = UserDefaults.standard.array(forKey: Constant.Key.Tags)
        var cumulatedHeight:CGFloat = 20
        for tag in tags!{
            let tagView = TagView(frame: CGRect(x: 0, y: cumulatedHeight, width: self.view.frame.width, height: 100), tag: tag as! String)
            tagList.append(tagView)
            let deleteButton = DeleteView(frame: CGRect(x: 0, y: 0, width: tagView.frame.width, height: tagView.frame.height))
            deleteButton.frame.origin.x = tagView.frame.width
            tagView.addSubview(deleteButton)
            
            let swipeLeft = UISwipeGestureRecognizer(target: tagView, action: #selector(tagView.swiped))
            swipeLeft.direction = .left
            tagView.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: tagView, action: #selector(tagView.swiped(gesture:)))
            swipeRight.direction = .right
            tagView.addGestureRecognizer(swipeRight)
            tagView.delegate = self
            tagView.deleteView = deleteButton
            let tapGesture = UITapGestureRecognizer(target: tagView, action: #selector(tagView.deleteButtonClicked))
            deleteButton.addGestureRecognizer(tapGesture)
            tagView.center.x = self.view.frame.width/2
            self.scrollView.addSubview(tagView)
            cumulatedHeight += 100 + 20
            scrollView.contentSize.height = tagView.frame.origin.y + tagView.frame.height + 20
        }
    }
    
    
    
    @objc func addTag(){
       let addTagView = AddTagView.show(superView: self.view)
        addTagView.addTagCompletionHandler = {[unowned self] tag in
            self.loadTags()
        }
    }
    
    
    
}

extension ClassController:TagViewDelegate{
    func tagView(didDelete tagView: TagView, tag: String) {
        var index = 0
        for tagV in tagList{
            if tagV == tagView{
                tagList.remove(at: index)
                break
            }
            index += 1
        }
        loadTags()
    }
}

@objc protocol TagViewDelegate:NSObjectProtocol{
    @objc optional func tagView(didDelete tagView:TagView, tag: String)
}

class TagView:UIView{
    weak var delegate:TagViewDelegate?
    private var tagLabel:UILabel
    private var tagString:String
    var deleteView:SpringView?
    init(frame: CGRect,tag:String,colors:UIColor...) {
        tagLabel = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width-40, height: frame.height))
        tagString = tag
        super.init(frame: frame)
        tagLabel.text = "#" + tag
        tagLabel.font = UIFont.systemFont(ofSize: 20)
        tagLabel.textColor = .black
        tagLabel.backgroundColor = .clear
        self.backgroundColor = .white
        tagLabel.textAlignment = .center
        self.addSubview(tagLabel)
        self.backgroundColor = .white
       // self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.shadowColor = Constant.Color.translusentGray.cgColor                                                                                                             
        self.layer.shadowOffset = CGSize(width:0,height:5)
        self.layer.shadowOpacity = 0.5
    }
    
    init(frame:CGRect,tag:String,color:UIColor,textColor:UIColor){
        tagLabel = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width-40, height: frame.height))
        tagString = tag
        super.init(frame: frame)
        tagLabel.text = "#" + tag
        tagLabel.font = UIFont.systemFont(ofSize: 20)
        tagLabel.textColor = .white
        self.backgroundColor = Constant.Color.themeColor
        let gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.frame.width,height:self.frame.height);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        self.layer.addSublayer(gl)
        tagLabel.textAlignment = .center
        //self.addBottomLine()
        self.addSubview(tagLabel)
       // self.backgroundColor = .white
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.shadowColor = Constant.Color.blueLeft.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
    }
    
    @objc func deleteButtonClicked()
    {
        //delete
        self.removeFromSuperview()
        var tags = UserDefaults.standard.array(forKey: Constant.Key.Tags)
        var index = 0
        for tag in tags!{
            if tag as! String == tagString{
                tags?.remove(at: index)
                break
            }
            index += 1
        }
        UserDefaults.standard.set(tags, forKey: Constant.Key.Tags)
        UserDefaults.standard.synchronize()
        if delegate != nil{
            delegate?.tagView?(didDelete: self, tag: (self.tagLabel.text)!)
        }
    }
    
    @objc func swiped(gesture:UISwipeGestureRecognizer){
        if self.deleteView != nil && gesture.direction == .left && self.deleteView?.frame.origin.x == self.frame.width{
            deleteView?.animation = "slideLeft"
            deleteView?.curve = "easeIn"
            self.deleteView?.frame.origin.x = 0
            deleteView?.x = self.frame.width
            deleteView?.y = 0
            deleteView?.animate()
            deleteView?.animateNext {
                self.deleteView?.frame.origin.x = 0
            }
        }else if self.deleteView != nil && gesture.direction == .right && self.deleteView?.frame.origin.x == 0{
            deleteView?.animation = "slideRight"
            deleteView?.curve = "easeOut"
            self.deleteView?.frame.origin.x = self.frame.width
            deleteView?.x = 0
            deleteView?.y = 0
            deleteView?.animate()
            deleteView?.animateNext {
                self.deleteView?.frame.origin.x = self.frame.width
            }
        }
    }
    
    func setTag(_ tag: String){
        tagLabel.text = "#" + tag
        tagString = tag
    }
    
    func getTag()->String{
        return tagString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DeleteView:SpringView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Delete"
        label.font = UIFont.systemFont(ofSize: 20)
        self.backgroundColor = .red
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class AddTagView:UIView{
    var tagTextField = UITextField()
    var addTagCompletionHandler:(String)->() = {tag in}
    var addTagCancelledHandler = {}
    class func show(superView:UIView)->AddTagView{
        let addTagView = AddTagView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        addTagView.center.x = superView.frame.width/2
        addTagView.center.y = superView.frame.height/2
        addTagView.backgroundColor = .white
        addTagView.layer.shadowColor = Constant.Color.translusentGray.cgColor
        addTagView.layer.shadowOffset = CGSize(width: 0, height: 5)
        addTagView.layer.shadowOpacity = 0.5
        addTagView.layer.shadowRadius = 10
        addTagView.layer.cornerRadius = 15
        
        let titleLabel =  UILabel(frame: CGRect(x: 0, y: 10, width: 200, height: 30))
        titleLabel.center.x = addTagView.frame.width/2
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = "Add Tag"
        addTagView.addSubview(titleLabel)
        
        addTagView.tagTextField = UITextField(frame: CGRect(x: 20, y: 50, width: 160, height: 30))
        addTagView.tagTextField.backgroundColor = .clear
        addTagView.tagTextField.textColor = .black
        addTagView.tagTextField.textAlignment = .center
        addTagView.tagTextField.layer.cornerRadius = 10
        addTagView.tagTextField.addBottomLine()
        addTagView.tagTextField.text = ""
        addTagView.tagTextField.font = UIFont.systemFont(ofSize: 20)
        
        
        let OK = UIButton(frame: CGRect(x: 0, y: 100, width: 30, height: 30))
        OK.center.x = addTagView.frame.width/4
        OK.setFAIcon(icon: .FACheck, iconSize: 20, forState: .normal)
        OK.addTarget(nil, action: #selector(addTagAction), for: .touchDown)
        OK.setFATitleColor(color: .white)
        OK.backgroundColor = Constant.Color.themeColor
        OK.layer.cornerRadius = 15
        addTagView.addSubview(addTagView.tagTextField)
        addTagView.addSubview(OK)
        
        let cancel = UIButton(frame: CGRect(x: 0, y: 100, width: 30, height: 30))
        cancel.center.x = addTagView.frame.width/4*3
        cancel.setFAIcon(icon: .FATimes, iconSize: 20, forState: .normal)
        cancel.addTarget(addTagView, action: #selector(dismissAddTagView), for: .touchDown)
        cancel.setFATitleColor(color: .white)
        cancel.backgroundColor = .red
        cancel.layer.cornerRadius = 15
        addTagView.addSubview(cancel)
        
        superView.addSubview(addTagView)
        
        return addTagView
    }
    
    @objc func dismissAddTagView(){
        self.removeFromSuperview()
        addTagCancelledHandler()
        
    }
    
    @objc func addTagAction(){
        if tagTextField.text == nil || tagTextField.text == ""{
            AlertView.show(alert: "Tag is empty.")
            return
        }
        self.removeFromSuperview()
        var tags = UserDefaults.standard.array(forKey: Constant.Key.Tags)
        let tagsArray = tags as! [String]
        if tagsArray.contains(tagTextField.text!){
            AlertView.show(alert: "Tag alrealy exist.")
            return
        }
        if tags == nil{
            UserDefaults.standard.set([tagTextField.text], forKey: Constant.Key.Tags)
        }else{
            tags?.append(tagTextField.text!)
            UserDefaults.standard.set(tags, forKey: Constant.Key.Tags)
        }
        
    
        Cloud.createTag(tag: tagTextField.text!) { (bool, error) in
            if !bool{
                DispatchQueue.main.async {
                AlertView.show(alert: "create tag failed.")
                }
            }
        }
        
        addTagCompletionHandler(tagTextField.text!)
    }
    
}
