//
//  UserView.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/14.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
class UserView:UIView
{
    private var username:UITextField!
    private var email:UITextField!
    private var password:UITextField!
    private var auth:UITextField!
    static let x = UIScreen.main.bounds.width
    static let y = UIScreen.main.bounds.height
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func loginView()->UserView{
        let loginView = UserView()
        loginView.frame = CGRect(x: 0, y: 0, width: x, height: y)
        loginView.email = UITextField()
        loginView.email.frame = CGRect(x: 0, y: 30, width: x * 0.7, height: 30)
        loginView.email.placeholder = "email"
        loginView.email.center.x = x/2
        loginView.email.textContentType = UITextContentType.emailAddress
        
        loginView.password = UITextField()
        loginView.password.frame = CGRect(x: 0, y:loginView.email.frame.height + loginView.email.frame.origin.y + 20, width: x * 0.7, height: 30)
        loginView.password.center.x = x/2
        loginView.password.placeholder = "password"
        loginView.password.textContentType = UITextContentType.password
        
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.addTarget(self, action: #selector(login), for: .touchDown)
        loginView.addSubview(loginView.email)
        loginView.addSubview(loginView.password)
        loginView.addSubview(button)
        return loginView
    }
    
    
    
    class func signUpView()->UserView{
        let loginView = UserView()
        loginView.frame = CGRect(x: 0, y: 0, width: x, height: y)
        loginView.email = UITextField()
        loginView.email.frame = CGRect(x: 0, y: 30, width: x * 0.7, height: 30)
        loginView.email.placeholder = "email"
        loginView.email.center.x = x/2
        
        let authButton = UIButton(frame: CGRect(x:loginView.email.frame.origin.x + loginView.email.frame.width, y: 30, width: 50, height: 30))
        authButton.setTitle("Verify", for: UIControlState())
        authButton.addTarget(self, action: #selector(verification), for: .touchDown)
        authButton.backgroundColor = .cyan
        loginView.addSubview(authButton)
        
        
        loginView.username = UITextField()
        loginView.username.frame = CGRect(x: 0, y: loginView.email.frame.height + loginView.email.frame.origin.y + 20, width: x * 0.7, height: 30)
        loginView.username.center.x = x/2
        loginView.username.placeholder = "username"
        
        loginView.password = UITextField()
        loginView.password.frame = CGRect(x: 0, y:loginView.username.frame.height + loginView.username.frame.origin.y + 20, width: x * 0.7, height: 30)
        loginView.password.center.x = x/2
        loginView.password.placeholder = "password"
        
        loginView.auth = UITextField()
        loginView.auth.frame = CGRect(x: 0, y:loginView.password.frame.height + loginView.password.frame.origin.y + 20, width: x * 0.7, height: 30)
        loginView.auth.center.x = x/2
        loginView.auth.placeholder = "Email Verification Code"
        loginView.addSubview(loginView.email)
        loginView.addSubview(loginView.username)
        loginView.addSubview(loginView.password)
        loginView.addSubview(loginView.auth)
        
        let button = UIButton()
        button.setTitle("Sign Up", for: UIControlState())
        button.backgroundColor = .cyan
        button.addTarget(self, action: #selector(signUp), for: .touchDown)
        button.frame = CGRect(x: 0, y: loginView.auth.frame.height + loginView.auth.frame.origin.y + 20, width: 200, height: 50)
        button.center.x = x/2
        loginView.addSubview(button)
        return loginView
    }
    
    @objc static func login(_ sender:UIButton){
        User.login(email: (sender.superview as! UserView).email.text!, password: (sender.superview as! UserView).password.text!,completionHandler: {(_ json:JSON?)->Void in
            
            
        })
    }
    
    @objc static func signUp(_ sender:UIButton){
        User.signUp(email: (sender.superview as! UserView).email.text!, username: (sender.superview as! UserView).username.text!, password: (sender.superview as! UserView).password.text!, auth: (sender.superview as! UserView).auth.text!,completionHandler: {(_ json:JSON?)->Void in
            
            
        })
    }
    
    @objc static func verification(_ sender:UIButton){
        User.verification(email: (sender.superview as! UserView).email.text!, username: (sender.superview as! UserView).username.text!, password: (sender.superview as! UserView).password.text!,completionhandler: {(_ json:JSON?)->Void in
            
            
        })
    }
    
}
