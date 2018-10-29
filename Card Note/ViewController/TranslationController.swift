//
//  TranslationController.swift
//  Card Note
//
//  Created by 强巍 on 2018/8/20.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

var languageDictionary = NSDictionary(contentsOf: URL(fileURLWithPath:Bundle.main.path(forResource: "languageList", ofType: "plist")!))
class TranslationController:UIViewController{
    var backButton:UIButton!
    var superCard:UIView!
    var fromLanguageLabel:UIButton!
    var toLanguageLabel:UIButton!
    var revertButton:UIButton!
    var originalText:UITextView!
    var translatedText:UITextView!
    var conversionButton:UIButton!
    var translateButton:UIButton!
    var copyButton:UIButton!
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
       // let centerDefault = NotificationCenter.default
       // centerDefault.addObserver(self, selector: #selector(keyboadWillExit(aNotification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.8)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        backButton = UIButton(frame: CGRect(x: 25, y: 25, width: 30, height: 30))
        backButton.setFAIcon(icon: FAType.FATimes, iconSize: 30, forState: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        self.view.addSubview(backButton)
        
        superCard = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 500))
        superCard.backgroundColor = .white
        superCard.layer.cornerRadius = 10
        superCard.center = self.view.center
        superCard.clipsToBounds = true
        self.view.addSubview(superCard)
        
        
       // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        fromLanguageLabel = UIButton(frame: CGRect(x: 0, y: 0, width: superCard.frame.width/3, height: 50))
       // fromLanguageLabel.textAlignment = .center
        fromLanguageLabel.setTitle("Auto", for: .normal)
        fromLanguageLabel.setTitleColor(Constant.Color.themeColor, for: .normal)
        //fromLanguageLabel.textColor = Constant.Color.themeColor
       // fromLanguageLabel.font = UIFont.systemFont(ofSize: 20)
       // fromLanguageLabel.text = "Auto"
       // fromLanguageLabel.isUserInteractionEnabled = true
       // fromLanguageLabel.layer.borderWidth = 1
        //fromLanguageLabel.layer.borderColor = UIColor.black.cgColor
        fromLanguageLabel.addTarget(self, action: #selector(tapped), for: .touchDown)
        superCard.addSubview(fromLanguageLabel)
    
        revertButton = UIButton(frame: CGRect(x: superCard.frame.width/3, y: 0, width: superCard.frame.width/3, height: 50))
        revertButton.setTitleColor(Constant.Color.themeColor, for: .normal)
        revertButton.setFAIcon(icon: .FAExchange, iconSize: 25, forState: .normal)
        revertButton.addTarget(self, action: #selector(revert), for: .touchDown)
        superCard.addSubview(revertButton)
        
        toLanguageLabel = UIButton(frame: CGRect(x: superCard.frame.width/3*2, y: 0, width: superCard.frame.width/3, height: 50))
      //  toLanguageLabel.textAlignment = .center
        //toLanguageLabel.textColor = Constant.Color.themeColor
       // toLanguageLabel.font = UIFont.systemFont(ofSize: 20)
       // toLanguageLabel.text = "English"
        //toLanguageLabel.isUserInteractionEnabled = true
        toLanguageLabel.setTitle("English", for: .normal)
        toLanguageLabel.setTitleColor(Constant.Color.themeColor, for: .normal)
        toLanguageLabel.addTarget(self, action: #selector(tapped), for: .touchDown)
        superCard.addSubview(toLanguageLabel)
        
        originalText = UITextView(frame: CGRect(x: 0, y: 50, width: self.view.frame.width * 0.8, height: 200))
        originalText.delegate = self
        superCard.addSubview(originalText)
        
        
        translatedText = UITextView(frame: CGRect(x: 0, y: 250, width: self.view.frame.width * 0.8, height: 250))
        translatedText.backgroundColor = Constant.Color.themeColor
        translatedText.textColor = .white
        translatedText.isEditable = false
        superCard.addSubview(translatedText)
        
        copyButton = UIButton(frame: CGRect(x: superCard.frame.width - 50, y: 500 - 50, width: 30, height: 30))
        copyButton.setFAIcon(icon: .FACopy, iconSize:30,forState: .normal)
        copyButton.setFATitleColor(color: Constant.Color.blueRight)
        copyButton.layer.cornerRadius = 15
        copyButton.backgroundColor = .white
        copyButton.addTarget(self, action: #selector(copyTranslatedText), for: .touchDown)
        copyButton.isHidden = true
        superCard.addSubview(copyButton)
        
        translateButton = UIButton(frame: CGRect(x: superCard.frame.width - 50, y: 200, width: 30, height: 30))
        translateButton.setFAIcon(icon: .FAArrowCircleRight, iconSize: 30, forState: .normal)
        translateButton.setFATitleColor(color: Constant.Color.blueRight)
        translateButton.layer.cornerRadius = 15
        translateButton.backgroundColor = .white
        translateButton.addTarget(self, action: #selector(self.trans), for: .touchDown)
        if originalText.text.count == 0{
        translateButton.isHidden = true
        }
        superCard.addSubview(translateButton)
        superCard.bringSubview(toFront: fromLanguageLabel)
    }
    
    @objc func copyTranslatedText(){
        UIPasteboard.general.string = translatedText.text
        AlertView.show(success: "Copied to Pasteboard.")
    }
    
    @objc func tapped(_ sender:UIButton){
        let label = sender
            let vc = OptionViewController()
            vc.modalPresentationStyle = .overCurrentContext
        if label == toLanguageLabel{
            var strings = languageDictionary?.allKeys as! [String]
            var index = 0
            for string in strings{
                if string == "Auto"{strings.remove(at: index)}
                index += 1
            }
            vc.loadOptions(strings: strings) { (string) in
                label.setTitle(string, for: .normal)
            }
        }else{
            vc.loadOptions(strings: languageDictionary?.allKeys as! [String]) { (string) in
                label.setTitle(string, for: .normal)
            }
        }
            self.present(vc, animated: true, completion: nil)
    }
    
    @objc func revert(){
        if fromLanguageLabel.title(for: .normal) != "Auto"{
       let tmp = fromLanguageLabel.title(for: .normal)
       fromLanguageLabel.setTitle(toLanguageLabel.title(for: .normal), for: .normal)
       toLanguageLabel.setTitle(tmp, for: .normal)
        }
    }
    
    @objc func dismissView(){
        dismiss(animated: true, completion: nil)
    }
    
    private func translate(from:String,to:String,text:String){
        var f = ""
        if from != "Auto"{
        f = languageDictionary![from] as! String
        }else{
        f = "auto"
        }
        let to = languageDictionary![to] as! String
        if from == to{
            self.translatedText.text = self.originalText.text
            return
        }
        
        
        //textporarily disable youdao translate
        /*
        TranslationManager.translate(text: text, from: from, to: to) {[unowned self] (string) in
            if string == nil{
                //error
                AlertView.show(error: "An Error Occur.")
            }else{
               self.translatedText.text = string
              self.copyButton.isHidden = false
           // self.view.addSubview(self.translatedText)
            }
        }
        */
        TranslationManager.gTranslate(text: text, toLanguage: to, fromLanguage: f) {[unowned self] (string) in
            if string == nil{
                //error
                DispatchQueue.main.async {
                AlertView.show(error: "Translation Failed. An Unknown Error Occur.")
                }
            }else{
                DispatchQueue.main.async {
                self.translatedText.text = string
                self.copyButton.isHidden = false
                }
                // self.view.addSubview(self.translatedText)
            }
        }
    }
    
    @objc private func trans(){
        if originalText.text.count > 0{
        translate(from:fromLanguageLabel.title(for: .normal)!, to:toLanguageLabel.title(for: .normal)!, text: originalText.text)
        }
    }
    
}

extension TranslationController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count > 0{
            translateButton.isHidden = false
        }else{
            translateButton.isHidden = true
        }
    }
}
