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
        if (ifloggedin){
            userLabel.text = loggedusername
        }
    }
}
