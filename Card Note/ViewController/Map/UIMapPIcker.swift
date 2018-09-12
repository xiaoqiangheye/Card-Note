//
//  UIMapPIcker.swift
//  Card Note
//
//  Created by 强巍 on 2018/5/1.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import AMapFoundationKit

class UIMapPicker:UIViewController,MAMapViewDelegate, AMapSearchDelegate, UITextFieldDelegate, LocationListViewDelegate{
    var mapView:MAMapView = MAMapView()
    var search:SearchBar = SearchBar()
    var searchApi = AMapSearchAPI()
    var locationListView = LocationListView()
    var isLocated = false
    var exitButton = UIButton()
    var neighbourHoodAddress:String = ""
    var formalAddress:String = ""
    var poi:AMapPOI?
    var action:String?
    var latitude:CGFloat?
    var longitude:CGFloat?
    weak var delegate:UIMapPickerDelegate?
    
    enum Action:String{
        case add
        case update
    }
    override func viewDidLoad() {
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame: self.view.bounds)
        mapView.isShowsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        mapView.setZoomLevel(16, animated: false)
        searchApi?.delegate = self
        self.view.addSubview(mapView)
        search = SearchBar(frame: CGRect(x: 40, y: UIDevice.current.Xdistance(), width: Int(UIScreen.main.bounds.width - 80), height: 40))
        search.searchTextView.delegate = self
        search.center.x = self.view.center.x
        self.view.addSubview(search)
        exitButton = UIButton()
        exitButton.backgroundColor = .white
        exitButton.frame = CGRect(x: 0, y: self.view.frame.height - 80, width: self.view.frame.width - 80 , height: 50)
        exitButton.setTitle("Set", for: UIControlState.normal)
        exitButton.setTitleColor(.black, for: UIControlState.normal)
        exitButton.addTarget(self, action: #selector(exit), for: .touchDown)
        exitButton.center.x = self.view.frame.width/2
        exitButton.isHidden = true
        self.view.addSubview(exitButton)
        //the first search for location
       
        
        locationListView = LocationListView(frame: CGRect(x: 40, y: search.frame.origin.y + 40 + 20, width: self.view.frame.width - 80, height: self.view.frame.height - (search.frame.origin.y + 40 + 20 + 20 + 80)))
         locationListView.isHidden = true
         locationListView.delegate = self
        self.view.addSubview(locationListView)

    }
    
    func loadMap(){
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame: self.view.bounds)
        mapView.isShowsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        mapView.setZoomLevel(16, animated: false)
    }
    
    func cell(cellDidClicked cell: LocationListView.LocationCellView,Pois:AMapPOI) {
        exitButton.isHidden = false
        search.searchTextView.text = cell.neighbourhood.text
        neighbourHoodAddress = cell.neighbourhood.text!
        formalAddress = cell.standardFormat.text!
        mapView.centerCoordinate.latitude = CLLocationDegrees(Pois.location.latitude)
        mapView.centerCoordinate.longitude = CLLocationDegrees(Pois.location.longitude)
        self.poi = cell.poi
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if !mapView.isShowsUserLocation{
            mapView.centerCoordinate = mapView.userLocation.location.coordinate
        }
        if !self.isLocated && action == Action.add.rawValue{
        self.isLocated = true
        let location = mapView.centerCoordinate
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.latitude), longitude: CGFloat(location.longitude))
        request.requireExtension = true
        searchApi?.aMapReGoecodeSearch(request)
        }else if action == Action.update.rawValue{
            mapView.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude!), longitude: CLLocationDegrees(longitude!)), animated: true)
            let location = mapView.centerCoordinate
            let request = AMapReGeocodeSearchRequest()
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.latitude), longitude: CGFloat(location.longitude))
            request.requireExtension = true
            searchApi?.aMapReGoecodeSearch(request)
        }
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction{
        let centerCoordinate = mapView.centerCoordinate
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(centerCoordinate.latitude), longitude: CGFloat(centerCoordinate.longitude))
        request.requireExtension = true
            searchApi?.aMapReGoecodeSearch(request)
        }
        
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode == nil {
            return
        }else{
            let street = "\(response.regeocode.addressComponent.streetNumber.street)\(response.regeocode.addressComponent.streetNumber.number )\(response.regeocode.addressComponent.building)"
            if response.regeocode.pois.count > 0{
            search.searchTextView.text = response.regeocode.pois[0].name
            neighbourHoodAddress = response.regeocode.pois[0].name
            formalAddress = response.regeocode.formattedAddress
            self.poi = response.regeocode.pois[0]
            exitButton.isHidden = false
            }else{
            formalAddress = response.regeocode.formattedAddress
            search.searchTextView.text = street
            neighbourHoodAddress = street
            }
        }
        //解析response获取地址描述，具体解析见 Demo
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        if response.geocodes.count < 1{
            return
        }else{
          //  locationListView.loadViewWithCurrentLocation(geocodes: response.geocodes)
          //  self.view.addSubview(locationListView)
        }
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois.count < 1{
            return
        }else{
            locationListView.loadViewWithPOI(pois: response.pois)
            
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let request = AMapGeocodeSearchRequest()
        request.address = textField.text
        searchApi?.aMapGeocodeSearch(request)
        
        let requestPOI = AMapPOIAroundSearchRequest()
        requestPOI.keywords = search.searchTextView.text
        requestPOI.sortrule = 0
        if !mapView.isShowsUserLocation{
            requestPOI.location = AMapGeoPoint.location(withLatitude: CGFloat(mapView.centerCoordinate.latitude), longitude: CGFloat(mapView.centerCoordinate.longitude))
        }else{
            requestPOI.location = AMapGeoPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude))
        }
        requestPOI.requireExtension = true
       // requestPOI.cityLimit = true
        requestPOI.requireSubPOIs = true
        searchApi?.aMapPOIAroundSearch(requestPOI)
        locationListView.isHidden = false
    }
   
    
    @objc func exit(){
        mapView.setZoomLevel(12, animated: false)
        let image = self.mapView.takeSnapshot(in: CGRect(x: mapView.frame.width/2-100, y: mapView.frame.height/2-100, width: 200, height: 200))
      //  let screenshotImage = self.mapView.takeSnapshot(in:CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: , height: <#T##CGFloat#>))
        self.dismiss(animated: true) {
            if self.delegate != nil{
                self.delegate?.UIMapDidSelected!(image:image!,poi:self.poi!,formalAddress:self.formalAddress)
            }
        }
    }
}
