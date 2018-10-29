//
//  OCRController.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/15.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
import ChameleonFramework

class Point:UIButton{
    var point:CGPoint
    var superFrame:CGRect
    weak var delegate:PointDelegate?
    init(point:CGPoint,superFrame:CGRect){
       self.point = point
        self.superFrame = superFrame
       super.init(frame: CGRect(origin:point, size: CGSize(width: 30, height: 30)))
       self.center = point
        self.setTitleColor(UIColor.flatBlue, for: .normal)
        self.setFAIcon(icon: .FACircleO, iconSize: 30, forState: .normal)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(Point.pan))
        self.addGestureRecognizer(gesture)
    }
    
    
    
    @objc func pan(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed{
            if (self.center.x) >= (superFrame.origin.x) && (self.center.y) >= (superFrame.origin.y) && (self.center.x) <= (superFrame.width) + (superFrame.origin.x) && (self.center.y) <= (superFrame.height) + (superFrame.origin.y){
            let midX = (superFrame.origin.x * 2 + superFrame.width)/2
            let midY = (superFrame.origin.y * 2 + superFrame.height)/2
                if abs(self.center.x + gesture.translation(in: self).x - midX) <= superFrame.width + superFrame.origin.x - midX{
            self.frame.origin.x += gesture.translation(in: self).x
                }
                if abs(self.center.y + gesture.translation(in: self).y - midY) <= (superFrame.height) + (superFrame.origin.y) - midY{
             self.frame.origin.y += gesture.translation(in: self).y
                }
            gesture.setTranslation(CGPoint.zero, in: self)
            }
        }else if gesture.state == .ended{
            if (self.center.x) < (superFrame.origin.x) || (self.center.y) < (superFrame.origin.y) {
            self.center.x = max(superFrame.origin.x, self.center.x)
            self.center.y = max(superFrame.origin.y, self.center.y)
            }else if(self.center.x) > (superFrame.width) + (superFrame.origin.x) || (self.center.y) > (superFrame.height) + (superFrame.origin.y){
                self.center.x = min(superFrame.origin.x + superFrame.width, self.center.x)
                self.center.y = min(superFrame.origin.y + superFrame.height, self.center.y)
            }
        }
        if delegate != nil{
            delegate?.pointMoved!(to: self.center)
            self.point = self.center
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc protocol PointDelegate:NSObjectProtocol{
    @objc optional func pointMoved(to point:CGPoint)
}

class OCRController:UIViewController,PointDelegate{
    var imageView:UIImageView!
    var pointArray:[Point] = [Point]()
    var polygon:Polygon!
    var extractButton:UIButton!
    var widthRatioToView:CGFloat = 1
    var heightRatioToView:CGFloat = 1
    var backButton:UIButton!
    var ocrbutton:UIButton!
    var image:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.8)
        backButton = UIButton(frame: CGRect(x: 25, y: 25, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FATimes, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        
        imageView = UIImageView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        extractButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        extractButton.backgroundColor = .white
        extractButton.setFAIcon(icon: .FACut, iconSize:30,forState: .normal)
        extractButton.setTitleColor(Constant.Color.themeColor, for: .normal)
        extractButton.layer.cornerRadius = 25
        extractButton.addTarget(self, action: #selector(extractText), for: .touchDown)
        
        ocrbutton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        ocrbutton.backgroundColor = .white
        ocrbutton.setImage(UIImage(named: "ocr"), for: .normal)
        ocrbutton.imageView?.frame.size = CGSize(width: 30, height: 30)
        ocrbutton.setTitleColor(.white, for: .normal)
        ocrbutton.layer.cornerRadius = 25
        ocrbutton.addTarget(self, action: #selector(recognize), for: .touchDown)
        
        if image != nil{
            loadPic(pic: image)
        }
    }
    
    @objc private func imageViewTapped(){
        
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func extractText(){
        var points = [CGPoint]()
        for point in pointArray{
            var point = (point.point - CGPoint(x: imageView.frame.origin.x, y: imageView.frame.origin.y))
            point.y = imageView.frame.height - point.y
            point = point * CGPoint(x: max(widthRatioToView,heightRatioToView,1), y:  max(widthRatioToView,heightRatioToView,1))
           points.append(point)
        }
        
       // let width = Int(points[3].x - points[0].x + points[2].x - points[1].x)/2
       // let height = Int(points[1].y - points[0].y + points[2].y - points[3].y)/2
        var image = imagePerspective(usingCI:(imageView.image)!, inputVertex: points)
        if image == nil{
            image = imageView.image
        }else{
           // imageView.frame.size = (image?.size)!
            imageView.center = self.view.center
            loadPic(pic: image!)
        }
    }
    
    @objc func recognize(){
        print("start to recognize")
        let processController = LoadingViewController()
        processController.setAlert("Extracting Text...")
        processController.modalPresentationStyle = .overCurrentContext
        self.present(processController, animated: false, completion: nil)
        OCRManager.ocr(usingAPI: imageView.image!) { [unowned self] (error, strings) in
            if error == nil{
                if strings.count == 0{
                    DispatchQueue.main.async {
                    processController.dismiss(animated: true, completion: nil)
                AlertView.show(alert: "No text recognized.")
                    }
                    return
                }
                DispatchQueue.main.async {
                    processController.dismiss(animated: false, completion: nil)
                    let vc = OCRResultController()
                    vc.strings = strings
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                AlertView.show(alert: "Seems no internet.")
                print(error?.localizedDescription)
            }
        }
    }
    
    func loadPic(pic:UIImage){
        for point in pointArray{
            if point.superview != nil{
                point.removeFromSuperview()
            }
        }
        let imageData = resetImgSize(sourceImage: pic, maxImageLenght: 2000, maxSizeKB: 2000)
        let image = UIImage(data: imageData)!
        let width = image.size.width
        let height = image.size.height
         widthRatioToView = width/(self.view.frame.width * 0.7)
         heightRatioToView = height/(self.view.frame.height * 0.7)
        if widthRatioToView > 1 || heightRatioToView > 1{
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width / max(widthRatioToView, heightRatioToView), height: image.size.height / max(widthRatioToView, heightRatioToView))
        }else{
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        }
         imageView.image = image
        if imageView.superview != nil{
            imageView.removeFromSuperview()
        }
         self.view.addSubview(imageView)
        if extractButton.superview != nil{
        extractButton.removeFromSuperview()
        }
        if ocrbutton.superview != nil{
        ocrbutton.removeFromSuperview()
        }
         self.view.addSubview(extractButton)
         self.view.addSubview(ocrbutton)
        imageView.center = self.view.center
        extractButton.center = CGPoint(x: self.view.frame.width/4, y:imageView.frame.height + imageView.frame.origin.y + 60)
        ocrbutton.center = CGPoint(x: self.view.frame.width/4 * 3, y:imageView.frame.height + imageView.frame.origin.y + 60)
        pointArray.removeAll()
        pointArray.append(Point(point: CGPoint(x: imageView.frame.origin.x, y: imageView.frame.origin.y),superFrame:imageView.frame))
        pointArray.append(Point(point: CGPoint(x: imageView.frame.origin.x, y: imageView.frame.height + imageView.frame.origin.y),superFrame:imageView.frame))
        pointArray.append(Point(point: CGPoint(x: imageView.frame.width + imageView.frame.origin.x, y: imageView.frame.height + imageView.frame.origin.y),superFrame:imageView.frame))
        pointArray.append(Point(point: CGPoint(x: imageView.frame.width + imageView.frame.origin.x, y:imageView.frame.origin.y),superFrame:imageView.frame))
        
        //draw polygon
        var pointArr = [CGPoint]()
        for point in pointArray{
            pointArr.append(point.point)
        }
        if polygon != nil{
            polygon.removeFromSuperview()
        }
        polygon = Polygon(points: pointArr)
        polygon.frame = self.view.bounds
        self.view.addSubview(polygon)
        
        for point in pointArray{
            point.delegate = self
            self.view.addSubview(point)
            
        }
        
        self.view.bringSubview(toFront: extractButton)
        self.view.bringSubview(toFront: ocrbutton)
        self.view.bringSubview(toFront: backButton)
    }
    
    func pointMoved(to point: CGPoint) {
       // let image = cropImageWithImageV(imageV: self.imageView, pointArr:pointArr)
       // imageView.image = image
        var points = [CGPoint]()
        for point in pointArray{
            points.append(point.center)
        }
        polygon.points = points
        polygon.setNeedsDisplay()
        
    }
}


class Polygon:UIView{
    var points:[CGPoint]
    
    init(points:[CGPoint]){
        self.points = points
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        draw(points)
    }
    
    func draw(_ points:[CGPoint]) {
        var points = points
        let color = Constant.Color.themeColor
        color.setStroke() // 设置线条颜色
        let clear = UIColor.clear
        clear.setFill()
        let aPath = UIBezierPath()
        
        aPath.lineWidth = 2 // 线条宽度
        aPath.lineCapStyle = .round // 线条拐角
        aPath.lineJoinStyle = .round // 终点处理
        
        // Set the starting point of the shape.
        aPath.move(to: points[0])
        points.removeFirst()
        for point in points{
            aPath.addLine(to: point)
        }
        aPath.close() // 最后一条线通过调用closePath方法得到
        aPath.stroke()
    }
}
