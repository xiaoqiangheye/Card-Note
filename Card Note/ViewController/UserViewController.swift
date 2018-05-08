//
//  UserViewController.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/14.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
class UserViewController:UIViewController{
    @IBOutlet weak var collect: UIButton!
    @IBOutlet weak var like: UIButton!
    @IBOutlet weak var branch: UIButton!
    @IBAction func logout(_ sender: Any) {
        ifloggedin = false
        UserDefaults.standard.set("", forKey: Constant.Key.Token)
        loggedusername = ""
        loggedID = ""
        loggedemail = ""
        performSegue(withIdentifier: "login", sender: "logout")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as! String == "logout"{
            (segue.destination as! SignUpController).former = "logout"
        }
    }
    @IBOutlet weak var userLabel: UILabel!
    override func viewDidLoad() {
        collect.setFAIcon(icon: .FAUserPlus, forState: .normal)
        like.setFAIcon(icon: .FAHeart, forState: .normal)
        branch.setFAIcon(icon: .FACodeFork, forState: .normal)
        if (ifloggedin){
            userLabel.text = loggedusername
        }
    }
}
