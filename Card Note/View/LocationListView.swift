//
//  File.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import AMapFoundationKit

class LocationListView:UIView,UIScrollViewDelegate{
    var MapPOIS:[AMapPOI] = [AMapPOI]()
    var cumulatedheight = 0
    var scrollView = UIScrollView()
    var delegate:LocationListViewDelegate?
    override init(frame:CGRect){
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
        self.backgroundColor = .white
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.frame.size = self.bounds.size
        scrollView.frame.origin = CGPoint(x: 0, y: 0)
        self.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class LocationCellView:UIView{
        var neighbourhood:UILabel = UILabel()
        var standardFormat:UILabel = UILabel()
        var poi:AMapPOI!
        var latitude:CLLocationDegrees?
        var longitude:CLLocationDegrees?
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .white
            neighbourhood.frame = CGRect(x: 50, y: 0, width: self.frame.width-50, height: self.frame.height/2)
            neighbourhood.font = UIFont.boldSystemFont(ofSize: 15)
            neighbourhood.center.x = self.frame.width/2
            standardFormat.frame = CGRect(x: 50, y:self.frame.height/2, width: self.frame.width-50, height: self.frame.height/2)
            standardFormat.font = UIFont.systemFont(ofSize: 12)
            standardFormat.center.x = self.frame.width/2
            self.addSubview(neighbourhood)
            self.addSubview(standardFormat)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            //fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    func loadViewWithCurrentLocation(geocodes:[AMapGeocode]){
        for geocode in geocodes{
            let cell = LocationCellView(frame: CGRect(x: 0, y: CGFloat(cumulatedheight), width: self.frame.width, height: self.frame.height/10))
            cell.neighbourhood.text = "当前位置"
            cell.standardFormat.text = geocode.formattedAddress
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.gray.cgColor
            self.scrollView.addSubview(cell)
            cumulatedheight += Int(cell.frame.height)
            self.scrollView.contentSize.height += cell.frame.height
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            tap.addTarget(self, action: #selector(cellDidClicked))
            cell.addGestureRecognizer(tap)
        }
    }
    
    @objc func cellDidClicked(_ sender:UITapGestureRecognizer){
        let cell:LocationCellView = sender.view as! LocationCellView
        if delegate != nil{
            if cell.poi != nil{
            delegate?.cell?(cellDidClicked: cell, Pois: cell.poi)
            }else{
            delegate?.cell?(cellDidClicked: cell)
            }
        }
        self.isHidden = true
    }
    
    
    func loadViewWithKeyandAddress(suggestion:[BMKSuggestionInfo]?){
        if suggestion == nil{return}
        cumulatedheight = 0
        scrollView.contentSize.height = 0
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        var index = 0
        for info in suggestion!{
            let cell = LocationCellView(frame: CGRect(x: 0, y: CGFloat(cumulatedheight), width: self.frame.width, height: self.frame.height/10))
            cell.neighbourhood.text = info.key
            if info.address != nil{
            cell.standardFormat.text = info.address
            }else{
            cell.standardFormat.text = info.key
            }
            cell.latitude = info.location.latitude
            cell.longitude = info.location.longitude

            self.scrollView.addSubview(cell)
            cumulatedheight += Int(cell.frame.height)
            self.scrollView.contentSize.height += cell.frame.height
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            tap.addTarget(self, action: #selector(cellDidClicked))
            cell.addGestureRecognizer(tap)
            index += 1
        }
    }
    
    func loadViewWithPOI(pois:[AMapPOI]){
        self.MapPOIS = pois
       cumulatedheight = 0
        scrollView.contentSize.height = 0
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
       // scrollView.contentSize.height = 0
        for poi in pois{
            let cell = LocationCellView(frame: CGRect(x: 0, y: CGFloat(cumulatedheight), width: self.frame.width, height: self.frame.height/10))
            cell.neighbourhood.text = poi.name
            cell.poi = poi
            cell.standardFormat.text = poi.address
            self.scrollView.addSubview(cell)
            cumulatedheight += Int(cell.frame.height)
            self.scrollView.contentSize.height += cell.frame.height

           let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            tap.addTarget(self, action: #selector(cellDidClicked))
            cell.addGestureRecognizer(tap)
        }
    }
    
    func loadViewWithPOI(pois:[BMKPoiInfo]?){
        if pois == nil{return}
        cumulatedheight = 0
        scrollView.contentSize.height = 0
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        for poi in pois!{
            let cell = LocationCellView(frame: CGRect(x: 0, y: CGFloat(cumulatedheight), width: self.frame.width, height: self.frame.height/10))
            cell.neighbourhood.text = poi.name
            cell.standardFormat.text = poi.address
            cell.latitude = poi.pt.latitude
            cell.longitude = poi.pt.longitude
            self.scrollView.addSubview(cell)
            cumulatedheight += Int(cell.frame.height)
            self.scrollView.contentSize.height += cell.frame.height
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            tap.addTarget(self, action: #selector(cellDidClicked))
            cell.addGestureRecognizer(tap)
        }
        
    }
    
}
