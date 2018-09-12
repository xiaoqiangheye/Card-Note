//
//  UIMapPickerWithBaiduMap.swift
//  Card Note
//
//  Created by 强巍 on 2018/9/4.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation



class UIMapPickerWithBaiduMap:UIViewController,BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKSuggestionSearchDelegate,BMKPoiSearchDelegate{
var _mapView: BMKMapView?
    enum Action:String{
        case add = "add"
        case update = "update"
    }
    private var searchBar:SearchBar!
    private var userLocation:BMKUserLocation?
    var action:Action = .add
    private var isUpdated:Bool = false
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    private var shortAddress:String?
    private var longAddress:String?
    private var locationListView = LocationListView()
    private var exitButton:UIButton!
    private var cancelButton:UIButton!
    private var cityName:String = ""
    private var locationManager:BMKLocationManager!
    weak var delegate:UIMapPickerDelegate?
    private var country:String = ""
    override func viewDidLoad() {
    super.viewDidLoad()
    _mapView = BMKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    self.view.addSubview(_mapView!)
    _mapView?.mapType = .standard
    _mapView?.showsUserLocation = true
    _mapView?.zoomLevel = 16
    _mapView?.delegate = self
        
    //searchBar
    searchBar = SearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 40))
    searchBar.center.y = 50
    searchBar.center.x = self.view.frame.width/2
    searchBar.searchTextView.delegate = self
    searchBar.searchTextView.addTarget(self, action: #selector(textFieldChange(textField:)), for: .editingChanged)
    self.view.addSubview(searchBar)
        
    exitButton = UIButton()
    exitButton.frame = CGRect(x: 0, y: self.view.frame.height - 80, width:self.view.frame.width * 0.8 , height: 50)
    exitButton.setTitle("Set", for: UIControlState.normal)
    exitButton.setTitleColor(.white, for: UIControlState.normal)
    exitButton.addTarget(self, action: #selector(exit), for: .touchDown)
    exitButton.center.x = self.view.frame.width/2
    exitButton.isHidden = true
    let gl = CAGradientLayer.init()
    gl.frame = CGRect(x:0,y:0,width:exitButton.frame.width,height:exitButton.frame.height)
    gl.startPoint = CGPoint(x:0, y:0);
    gl.endPoint = CGPoint(x:1, y:1);
    gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
    gl.locations = [NSNumber(value:0),NSNumber(value:1)]
    gl.cornerRadius = 0
    exitButton.layer.addSublayer(gl)
    exitButton.bringSubview(toFront: exitButton.titleLabel!)
    exitButton.layer.cornerRadius = 20
    self.view.addSubview(exitButton)
        
    //cancelButton
    cancelButton = UIButton()
    cancelButton.frame = CGRect(x: 0, y: self.view.frame.height - 160, width:self.view.frame.width - 80 , height: 50)
    cancelButton.setTitle("Cancel", for: UIControlState.normal)
    cancelButton.setTitleColor(.white, for: UIControlState.normal)
    cancelButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
    cancelButton.center.x = self.view.frame.width/2
   // cancelButton.layer.addSublayer(gl)
    cancelButton.bringSubview(toFront: cancelButton.titleLabel!)
    cancelButton.layer.cornerRadius = 20
    self.view.addSubview(cancelButton)
    
       
    
    locationListView = LocationListView(frame: CGRect(x: 40, y: searchBar.frame.origin.y + 40 + 20, width: self.view.frame.width - 80, height: self.view.frame.height - (searchBar.frame.origin.y + 160)))
        locationListView.isHidden = true
        locationListView.delegate = self
        self.view.addSubview(locationListView)
    
    locate()
   }
    
    func locate(){
        locationManager = BMKLocationManager()
        locationManager.delegate = self
        locationManager.coordinateType = BMKLocationCoordinateType.BMK09LL
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.automotiveNavigation
        locationManager.locationTimeout = 10
        locationManager.allowsBackgroundLocationUpdates = true
        userLocation = BMKUserLocation()
        /*
        _locationManager.requestLocation(withReGeocode: true, withNetworkState: true) {[unowned self] (location, networkState, error) in
            
            DispatchQueue.main.async{
            if !self.isUpdated && self.action == .add{
                self.isUpdated = true
                self._mapView?.setCenter((self.userLocation?.location?.coordinate)!, animated: true)
                self.reGeoCode(latitude: (self.userLocation?.location?.coordinate.latitude)!, longitude: (self.userLocation?.location?.coordinate.longitude)!)
            }else if self.action == .update{
                let coordinate = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
                self._mapView?.setCenter(coordinate, animated: true)
            }
            }
        }
      */
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        //_locationManager.locatingWithReGeocode = true
        _mapView?.showsUserLocation = false//先关闭显示的定位图层
        _mapView?.userTrackingMode = BMKUserTrackingModeHeading//设置定位的状态
        _mapView?.showsUserLocation = true//显示定位图层
    }
    
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if (annotation.isKind(of:BMKPointAnnotation.self)){
            let pointReuseIndentifier = "pointReuseIndentifier"
            var annotationView = _mapView?.dequeueReusableAnnotationView(withIdentifier: pointReuseIndentifier) as? BMKPinAnnotationView
            if (annotationView == nil) {
                annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndentifier)
            }
            
            
            annotationView?.pinColor = UInt(BMKPinAnnotationColorRed)
            annotationView?.canShowCallout = true      //设置气泡可以弹出，默认为NO
            annotationView?.enabled3D = true
            //设置标注动画显示，默认为NO
            annotationView?.isDraggable = false          //设置标注可以拖动，默认为NO
            return annotationView
        }
        return nil
    }
    
    @objc func exit(){
        if delegate != nil{
            let image = _mapView?.takeSnapshot(CGRect(x:self.view.frame.width * 0.1, y: self.view.frame.height * 0.25, width:self.view.frame.width * 0.8, height: self.view.frame.height/4))
            delegate?.UIMapDidSelected!(image: image!, name: shortAddress!, address: longAddress!, coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func textFieldChange(textField:UITextField){
        if textField.text?.count == 0{
            return
        }
        /*
        let searcher = BMKSuggestionSearch()
        searcher.delegate = self
        let option = BMKSuggestionSearchOption()
        option.cityLimit = false
        option.cityname = cityName
        option.keyword = (textField.text)!
        searcher.suggestionSearch(option)
        */
        poiCode()
    }
    
    //suggestion search
    
    func onGetSuggestionResult(_ searcher: BMKSuggestionSearch!, result: BMKSuggestionSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR{
            var index = 0
            if result.suggestionList == nil{return}
            let suggestionList = result.suggestionList
            locationListView.loadViewWithKeyandAddress(suggestion:suggestionList)
            self.locationListView.isHidden = false
            index += 1
        }else{
            NSLog("reverse geocode sent failed." + String(error.rawValue))
        }
    }
    
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR{
            let list = poiResult.poiInfoList
            locationListView.loadViewWithPOI(pois: list)
             self.locationListView.isHidden = false
        }else{
            print("error on get poi result " + String(errorCode.rawValue))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _mapView?.viewWillAppear()
        _mapView?.delegate = self // 此处记得不用的时候需要置nil，否则影响内存的释放
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView?.viewWillDisappear()
        _mapView?.delegate = nil // 不用时，置nil
    }
    
    func mapStatusDidChanged(_ mapView: BMKMapView!) {
        // locate()
    }
    
    func mapViewDidFinishRendering(_ mapView: BMKMapView!) {
       // locate()
    }
    
    func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
       
    }

    
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        if animated == false{
        self.longitude = mapView.centerCoordinate.longitude
        self.latitude = mapView.centerCoordinate.latitude
        reGeoCode(latitude: self.latitude!, longitude: self.longitude!)
        }
    }
    
    
    
    
    //location Update
    func didUpdate(_ userLocation: BMKUserLocation!) {
        
    }
    
    
    
    func poiCode(){
        //初始化搜索对象 ，并设置代理
        let _searcher = BMKPoiSearch()
        _searcher.delegate = self
        //请求参数类BMKCitySearchOption
        let option = BMKPOICitySearchOption()
        option.isCityLimit = false
        option.city = cityName
        option.tags = [cityName,country]
        option.keyword = searchBar.searchTextView.text
        let flag = _searcher.poiSearch(inCity: option)
        if flag{
            NSLog("poi sent successfully.")
        }else{
            NSLog("poi sent failed.")
        }
        //发起城市内POI检索
    }
    //geoCode
    func geoCode(){
        let searcher = BMKGeoCodeSearch()
        searcher.delegate = self
        let option = BMKGeoCodeSearchOption()
        option.address = searchBar.searchTextView.text
        option.city = cityName
        let flag = searcher.geoCode(option)
        if flag{
            NSLog("geocode sent successfully.")
        }else{
            NSLog("geocode sent failed.")
        }
    }
    
    func reGeoCode(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let searcher = BMKGeoCodeSearch()
        searcher.delegate = self
        let option = BMKReverseGeoCodeSearchOption()
        option.location = CLLocationCoordinate2DMake(latitude, longitude)
        let flag = searcher.reverseGeoCode(option)
        if flag{
            NSLog("reverse geocode sent successfully.")
        }else{
            NSLog("reverse geocode sent failed.")
        }
    }
    
    func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR{
            self._mapView?.setCenter(result.location, animated: true)
        }else{
            NSLog("address geocode failed" + String(error.rawValue))
        }
    }
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR{
            cityName = result.addressDetail.city
            country = result.addressDetail.country
            print(country + cityName)
            if result.poiList.count > 0{
                self.shortAddress = (result.poiList[0] as! BMKPoiInfo).name
                self.searchBar.searchTextView.text = (result.poiList[0] as! BMKPoiInfo).name
            }else{
                self.shortAddress = result.address
                self.searchBar.searchTextView.text = result.address
            }
            self.longAddress = result.address
            self.exitButton.isHidden = false
        }else{
            NSLog("address Regeocode failed")
        }
    }
    
    
}

extension UIMapPickerWithBaiduMap:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
         self.locationListView.isHidden = true
        // poiCode()
    }
    
}

extension UIMapPickerWithBaiduMap:LocationListViewDelegate{
    func cell(cellDidClicked cell: LocationListView.LocationCellView) {
        searchBar.searchTextView.text = cell.neighbourhood.text
        if cell.latitude != nil && cell.longitude != nil{
            self._mapView?.setCenter(CLLocationCoordinate2D(latitude: cell.latitude!, longitude: cell.longitude!), animated: true)
            self.latitude = cell.latitude
            self.longitude = cell.longitude
            self.shortAddress = cell.neighbourhood.text
            self.longAddress = cell.standardFormat.text
            let annotation = BMKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: cell.latitude!, longitude: (cell.longitude)!)
            annotation.title = cell.neighbourhood.text
            _mapView?.addAnnotation(annotation)
        }
    }
}


extension UIMapPickerWithBaiduMap:BMKLocationManagerDelegate{
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        if error != nil{
            return
        }
        
        if (location == nil) {
            return
        }
        
        if (self.userLocation == nil) {
            self.userLocation = BMKUserLocation()
        }
        self.userLocation?.location = location?.location
        self._mapView?.updateLocationData(self.userLocation)
        DispatchQueue.main.async{
            if !self.isUpdated && self.action == .add{
                self.isUpdated = true
                self._mapView?.setCenter((self.userLocation?.location?.coordinate)!, animated: true)
                self.reGeoCode(latitude: (self.userLocation?.location?.coordinate.latitude)!, longitude: (self.userLocation?.location?.coordinate.longitude)!)
                self.latitude = location?.location?.coordinate.latitude
                self.longitude = location?.location?.coordinate.longitude
            }else if !self.isUpdated && self.action == .update{
                self.isUpdated = true
                let coordinate = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
                self._mapView?.setCenter(coordinate, animated: true)
            }
        }
    }
    
    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate heading: CLHeading?) {
        if (heading == nil) {
            return
        }
        
        if (self.userLocation == nil){
            self.userLocation = BMKUserLocation()
        }
        self.userLocation?.heading = heading
        self._mapView?.updateLocationData(self.userLocation)
    }
}
