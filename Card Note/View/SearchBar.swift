//
//  SearchBar.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/21.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class SearchBar:UIView{
    var searchTextView = UITextField()
    override init(frame: CGRect) {
        super.init(frame: frame)
      //  self.backgroundColor = .white
        self.layer.shadowColor = Constant.Color.darkWhite.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.cornerRadius = 20
        self.layer.backgroundColor = UIColor.white.cgColor
        
        //let imageView = UIImageView(image: #imageLiteral(resourceName: "searchBar"))
        
        let imageView = UIImageView(frame: CGRect(x:10, y: 0, width: 25, height: 25))
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "search")
        imageView.center.y = 20
        //imageView.layer.borderWidth = 0.5
        self.addSubview(imageView)
 
        searchTextView.frame = CGRect(x: 35, y: 0, width: 200, height: 40)
        searchTextView.backgroundColor = .clear
        searchTextView.textColor = .black
        searchTextView.center.y = 20
        searchTextView.keyboardType = .webSearch
        searchTextView.addTarget(self, action: #selector(textViewChange), for: .allEditingEvents)
        searchTextView.layer.cornerRadius = 20
        self.addSubview(searchTextView)
    }
    
    @objc func textViewChange(){
        
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
}
