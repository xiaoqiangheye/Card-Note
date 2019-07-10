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
import SCLAlertView
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
        fromLanguageLabel.addTarget(self, action: #selector(tapped), for: .touchDown)
        superCard.addSubview(fromLanguageLabel)
    
        revertButton = UIButton(frame: CGRect(x: superCard.frame.width/3, y: 0, width: superCard.frame.width/3, height: 50))
        revertButton.setTitleColor(Constant.Color.themeColor, for: .normal)
        revertButton.setFAIcon(icon: .FAExchange, iconSize: 25, forState: .normal)
        revertButton.addTarget(self, action: #selector(revert), for: .touchDown)
        superCard.addSubview(revertButton)
        
        toLanguageLabel = UIButton(frame: CGRect(x: superCard.frame.width/3*2, y: 0, width: superCard.frame.width/3, height: 50))
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
    
    @objc private func copyTranslatedText(){
        UIPasteboard.general.string = translatedText.text
        AlertView.show(success: "Copied to Pasteboard.")
    }
    
    
    @objc private func tapped(_ sender:UIButton){
        let label = sender
            let vc = OptionViewController()
            vc.setTitle(string: "Languages")
            vc.modalPresentationStyle = .overCurrentContext
        if label == toLanguageLabel{
            var strings = languageDictionary?.allKeys as! [String]
            strings.sort()
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
    
    //revert the two languages
    @objc private func revert(){
        if fromLanguageLabel.title(for: .normal) != "Auto"{
       let tmp = fromLanguageLabel.title(for: .normal)
       fromLanguageLabel.setTitle(toLanguageLabel.title(for: .normal), for: .normal)
       toLanguageLabel.setTitle(tmp, for: .normal)
        }
    }
    
    @objc func dismissView(){
        dismiss(animated: true, completion: nil)
    }
    
    
    //translate
    func translate(from:String,to:String,text:String){
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
    
    //translation the text in the textbox
    @objc private func trans(){
            if self.originalText.text.count > 0{
                self.translate(from:self.fromLanguageLabel.title(for: .normal)!, to:self.toLanguageLabel.title(for: .normal)!, text: self.originalText.text)
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
