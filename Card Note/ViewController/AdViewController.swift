//
//  AddViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/19.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import GoogleMobileAds


class AdViewController:UIViewController, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate{
    var adLoader: GADAdLoader!
    var adview: GADNativeAdView!
    static let UNIT_ID = "ca-app-pub-3940256099942544/3986624511"
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // performSegue(withIdentifier: "main", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
            multipleAdsOptions.numberOfAds = 5

        adLoader = GADAdLoader(adUnitID: AdViewController.UNIT_ID, rootViewController: self,
                adTypes: [.native],
                options: [multipleAdsOptions])
            adLoader.delegate = self
            adLoader.load(GADRequest())

    }
    
    
    func setAdView(_ view: GADNativeAdView) {
      // Remove the previous ad view.
        if(adview != nil){
          adview.removeFromSuperview()
        }
        adview = view
        adview.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        self.view.addSubview(adview)
     

     
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                    didReceive nativeAd: GADNativeAd) {
        // A native ad has loaded, and can be displayed.
        print("A native ad has loaded, and can be displayed")
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first
          guard let adview = nibView as? GADNativeAdView else {
            return
          }

        setAdView(adview)
        nativeAd.delegate = self
        
        //adview.mediaView?.frame = adview.frame
        adview.mediaView?.mediaContent = nativeAd.mediaContent
        adview.mediaView?.isHidden = false
        let mediaContent = nativeAd.mediaContent
           if mediaContent.hasVideoContent {
             // By acting as the delegate to the GADVideoController, this ViewController receives messages
             // about events in the video lifecycle.
             mediaContent.videoController.delegate = self
           }
        
        /*
        if let mediaView = adview.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(
              item: mediaView,
              attribute: .height,
              relatedBy: .equal,
              toItem: mediaView,
              attribute: .width,
              multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
              constant: 0)
            heightConstraint.isActive = true
          }
       */
        
        (adview.bodyView as? UILabel)?.text = nativeAd.body
        adview.bodyView?.isHidden = nativeAd.body == nil

        (adview.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            adview.callToActionView?.isHidden = nativeAd.callToAction == nil

            (adview.iconView as? UIImageView)?.image = nativeAd.icon?.image
            adview.iconView?.isHidden = nativeAd.icon == nil

           

            (adview.storeView as? UILabel)?.text = nativeAd.store
            adview.storeView?.isHidden = nativeAd.store == nil

            (adview.priceView as? UILabel)?.text = nativeAd.price
            adview.priceView?.isHidden = nativeAd.price == nil

            (adview.advertiserView as? UILabel)?.text = nativeAd.advertiser
            adview.advertiserView?.isHidden = nativeAd.advertiser == nil

        
        
        adview.callToActionView?.isUserInteractionEnabled = false
        adview.nativeAd = nativeAd
        self.view.addSubview(adview)
    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
          // The adLoader has finished loading ads, and a new request can be sent.
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        //do nothing
    }

   
}
