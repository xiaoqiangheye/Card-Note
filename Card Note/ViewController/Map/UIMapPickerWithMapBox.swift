//
//  UIMapPickerWithMapBox.swift
//  Card Note
//
//  Created by 强巍 on 2018/7/20.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import Mapbox
import MapboxGeocoder
import Font_Awesome_Swift
class UIMapPickerWithMapBox:UIViewController,UITextFieldDelegate,MGLMapViewDelegate{
    weak var delegate:UIMapPickerDelegate?
    var mapView:MGLMapView!
    var search:SearchBar = SearchBar()
    var geocoder:Geocoder!
    var exitButton:UIButton!
    var cancelButton:UIButton!
    var coordinate:CLLocationCoordinate2D?
    var name:String = ""
    var address:String = ""
    var userLocateButton:UIButton!
    var isFollowed:Bool = false
    var isFirstUserUpdated = true
    var currentPlace:Placemark?
    var action:Action?
    
    enum Action:String{
        case add
        case update
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "mapbox://styles/mapbox/streets-v10")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.setZoomLevel(15, animated: true)
        mapView.delegate = self
        mapView.logoView.isHidden = true
        //mapView.attributionButton.isHidden = true
       
        
        view.addSubview(mapView)
        
        //searchBar
        search = SearchBar(frame: CGRect(x: 40, y: UIDevice.current.Xdistance(), width: Int(UIScreen.main.bounds.width - 80), height: 40))
        search.searchTextView.delegate = self
        search.center.x = self.view.center.x
        self.view.addSubview(search)
        
        //action

        //geocoder
        geocoder = Geocoder.shared
        
        //exitButton
        exitButton = UIButton()
        exitButton.backgroundColor = .white
        exitButton.frame = CGRect(x: 0, y: self.view.frame.height - 80, width: self.view.frame.width - 80 , height: 50)
        exitButton.setTitle("Save", for: UIControlState.normal)
        exitButton.setTitleColor(.black, for: UIControlState.normal)
        exitButton.addTarget(self, action: #selector(exit), for: .touchDown)
        exitButton.center.x = self.view.frame.width/2
        exitButton.isHidden = true
        self.view.addSubview(exitButton)
        
        //cancelButton
        cancelButton = UIButton()
        cancelButton.backgroundColor = .white
        cancelButton.frame = CGRect(x: 0, y: self.view.frame.height - 160, width: self.view.frame.width - 80 , height: 50)
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitleColor(.black, for: UIControlState.normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchDown)
        cancelButton.center.x = self.view.frame.width/2
        self.view.addSubview(cancelButton)
        
        //userLocationButton
        userLocateButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: self.view.frame.height - 50, width: 30, height: 30))
        userLocateButton.setFAIcon(icon: FAType.FALocationArrow, forState: .normal)
        userLocateButton.addTarget(self, action: #selector(locateUser), for: .touchDown)
        userLocateButton.setFATitleColor(color: .black)
        self.view.addSubview(userLocateButton)
    }
    
    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func locateUser(){
        if mapView.userLocation != nil{
            mapView.setCenter((mapView.userLocation?.coordinate)!, animated: true)
            var places = [Placemark]()
            reverseGeoCode(latitude: (mapView.userLocation?.coordinate.latitude)!, longitude: (mapView.userLocation?.coordinate.longitude)!){(places) in
            if places.count > 0{
                let name = places[0].name
                self.currentPlace = places[0]
                self.search.searchTextView.text = name
            }
            }
        }
    }
    
    @objc func exit(){
        mapView.setZoomLevel(10, animated: false)
        let image = self.mapViewtakeSnapshot(view:self.view,frame: CGRect(x: mapView.frame.width/2-100, y: mapView.frame.height/2-100, width: 200, height: 200))
        
        self.dismiss(animated: true) {
            if self.delegate != nil && self.currentPlace != nil{
                self.delegate?.UIMapDidSelected!(image:image!,place:self.currentPlace)
            }else if self.delegate != nil && self.currentPlace == nil{
                self.delegate?.UIMapDidSelected!(image: image!, name: self.name, address: self.address, coordinate: self.coordinate!)
            }
        }
    }
    
    
    func mapViewtakeSnapshot(view:UIView,frame:CGRect)->UIImage?{
       // guard let window = UIApplication.shared.keyWindow else { return nil }
        
        // 用下面这行而不是UIGraphicsBeginImageContext()，因为前者支持Retina
     UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        view.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        
        let sourceImageRef: CGImage = image!.cgImage!
        let newCGImage = sourceImageRef.cropping(to: frame)
        let newImage = UIImage.init(cgImage: newCGImage!)
        UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)

        return newImage
        
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            print("保存失败")
        } else {
            print("保存成功")
        }
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if isFirstUserUpdated{
            isFirstUserUpdated = false
            //set user location and fetch the location
            if mapView.userLocation != nil{
                var placemarks = [Placemark]()
                reverseGeoCode(latitude: (userLocation?.coordinate.latitude)!, longitude: (userLocation?.coordinate.longitude)!){(placemarks) in
                let coordinate = userLocation?.coordinate
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: ((coordinate?.latitude)!), longitude: (coordinate?.longitude)!)
                    if placemarks.count > 0{
                        let placemark = placemarks[0]
                        self.currentPlace = placemark
                        annotation.title = placemark.name
                        annotation.subtitle = placemark.address == nil ? "" : placemark.address
                        print(placemark.address)
                        self.search.searchTextView.text = placemark.name
                        self.mapView.addAnnotation(annotation)
                        self.exitButton.isHidden = false
                        mapView.setCenter(coordinate!, animated: true)
                    }
                }
                if action == Action.update{
                    mapView.setCenter(self.coordinate!, animated: true)
                    search.searchTextView.text = name
                }
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        if reason != .programmatic{
            reverseGeoCode(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude){(places) in
            if places.count > 0{
                self.search.searchTextView.text = places[0].name
                self.currentPlace = places[0]
            }
            }
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        //fail to load map
        AlertView.show(self.view, alert: "failed to load the map. Please check the internet.")
    }
    
    func mapView(_ mapView: MGLMapView, didFailToLocateUserWithError error: Error) {
         AlertView.show(self.view, alert: "failed to locate the user. Please check the internet.")
    }
    
    func reverseGeoCode(latitude:CLLocationDegrees,longitude:CLLocationDegrees, completionHandler:@escaping ([Placemark])->()){
        let options = ReverseGeocodeOptions(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        // Or perhaps: ReverseGeocodeOptions(location: locationManager.location)
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            if error != nil{
                AlertView.show(self.view, alert: (error?.localizedDescription)!)
            }
            if placemarks != nil{
                completionHandler(placemarks!)
            }else{
                completionHandler([Placemark]())
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        exitButton.isHidden = false
        search.searchTextView.text = annotation.title as! String
        mapView.centerCoordinate = annotation.coordinate
        currentPlace = nil
        name = annotation.title as! String
        address = annotation.subtitle as! String
        coordinate = annotation.coordinate
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil{
            let options = ForwardGeocodeOptions(query: textField.text!)
        // To refine the search, you can set various properties on the options object.
     
        if mapView.userLocation?.location != nil{
        options.focalLocation = mapView.userLocation?.location
            }
        options.allowedScopes = [.address, .pointOfInterest, .district,.landmark, .locality,.place, .region]
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            self.mapView.setCenter((placemarks![0].location?.coordinate)!, animated: true)
            for place in placemarks!{
            print(place.qualifiedName)
                
            // 200 Queen St, Saint John, New Brunswick E2L 2X1, Canada
                let coordinate = place.location?.coordinate
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
                annotation.title = place.qualifiedName == nil ? "" : place.qualifiedName
                // Add marker `hello` to the map.
               
                self.mapView.addAnnotation(annotation)
            }
         }
        }
    }
    
    
}
