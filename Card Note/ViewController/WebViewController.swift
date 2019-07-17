//
//  WebViewController.swift
//  Card Note
//
//  Created by Wei Wei on 7/14/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import WebKit


class WebViewController: UIViewController,WKUIDelegate, WKNavigationDelegate {
    lazy private var webview: WKWebView = {
        self.webview = WKWebView.init(frame: self.view.bounds)
        self.webview.uiDelegate = self as WKUIDelegate
        self.webview.navigationDelegate = self as WKNavigationDelegate
        return self.webview
    }()
    
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(65), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor.blue
        self.progressView.trackTintColor = UIColor.white
        return self.progressView
    }()
    
    private var exitButton:UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webview)
        view.addSubview(progressView)
        
        exitButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        exitButton.addTarget(self, action: #selector(exitVC), for: .touchDown)
        exitButton.setFAIcon(icon: .FATimes, iconSize: 30, forState: .normal)
        exitButton.setTitleColor(.black, for: .normal)
        view.addSubview(exitButton)
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webview.load(URLRequest.init(url: URL.init(string: "https://www.cardnotebook.com/terms.php")!))
    }
    
    func load(url:URL){
        webview.load(URLRequest.init(url: url))
    }
    
    @objc func exitVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float(webview.estimatedProgress), animated: true)
            if webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        webview.removeObserver(self, forKeyPath: "estimatedProgress")
        webview.uiDelegate = nil
        webview.navigationDelegate = nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        AlertView.show(alert: "Load Failed. Check the Internet.")
    }
}
