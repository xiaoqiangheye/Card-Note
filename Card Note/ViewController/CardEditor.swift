//
//  CardEditor.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/4.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Font_Awesome_Swift
import ChameleonFramework
import Hero
import MapboxGeocoder
import MobileCoreServices
import Spring


class CardEditor:UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, MAMapViewDelegate,UIMapPickerDelegate,UIActionSheetDelegate,AttributedTextViewDelegate, UIPickerViewDelegate,UIPickerViewDataSource,CardEditorDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate{
    //main components
    weak var delegate:CardEditorDelegate?
    var isSubCard:Bool = false
    var cardTitle: UITextView!
    var tag: UITextView!
    var definition: UITextView!
    var descriptions: UITextView!
    var definitionLabel:UILabel!
    var tagInputView: TagInputView!
    var scrollView:UIScrollView!
    var cardColor:UIView!
   // var cardBackGround = UIView()
    var attributedView:AttributedTextView?
    var pickerView:UIPickerView!
    var pickerColorView:UIView!
    var doneButton: UIButton!
    @IBOutlet var addButton: UIButton!
    var color:UIColor = Constant.Color.blueLeft
    var card:Card?
    var type:CardEditor.type?
    var textMode:Constant.TextMode!
    var subCards:[CardView] = [CardView]()
    /////////addButton
    var toolBox:SpringView!
    var addButtonStateisOpen:Bool = false
    var addSubCard:UIView!
    var addPicCard:UIView!
    var addExa:UIView!
    var addText:UIView!
    var addVoiceView:UIView!
    var addMapView:UIView!
    var addMovieView:UIView!
    var addButtonList = [UIView]()
    ///////////////////////////////
    var cumulatedheight:Int = 0
    //////////show palette/////
    var ifPaletteShowed:Bool = false
    /////pictureAction/////
    var picTureAction:String = ""
    var mapAction:String = ""
    /////////selected
    var selectedPictureView:CardView.PicView?
    var selectedTextView:UITextView?
    var selectedView:UIView?
    var selectedMapView:CardView.MapCardView?
   // private var EditingSubCard:[CardEditorView] = [CardEditorView]()
    //textMode
    var isEditMode = false
    var modeButton:UIButton!
    //leadingBar
   // var leardingBar:UIView!
/** pickerViewDelegate
  numberOfComponents
  numberOfRows
  title
 */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        /* deprecated font
        if component == 0{
        return UIFont.familyNames.count
        }else{
        return 72
        }
      */
        return 72
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /*deprecated
        if component == 0{
        return UIFont.familyNames[row]
        }else{
        return String(row + 1)
        }
        */
        return String(row + 1)
    }
    
    
    //AttributedText
    func selectFont(height:CGFloat)
    {
        let view = UIView(frame: CGRect(x:0, y: height + (attributedView?.frame.height)!, width:  UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - height - (attributedView?.frame.height)!))
        if Int((attributedView?.font?.pointSize)!) >= 1{
        pickerView.selectRow(Int((attributedView?.font?.pointSize)!) - 1, inComponent: 0, animated: true)
        }else{
        pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        view.addSubview(pickerView)
        view.addSubview(pickerColorView)
        pickerColorView.backgroundColor = attributedView?.fontColor == nil ? UIColor.black : attributedView?.fontColor
       
        selectedTextView?.resignFirstResponder()
        selectedTextView?.inputView = view
        selectedTextView?.inputAccessoryView = attributedView
        selectedTextView?.becomeFirstResponder()
        let pickerViewDone = UIButton(frame: CGRect(x: pickerView.frame.width*2 - 50, y:0, width: 100, height: 100))
        pickerViewDone.setTitle("Done", for: .normal)
        pickerViewDone.setFAIcon(icon: FAType.FATimesCircle, forState: .normal)
        pickerViewDone.setTitleColor(UIColor.black, for: .normal)
        pickerViewDone.addTarget(self, action: #selector(getPickerViewValue), for: .touchDown)
        view.addSubview(pickerViewDone)
    }
    
    //ActionSheet
   

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedView = textField
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedView = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.frame.origin.y = 0
        }, completion: nil)
        textField.resignFirstResponder()
        selectedTextView = nil
        selectedView = nil
    }
/**TextView
 */
    
    private var lastSelectedLocation = 0
    private var currentSelectedLocation = 0
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.lengthOfBytes(using: .utf8) < 1{
            switch textView{
            case cardTitle:
            textView.text = "Title"
            case tag:
                textView.text = "class"
            case definition:
                textView.text = "Definition"
            case descriptions:
                textView.text = "Description"
            default:
                break
            }
            textView.textColor = .gray
            
            if subCards.count > 0{
                if (subCards.last?.isKind(of:CardView.TextView.self))!{
                    subCards.last?.removeFromSuperview()
                    subCards.removeLast()
                }
            }
        }
       
        textView.backgroundColor = .clear
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.frame.origin.y = 0
        }, completion: nil)
        textView.resignFirstResponder()
        attributedView?.removeFromSuperview()
        attributedView = nil
    }
    
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
    lastSelectedLocation = currentSelectedLocation
        currentSelectedLocation = textView.selectedRange.location
        if attributedView != nil{
            if textView.selectedRange.location >= 1{
           let character = textView.text[textView.text.index(textView.text.startIndex, offsetBy: currentSelectedLocation - 1)]
                print(character)
                
                if character == "\u{2022}"{
                     self.attributedView?.reset()
                     self.attributedView?.update(at: textView.selectedRange.location - 1)
                }else if character == "." && currentSelectedLocation >= 2{
                    if let lastCharacter = Int(String(textView.text[textView.text.index(textView.text.startIndex, offsetBy: currentSelectedLocation - 2)])){
                        var range = NSRange()
                        let attributeOfLigature = (textView.attributedText.attribute(NSAttributedStringKey.ligature, at: currentSelectedLocation - 1, effectiveRange: &range)) == nil ? 0 : 1
                        let attributeOfFont = (textView.attributedText.attribute(NSAttributedStringKey.ligature, at: currentSelectedLocation - 1, effectiveRange: &range)) as? UIFont
                        if attributeOfLigature == 1 || attributeOfFont == UIFont(name: "Avenir-Medium", size: 18){
                           self.attributedView?.reset()
                           self.attributedView?.update(at: textView.selectedRange.location - 1)
                        }
                    }
                }else if character != "\n"{
                   self.attributedView?.update(at: textView.selectedRange.location - 1)
                    //self.attributedView?.update(at: textView.selectedRange.location - 1)
                }else{
                    self.attributedView?.reset()
                    self.attributedView?.isUnorderedListAtCurrentSelectedLine()
                    self.attributedView?.isOrderedListAtSelectedLocation()
                }
            }
        }
    }
    

    var lastNumOfLines = 1
    var currentNumOfLines = 1
    var lastCharacter = ""
    var currentCharacter = ""
    func textViewDidChange(_ textView: UITextView) {
        lastCharacter = currentCharacter
        if textView.selectedRange.location > 0{
        currentCharacter = String(textView.text[textView.text.index(textView.text.startIndex, offsetBy: textView.selectedRange.location - 1)])
        }else{
        currentCharacter = ""
        }
    
       // lastNumOfLines = currentNumOfLines
       // currentNumOfLines = Int(textView.contentSize.height/(textView.font?.lineHeight)!)
        
        //save to files
        if textView.superview != nil{
            if (textView.superview?.isKind(of: CardView.ExaView.self))!{
                let view = textView.superview as! CardView.ExaView
                let data = try? view.textView.attributedText.data(from: NSMakeRange(0, view.textView.attributedText.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf])
                var url = Constant.Configuration.url.attributedText
                url.appendPathComponent(view.card.getId() + ".rtf")
                do{
                    try data?.write(to: url)
                }catch let error{
                    print(error.localizedDescription)
                }
            }else if (textView.superview?.isKind(of: CardView.TextView.self))!{
                let view = textView.superview as! CardView.TextView
                let data = try? view.textView.attributedText.data(from: NSMakeRange(0, view.textView.attributedText.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf])
                var url = Constant.Configuration.url.attributedText
                url.appendPathComponent(view.card.getId() + ".rtf")
                do{
                    try data?.write(to: url)
                }catch let error{
                    print(error.localizedDescription)
                }
            }
        }
        
        let y = scrollView.contentOffset.y
        let frame = textView.frame
        
        //定义一个constrainSize值用于计算textview的高度
        
        let constrainSize=CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        
        //获取textview的真实高度
        var size = textView.sizeThatFits(constrainSize)
        
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        if textView.superview != nil{
            if let cardView = textView.superview as? CardView.TextView{
                textView.frame.size.height = size.height
                textView.superview?.frame.size.height = size.height
                reLoad()
                /*
                var origin = (textView.superview?.frame.origin.y)! + (textView.superview?.frame.height)! + 20
                guard let index = subCards.index(of: cardView) else{return}
                if index < subCards.count - 1{
                for i in index + 1...subCards.endIndex - 1{
                      let card = subCards[i]
                        card.frame.origin.y = origin
                        origin = card.frame.origin.y + card.frame.height + 20
                }
                }
                 cardBackGround.frame.size.height = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
                 scrollView.contentSize.height = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
                 scrollView.contentOffset.y = y
                */
        
            }else if let cardView = textView.superview as? CardView.ExaView{
                textView.frame.size.height = size.height
                textView.superview?.frame.size.height = textView.frame.origin.y + textView.frame.height
            }
            else if textView == definition{
                textView.frame.size.height = size.height
                reLoad()
            }
        }
        
      //Mode Caculation
        if textView.text.count > 0{
            if attributedView?.textMode == Constant.TextMode.UnorderedListMode && lastSelectedLocation - currentSelectedLocation == -1 && currentCharacter == "\n"{
                attributedView?.setUnorderedList()
            }
            /*
            else if (attributedView?.textMode == Constant.TextMode.UnorderedListMode || attributedView?.textMode == Constant.TextMode.OrderedListMode) && lastSelectedLocation > currentSelectedLocation{
                attributedView?.textMode = Constant.TextMode.UnorderedListEndMode
                attributedView?.setOrderedList()
                attributedView?.setOrderedList()
            }
             */
                
            else if attributedView?.textMode == Constant.TextMode.OrderedListMode && lastSelectedLocation - currentSelectedLocation == -1 && currentCharacter == "\n"{
                attributedView?.setOrderedList()
            }
             attributedView?.isUnorderedListAtCurrentSelectedLine()
             attributedView?.isOrderedListAtSelectedLocation()
          
            
            if lastCharacter == "\u{2022}" && lastSelectedLocation - currentSelectedLocation == 1{
                attributedView?.textMode = Constant.TextMode.OrderedListEndMode
                attributedView?.setUnorderedList()
                /*
                let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
                let attributedSpace = NSAttributedString(string: " ")
                attributedString.insert(attributedSpace, at: textView.selectedRange.location)
                textView.attributedText = attributedString
                textView.selectedRange.location += 1
                */
                attributedView?.setUnorderedList()
            }
        }
        
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentSelectedLocation = textView.selectedRange.location
       
       textView.backgroundColor = UIColor.clear
      //textView.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
       selectedTextView = textView
       selectedView = textView
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        selectedTextView = textView
        selectedView = textView
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        selectedTextView = textView
        selectedView = textView
        return true
    }
    
  

    override func viewWillAppear(_ animated: Bool) {
        cardTitle.delegate = self
       // tag.delegate = self
        definition.delegate = self
      //  descriptions.delegate = self
         if self.type == CardEditor.type.add{
           textViewDidEndEditing(cardTitle)
          // textViewDidEndEditing(tag)
           textViewDidEndEditing(definition)
         }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setColor(color:UIColor){
        gl.removeFromSuperlayer()
        gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:100);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [color.cgColor,getRightColorFromLeftGradient(left: color).cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        cardColor.layer.addSublayer(gl)
        cardColor.bringSubview(toFront: cardTitle)
        tagInputView.plusButton.setTitleColor(color, for: .normal)
    }
    
    var gl:CAGradientLayer!
    override func viewDidLoad() {
        self.hero.isEnabled = true
        self.view.hero.id = "batman"
        self.view.backgroundColor = .clear
        
        //backGround
        gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:100);
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        if card != nil{
            gl.colors = [card?.getColor().cgColor,getRightColorFromLeftGradient(left: (card?.getColor())!).cgColor]
        }else{
             gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        }
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        
        cardColor = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        cardColor.layer.addSublayer(gl)
        
        
        
        doneButton = UIButton()
        doneButton.setFAIcon(icon: FAType.FATimes,iconSize: 30,forState: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.frame = CGRect(x: self.view.frame.width - 50, y: 20, width: 30, height: 30)
        doneButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        
        
        /*deprecated Leading Bar
        //leadingBar
        leardingBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50 + CGFloat(UIDevice.current.Xdistance())))
        self.view.addSubview(leardingBar)
        
        doneButton = UIButton()
        doneButton.setFAIcon(icon: FAType.FAMinusCircle,iconSize: 30,forState: .normal)
        doneButton.setTitleColor(.red, for: .normal)
        doneButton.frame = CGRect(x: self.view.frame.width - 50, y: 10 + CGFloat(UIDevice.current.Xdistance()), width: 30, height: 30)
        doneButton.addTarget(self, action: #selector(save(_:)), for: .touchDown)
        self.leardingBar.addSubview(doneButton)
        */
        //mode button
        
        modeButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 50, width: 30, height: 30))
        modeButton.center.y = 50
        modeButton.setBackgroundImage(UIImage(named: "edit"), for: .normal)
        modeButton.setTitleColor(.clear, for: .normal)
        modeButton.addTarget(self, action: #selector(modeChanged), for: .touchDown)
        modeButton.layer.cornerRadius = 15
        if self.type == .add{
            modeButton.isHidden = true
        }
        
        //addButton
        addButton.setBackgroundImage(UIImage(named: "plusButton"), for: .normal)
        addButton.setTitleColor(.clear, for: .normal)
        addButton.frame.origin = CGPoint(x: self.view.frame.width - 50, y: self.view.frame.height - 200)
        addButton.frame.size = CGSize(width: 50, height: 50)
        
        
        cardTitle = UITextView()
        cardTitle.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: 50)
        cardTitle.textColor = .white
        cardTitle.backgroundColor = .clear
        cardTitle.center.x = self.view.bounds.width/2
        cardTitle.center.y = 50
        cardTitle.layer.cornerRadius = 10
        cardTitle.textAlignment = .center
        cardTitle.font = UIFont.boldSystemFont(ofSize: 20)
        cardTitle.isScrollEnabled = false
        cardColor.addSubview(cardTitle)
        /*deprecated in 8.14
        tag.frame = CGRect(x: 0, y: cardTitle.frame.height + cardTitle.frame.origin.y + 20, width: self.view.bounds.width*0.8, height: 30)
        tag.font =  UIFont(name: "ChalkboardSE-Regular", size: 15)
        tag.textColor = .black
        tag.backgroundColor = .clear
        tag.center.x = self.view.bounds.width/2
        tag.layer.cornerRadius = 10
        */
        
        tagInputView = TagInputView(frame: CGRect(x: 0, y: 100 - 15, width: self.view.bounds.width*0.9, height: 50), tags:[String]())
        tagInputView.delegate = self
        tagInputView.center.x = self.view.frame.width/2
        if card != nil{
            tagInputView.plusButton.setTitleColor(card?.getColor(), for: .normal)
            tagInputView.loadTag(tags: (card?.getTag())!)
            color = (card?.getColor())!
        }else{
            color = Constant.Color.blueLeft
        }
        definitionLabel = UILabel()
        definitionLabel.font =  UIFont.systemFont(ofSize: 20)
        definitionLabel.text = "Definition"
        definitionLabel.frame = CGRect(x:20, y: tagInputView.frame.origin.y + tagInputView.frame.height + 20, width: self.view.bounds.width, height: 20)
        definitionLabel.textColor = .black
        
        definition = UITextView()
        definition.frame = CGRect(x: 0, y: definitionLabel.frame.origin.y + definitionLabel.frame.height + 20, width: self.view.bounds.width*0.8, height: 100)
        definition.font = UIFont.systemFont(ofSize: 18)
        definition.textColor = .black
        definition.backgroundColor = .black
        definition.center.x = self.view.bounds.width/2
        definition.layer.cornerRadius = 10
        definition.isScrollEnabled = false
        definition.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
        if self.card != nil{
            definition.text = card?.getDefinition()
            let constrainSize = CGSize(width:definition.frame.size.width,height:CGFloat(MAXFLOAT))
            definition.sizeThatFits(constrainSize)
        }
      
        /*
        let descriptionLabel = UILabel()
        descriptionLabel.font =  UIFont(name: "ChalkboardSE-Bold", size: 20)
        descriptionLabel.text = "Description"
        descriptionLabel.textColor = .black
        descriptionLabel.frame = CGRect(x: 20, y: definition.frame.origin.y + definition.frame.height + 20, width: self.view.bounds.width, height: 20)
        
        descriptions.frame = CGRect(x:0, y: descriptionLabel.frame.height + descriptionLabel.frame.origin.y + 20, width: self.view.bounds.width*0.8, height: 200)
        descriptions.font = UIFont(name: "ChalkboardSE-Regular", size: 18)
        descriptions.textColor = .black
        descriptions.backgroundColor = .clear
        descriptions.center.x = self.view.bounds.width/2
        descriptions.layer.cornerRadius = 10
        descriptions.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
 
        
        let contentLabel = UILabel()
       contentLabel.font =  UIFont(name: "ChalkboardSE-Bold", size: 20)
       contentLabel.text = "Content"
       contentLabel.textColor = .black
       contentLabel.frame = CGRect(x: 20, y: descriptions.frame.origin.y + descriptions.frame.height + 20, width: self.view.bounds.width, height: 20)
        
        */
    
        /*
        cardBackGround = UIView()
        cardBackGround.frame = CGRect(x: 0, y: CGFloat(-UIDevice.current.Xdistance()), width: self.view.bounds.width, height:  self.view.bounds.height)
        cardBackGround.backgroundColor = .white
        cardBackGround.addSubview(cardColor)
        cardBackGround.addSubview(cardTitle)
        cardBackGround.addSubview(definition)
        //cardBackGround.addSubview(descriptions)
        cardBackGround.addSubview(definitionLabel)
        cardBackGround.addSubview(tagInputView)
       */
        
       
        
       // cardBackGround.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(showPalette(_:)))
       cardColor.addGestureRecognizer(tapGesture)
        
       // let swipe = UISwipeGestureRecognizer(target: self, action: #selector(viewSwiped))
        //cardColor.addGestureRecognizer(swipe)
         //cardTitle.addGestureRecognizer(swipe)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewPaned))
        cardColor.addGestureRecognizer(pan)
      //cardTitle.addGestureRecognizer(pan)
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        scrollView.delegate = self
        scrollView.backgroundColor = .white
        //scrollView.layer.cornerRadius = 15
        scrollView.isScrollEnabled = true
        scrollView.bounces = true
        scrollView.contentOffset.y = 0
        scrollView.contentSize.height = self.view.bounds.height
        scrollView.contentSize.width = self.view.bounds.width
        scrollView.addSubview(cardColor)
        if self.type == .add{
        scrollView.addSubview(doneButton)
        }
       // scrollView.addSubview(cardTitle)
        scrollView.addSubview(definition)
        //cardBackGround.addSubview(descriptions)
        scrollView.addSubview(definitionLabel)
        scrollView.addSubview(tagInputView)
        scrollView.addSubview(modeButton)
        
        let endEditingGesture = UITapGestureRecognizer()
        endEditingGesture.numberOfTapsRequired = 1
        endEditingGesture.numberOfTouchesRequired = 1
        endEditingGesture.addTarget(self, action: #selector(endEditing))
        endEditingGesture.addTarget(self, action: #selector(turnOffToolBox))
        endEditingGesture.addTarget(self, action: #selector(autoAddTextViewAtBottom))
        scrollView.addGestureRecognizer(endEditingGesture)
        
        if card != nil{
            loadCard(card: card!)
        }
        
       self.view.addSubview(scrollView)
        

      self.view.bringSubview(toFront: addButton)
        
    let centerDefault = NotificationCenter.default
        centerDefault.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
         pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 300))
         pickerView.dataSource = self
         pickerView.backgroundColor = UIColor.white
         //将delegate设置成自己
         pickerView.delegate = self
         pickerView.selectRow(0, inComponent: 0, animated: true)
        
         pickerColorView = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2, y: 0, width: UIScreen.main.bounds.width/2, height: 300))
        let showPalette = UITapGestureRecognizer(target: self, action: #selector(showPalette(_:)))
        showPalette.numberOfTapsRequired = 1
        showPalette.numberOfTouchesRequired = 1
        pickerColorView.addGestureRecognizer(showPalette)
        
    }
    
    
    @objc func modeChanged(){
        if isEditMode{
            isEditMode = false
            modeButton.setBackgroundImage(UIImage(named:"edit"), for: .normal)
            modeButton.setTitle("", for: .normal)
            modeButton.backgroundColor = .clear
            for subCard in subCards{
                subCard.observeMode()
            }
        }else{
            isEditMode = true
            modeButton.setBackgroundImage(nil, for: .normal)
            modeButton.setFAIcon(icon: FAType.FACheckCircle, iconSize: 30,forState: .normal)
            modeButton.setTitleColor(.white, for: .normal)
            modeButton.backgroundColor = .clear
            for subCard in subCards{
                subCard.editMode()
            }
        }
    }
 
    
    @objc func viewSwiped(gesture:UISwipeGestureRecognizer){
        if gesture.state == .ended && gesture.direction == .down{
          self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    var isSaved = false
    @objc func viewPaned(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed{
            self.view.center.x += gesture.translation(in: gesture.view).x
            self.view.center.y += gesture.translation(in: gesture.view).y
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: gesture.view)
            if gesture.velocity(in: gesture.view).y > 100 && isSaved == false{
             isSaved = true
                self.dismiss(animated: true) {
                    self.save(gesture.view)
                }
            }
        }else if gesture.state == .cancelled || gesture.state == .ended{
            UIView.animate(withDuration: 0.3) {
                 self.view.frame.origin = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    
    //color picker
    @objc func getPickerViewValue(sender:UIButton){
        ifPaletteShowed = false
        if attributedView != nil{
           /*deprecated
            let row = pickerView.selectedRow(inComponent: 0)
            attributedView?.setFont(fontName: UIFont.familyNames[row])
            */
            let size = pickerView.selectedRow(inComponent: 0) + 1
            attributedView?.setFontSize(size: CGFloat(size))
            
            let color = pickerColorView.backgroundColor
            attributedView?.setFontColor(color: color!)
        }
        selectedTextView?.resignFirstResponder()
        selectedTextView?.inputView = nil
        selectedTextView?.becomeFirstResponder()
    }
    
    
    
    @objc func keyboardWillShow(aNotification: NSNotification){
        print("keyBoardShow")
        let userinfo: NSDictionary = aNotification.userInfo! as NSDictionary
        let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (nsValue as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        guard UIApplication.shared.keyWindow != nil else {
            return
        }
        
        if (selectedTextView != nil){
            //add the attributed view
            if attributedView != nil && attributedView?.superview != nil{
                attributedView?.removeFromSuperview()
            
             if (selectedTextView?.superview?.isKind(of: CardView.TextView.self))!{
            attributedView = AttributedTextView(y: self.view.frame.height - height! - 50, textView: selectedTextView!)
            attributedView?.delegate = self
            self.view.addSubview(attributedView!)
            }
            }
         }
        
        if selectedView != nil{
        //adjust the offset of the scrollview
        var relativeHeight:CGFloat!
        
        if !(selectedView?.superview?.isKind(of: CardView.TextView.self))! && !(selectedView?.superview?.isKind(of: CardView.SubCardView.self))! && !(selectedView?.superview?.isKind(of: CardView.PicView.self))! && !(selectedView?.superview?.isKind(of: CardView.ExaView.self))! && !(selectedView?.superview?.isKind(of: CardView.VoiceCardView.self))!{
            relativeHeight = (selectedView?.frame.origin.y)! - scrollView.contentOffset.y  + (selectedView?.frame.height)! + CGFloat(UIDevice.current.Xdistance())
        }else{
            relativeHeight = (selectedView?.superview?.frame.origin.y)! - scrollView.contentOffset.y  + (selectedView?.superview?.frame.height)! + CGFloat(UIDevice.current.Xdistance())
            
        }
       
        let heightDifference = relativeHeight - (self.view.frame.height - height!)
        if heightDifference > 0{
            UIView.animate(withDuration: 0.5) {
                self.scrollView.contentOffset.y += heightDifference
            }
        }
        }
 
    }
    
    //card type
    enum type:String{
        case add = "add"
        case save = "save"
    }
    //end cardType
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    @objc func showPalette(_ sender:UIGestureRecognizer){
        if !ifPaletteShowed{
        //let location = sender.location(in: cardBackGround)
        let location = sender.location(in:sender.view)
        let palette = Palette(frame: CGRect(x: location.x, y: location.y, width: 150, height: 150))
        palette.delegate = self
        palette.center = location
        var colors:[UIColor] = [UIColor]()
        colors.append(Constant.Color.redLeft)
        colors.append(Constant.Color.blueLeft)
        colors.append(Constant.Color.greenLeft)
        palette.addColors(colors)
        palette.parentView = sender.view
        palette.viewController = self
        sender.view?.addSubview(palette)
        sender.view?.bringSubview(toFront: palette)
        ifPaletteShowed = true
        }else{
            for subView in (sender.view?.subviews)!{
                if subView.isKind(of: Palette.self){
                subView.removeFromSuperview()
                ifPaletteShowed = false
                }
            }
        }
    }
    
    //cardView LongTap
    @objc func longTap(_ sender:UILongPressGestureRecognizer){
      
    }
    
    
    func deleteButtonClicked(view:CardView) {
        var index = 0
        view.removeFromSuperview()
        let fileManager = FileManager.default
        do{
        if view.isKind(of: CardView.TextView.self){
            try fileManager.removeItem(at: Constant.Configuration.url.attributedText.appendingPathComponent(view.card.getId() + ".rtf"))
        }else if view.isKind(of: CardView.PicView.self){
             try fileManager.removeItem(at: Constant.Configuration.url.PicCard.appendingPathComponent(view.card.getId() + ".jpg"))
        }else if view.isKind(of: CardView.VoiceCardView.self){
             try fileManager.removeItem(at: Constant.Configuration.url.Audio.appendingPathComponent(view.card.getId() + ".wav"))
        }else if view.isKind(of: CardView.MovieView.self){
             try fileManager.removeItem(at: Constant.Configuration.url.Movie.appendingPathComponent(view.card.getId() + ".mov"))
        }else if view.isKind(of: CardView.MapCardView.self){
              try fileManager.removeItem(at: Constant.Configuration.url.Map.appendingPathComponent(view.card.getId() + ".jpg"))
        }
        }catch let error{
            print(error.localizedDescription)
        }
        for card in subCards{
            if card.card.getId() == view.card.getId(){
                subCards.remove(at: index)
                break
            }
            index += 1
        }
        
        reLoad()
    }
    
    
    // loadCard
    func loadCard(card:Card){
        self.card = card
        cardTitle.text = card.getTitle()
        scrollView.contentOffset.y = 0
        cardColor.backgroundColor = card.getColor()
       // self.view.backgroundColor = card.getColor()
        //tag.text = card.getTag()
        //tagInputView.loadTag(tags: (self.card?.getTag())!)
        definition.text = card.getDefinition()
        //descriptions.text = card.getDescription()
        color = card.getColor()
        //cardBackGround.backgroundColor = .white
       //leardingBar.backgroundColor = color
       // self.view.backgroundColor = color
        var cumulatedHeight = definition.frame.origin.y + definition.frame.height + 20
        for card in card.getChilds(){
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(cardViewPanned))
            panGesture.delegate = self
            if card.isKind(of: ExampleCard.self){
                let exaView = CardView.singleExampleView(card:card as! ExampleCard)
                exaView.textView.text = card.getDefinition()
                exaView.frame.origin.y = cumulatedHeight
                exaView.textView.delegate = self
                exaView.delegate = self
                exaView.title.delegate = self
                exaView.addGestureRecognizer(panGesture)
                cumulatedHeight += exaView.frame.height + 20
                scrollView.addSubview(exaView)
                self.subCards.append(exaView)
            }else if card.isKind(of: PicCard.self){
                let picCard = CardView.getSinglePicView(pic: card as! PicCard)
                picCard.delegate = self
                picCard.commentView.delegate = self
                picCard.addGestureRecognizer(panGesture)
                scrollView.addSubview(picCard)
                subCards.append(picCard)
               // picCard.image.image = #imageLiteral(resourceName: "searchBar")
                var url = Constant.Configuration.url.PicCard
                url.appendPathComponent(card.getId() + ".jpg")
                if FileManager.default.fileExists(atPath: (url.path)){
                    let data = NSData(contentsOf: url)
                    picCard.image.image = UIImage(data: data! as Data)
                    (card as! PicCard).pic = UIImage(data: data! as Data)
                }else{
                    picCard.image.image = #imageLiteral(resourceName: "searchBar")
                    DispatchQueue.global().async {
                        picCard.loadPic()
                    }
                }
                picCard.frame.origin.y = cumulatedHeight
                cumulatedHeight += picCard.frame.height + 20
                let tapGesture = UITapGestureRecognizer()
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                tapGesture.addTarget(self, action: #selector(updatePic))
                picCard.addGestureRecognizer(tapGesture)
            }else if card.isKind(of: TextCard.self){
                let textCard = (card as! TextCard)
                let textCardView = CardView.getSingleTextView(card:textCard)
                textCardView.delegate = self
                textCardView.frame.origin.y = cumulatedHeight
                textCardView.textView.delegate = self
                textCardView.addSubview(textCardView.textView)
                cumulatedHeight += textCardView.frame.height + 20
                textCardView.addGestureRecognizer(panGesture)
                scrollView.addSubview(textCardView)
                subCards.append(textCardView)
            }else if card.isKind(of: VoiceCard.self){
                let voiceCard = card as! VoiceCard
                let voiceCardView = CardView.getSingleVoiceView(card: voiceCard)
                voiceCardView.title.delegate = self
                voiceCardView.hero.id = voiceCard.getId()
                let gesture = UITapGestureRecognizer(target: self, action: #selector(voiceCardTapped(gesture:)))
                voiceCardView.addGestureRecognizer(gesture)
                voiceCardView.delegate = self
                voiceCardView.addGestureRecognizer(panGesture)
                if voiceCard.voiceManager!.state == .willRecord || voiceCard.voiceManager!.state == .recording || voiceCard.voiceManager!.state == .pausedRecording{
                    voiceCard.voiceManager?.state = .willRecord
                }else{
                    voiceCard.voiceManager?.state = .haveRecord
                }
                voiceCardView.frame.origin.y = cumulatedHeight
                cumulatedHeight += voiceCardView.frame.height + 20
                scrollView.addSubview(voiceCardView)
                subCards.append(voiceCardView)
            }else if card.isKind(of: MapCard.self){
                let mapCard = card as! MapCard
                let mapCardView = CardView.getSingleMapView(card: mapCard)
                mapCardView.delegate = self
                mapCardView.addGestureRecognizer(panGesture)
                let manager = FileManager.default
                var url = Constant.Configuration.url.Map
                url.appendPathComponent(card.getId() + ".jpg")
                if !manager.fileExists(atPath: (url.path)){
                    mapCardView.image.image = #imageLiteral(resourceName: "searchBar")
                    DispatchQueue.global().async {
                        mapCardView.loadPic()
                    }
                }else{
                    
                    mapCardView.image.image = UIImage(contentsOfFile: (url.path))
                }
                mapCardView.frame.origin.y = cumulatedHeight
                let tapgesture = UITapGestureRecognizer(target: self, action: #selector(updateMap))
                tapgesture.numberOfTapsRequired = 1
                tapgesture.numberOfTouchesRequired = 1
                mapCardView.addGestureRecognizer(tapgesture)
                cumulatedHeight += mapCardView.frame.height + 20
                scrollView.addSubview(mapCardView)
                subCards.append(mapCardView)
            }else if card.isKind(of: MovieCard.self){
                let movieCard = card as! MovieCard
                let movieCardView = CardView.getSingleMovieView(card: movieCard)
              
                movieCardView.delegate = self
                movieCardView.frame.origin.y = cumulatedHeight
                movieCardView.addGestureRecognizer(panGesture)
                 cumulatedHeight += movieCardView.frame.height + 20
                scrollView.addSubview(movieCardView)
                
                subCards.append(movieCardView)
            }
            else{
         let cardView = CardView.getSubCardView(card)
         cardView.delegate = self
         cardView.frame.origin.y = cumulatedHeight
         cardView.layer.shadowOpacity = 0.5
         cardView.layer.shadowColor = UIColor.black.cgColor
         cardView.layer.shadowOffset = CGSize(width:1, height:1)
        // cardView.title.delegate = self
         //cardView.content.delegate = self
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.addTarget(self, action: #selector(performCardEditor))
            cardView.addGestureRecognizer(tapGesture)
            cardView.addGestureRecognizer(panGesture)
         cumulatedHeight += cardView.frame.height + 20
         scrollView.addSubview(cardView)
         self.subCards.append(cardView)
       
        }
            if self.type == .add && isEditMode == false{
            modeChanged()
            }
            scrollView.contentSize.height = (subCards.last?.frame.height)! + (subCards.last?.frame.origin.y)! + 70
    }
        
        
    }
    
    func reLoad(){
       
        //definition.text = card?.getDefinition()
        //cardTitle.text = card?.getTitle()
        //tagInputView.loadTag(tags: (card?.getTag())!)
       // cardColor.backgroundColor = card?.getColor()
        let contentoffSetY = scrollView.contentOffset.y
        UIView.animate(withDuration:0.5){
            self.definitionLabel.frame.origin.y = self.tagInputView.frame.origin.y + self.tagInputView.frame.height + 20
        self.definition.frame.origin.y = self.definitionLabel.frame.origin.y + self.definitionLabel.frame.height + 20
        }
        var cumulatedHeight = definition.frame.origin.y + definition.frame.height + 20
        var index = 0
        for card in subCards{
            //adjust two adjacent textViews into one.
            if index < subCards.count - 1 && subCards[index].isKind(of: CardView.TextView.self) && subCards[index + 1].isKind(of: CardView.TextView.self){
                let view = subCards[index] as! CardView.TextView
                let nxtView = subCards[index + 1] as! CardView.TextView
                let viewAttributedText = view.textView.attributedText
                let mutable = NSMutableAttributedString(attributedString: viewAttributedText!)
                mutable.append(NSAttributedString(string: "\n"))
                mutable.append(nxtView.textView.attributedText)
                view.textView.attributedText = mutable
                view.textView.sizeToFit()
                nxtView.removeFromSuperview()
                subCards.remove(at: index + 1)
            }
            UIView.animate(withDuration: 0.5) {
            card.frame.origin.y = cumulatedHeight
            card.center.x = self.view.frame.width/2
            }
            cumulatedHeight += card.frame.height + 20
           // cardBackGround.addSubview(card)
         //   cardBackGround.frame.size.height = card.frame.origin.y + card.frame.height + 20
            self.scrollView.contentSize.height = card.frame.origin.y + card.frame.height + 20
            index += 1
        }
       // cardBackGround.frame.size.height += 50
        self.scrollView.contentSize.height += 50
        scrollView.contentOffset.y = contentoffSetY
    }
    //load card End
    
    /*
    @objc func animationStop(){
        EditingSubCard.last?.removeFromSuperview()
    }
    */
    
    @IBAction func save(_ sender: Any) {
        if self.type == CardEditor.type.add{
            var childs:[Card] = [Card]()
            if subCards.count >= 1{
                for card in self.subCards
                {
                    childs.append(card.card)
                    if card.isKind(of: CardView.PicView.self){
                        let manager = FileManager.default
                        var url = Constant.Configuration.url.PicCard
                        url.appendPathComponent(card.card.getId() + ".jpg")
                        let picView = card as! CardView.PicView
                        if picView.commentView.text != nil{
                        card.card.setDescription(picView.commentView.text!)
                        }
                        if manager.fileExists(atPath: (url.path)){
                            User.uploadPhotoUsingQCloud(url: url)
                        }
                    }else if card.isKind(of: CardView.ExaView.self){
                        /**deprecated in 6.13
                        (card.card as! ExampleCard).setExample((card as! CardView.ExaView).textView.attributedText.string)
                        print((card as! CardView.ExaView).textView.attributedText.string)
                        */
                        
                        /**updated in 6.13
                        */
                        let view = card as! CardView.ExaView
                        view.card.setTitle(view.title.text!)
                        view.card.setDefinition(view.textView.text)
                       
                    }else if card.isKind(of: CardView.TextView.self){
                        /**deprecated in 6.13
                        (card.card as! TextCard).setText((card as! CardView.TextView).textView.attributedText.string)
                        */
                        
                        /**updated in 6.13
                         */
                        let view = card as! CardView.TextView
                        let data = try? view.textView.attributedText.data(from: NSMakeRange(0, view.textView.attributedText.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf])
                        var url = Constant.Configuration.url.attributedText
                        url.appendPathComponent(view.card.getId() + ".rtf")
                        do{
                            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                            try data?.write(to: url)
                        }catch let error{
                            print(error.localizedDescription)
                        }
                        User.uploadAttrUsingQCloud(url:url)
 
                    }else if card.isKind(of: CardView.VoiceCardView.self){
                        let voiceCard = card as! CardView.VoiceCardView
                        voiceCard.card.setTitle((voiceCard.title.text)!)
                        let manager = FileManager.default
                        var url = Constant.Configuration.url.Audio
                        url.appendPathComponent(card.card.getId() + ".wav")
                        if manager.fileExists(atPath: (url.path)){
                            User.uploadAudioUsingQCloud(url: url)
                        }
                    }else if card.isKind(of: CardView.MapCardView.self){
                        let manager = FileManager.default
                        var url = Constant.Configuration.url.Map
                        url.appendPathComponent(card.card.getId() + ".jpg")
                        if manager.fileExists(atPath: (url.path)){
                            User.uploadPhotoUsingQCloud(url: url)
                        }
                        
                    }else if card.isKind(of: CardView.MovieView.self){
                        let manager = FileManager.default
                        var url = Constant.Configuration.url.Movie
                        url.appendPathComponent(card.card.getId() + ".mov")
                            if manager.fileExists(atPath:((card.card as! MovieCard).path)){
                                User.uploadMovieUsingQCloud(url: url)
                            }
                    }else if card.isKind(of: CardView.SubCardView.self){
                        let sub = card.card
                        let view = card as! CardView.SubCardView
                        sub?.setTitle(view.title.text!)
                        sub?.setDefinition(view.content.text!)
                }
                }
            }
            
            let interval = NSTimeIntervalSince1970
            //let date = NSDate(timeIntervalSince1970: interval)
            //let timeFormatter = DateFormatter()
           // timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //let strNowTime = timeFormatter.string(from: date as Date) as String
            let card = Card(title: cardTitle.text, tag: tagInputView?.tags, description:"", id: UUID().uuidString, definition: definition.text, color: color, cardType:Card.CardType.card.rawValue,modifytime:String(interval))
            card.addChildNotes(childs)
            self.card = card
             if !isSubCard{
                Cloud.addCard(card: card) { (bool) in
                    if bool{
                        DispatchQueue.main.async {
                        AlertView.show(success: "Adding Card Succeed")
                        }
                    }else{
                        DispatchQueue.main.async {
                        AlertView.show(error: "Adding Card to iCoud Failed")
                        }
                    }
                }
            /*deprecated
            User.addCard(email: loggedemail, card: card, completionHandler: { (json:JSON?) in
                if json != nil{
                    if json!["ifSuccess"].boolValue{
                        print("Add Card SuccessFul")
                    }
                }
            })
              */
        let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent("card.txt")
            if let dateRead = try? Data.init(contentsOf: url!){
                var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                if cardList == nil{
                    cardList = [Card]()
                }
                cardList?.append(card)
                let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList as Any)
                do{
                    try datawrite.write(to: url!)
                }catch{
                    print("fail to add")
                }
            }
            }
          
            
        }else if self.type == CardEditor.type.save{
            let manager = FileManager.default
           // var subCards:[Card] = [Card]()
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent("card.txt")
            if let dateRead = try? Data.init(contentsOf: url!){
                var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                if cardList == nil{
                    cardList = [Card]()
                }
                if card != nil{
                    self.card?.setTitle(cardTitle.text)
                    self.card?.setColor(color)
                    self.card?.setDefinition(definition.attributedText.string)
                    //self.card?.setDescription(descriptions.attributedText.string)
                    self.card?.setTag(tagInputView!.tags)
                    var childs = [Card]()
                    for card in self.subCards
                    {
                        childs.append(card.card)
                        if card.isKind(of: CardView.PicView.self){
                            let manager = FileManager.default
                            let url = Constant.Configuration.url.PicCard
                            let picView = card as! CardView.PicView
                            if picView.commentView.text != nil{
                                card.card.setDescription(picView.commentView.text!)
                            }
                            if manager.fileExists(atPath: (url.path)){
                            
                             //User.uploadImageWithAF(email:loggedemail,image:image,cardID:card.card.getId())
                                User.uploadPhotoUsingQCloud(url: url)
                            }
                        }else if card.isKind(of: CardView.ExaView.self){
                             let exa = card.card
                             let exaView = card as! CardView.ExaView
                             exa?.setTitle(exaView.title.text!)
                             exa?.setDefinition(exaView.textView.text)
                        }else if card.isKind(of: CardView.TextView.self){
                            var url = Constant.Configuration.url.attributedText
                            url.appendPathComponent(card.card.getId() + ".rtf")
                            User.uploadAttrUsingQCloud(url:url)
                        }else if card.isKind(of: CardView.VoiceCardView.self){
                            let voiceCard = card as! CardView.VoiceCardView
                            voiceCard.card.setTitle((voiceCard.title.text)!)
                            let manager = FileManager.default
                            var url = Constant.Configuration.url.Audio
                            url.appendPathComponent(card.card.getId() + ".wav")
                            if manager.fileExists(atPath: (url.path)){
                        
                               // User.uploadAudioWithAF(email: loggedemail, filePath: (url?.path)!, cardID: card.card.getId())
                                User.uploadAudioUsingQCloud(url: url)
                            }
                        }else if card.isKind(of: CardView.MapCardView.self){
                            let manager = FileManager.default
                            var url = Constant.Configuration.url.Map
                            url.appendPathComponent(card.card.getId() + ".jpg")
                            if manager.fileExists(atPath: (url.path)){
                           
                               // User.uploadImageWithAF(email: loggedemail, image: image!, cardID: card.card.getId())
                                User.uploadPhotoUsingQCloud(url: url)
                            }
                        }else if card.isKind(of: CardView.MovieView.self){
                                var url = Constant.Configuration.url.Movie
                                url.appendPathComponent(card.card.getId() + ".mov")
                                if manager.fileExists(atPath:url.path){
                                    User.uploadMovieUsingQCloud(url: url)
                                }
                            
                        }else if card.isKind(of: CardView.SubCardView.self){
                             let sub = card.card
                             let view = card as! CardView.SubCardView
                            sub?.setTitle(view.title.text!)
                            sub?.setDefinition(view.content.text!)
                        }
                    }
                  
                    self.card?.setChilds(childs)
                    //update time
                    
                    let date = NSDate()
                    let interval = date.timeIntervalSince1970
                    self.card?.updateTime(String(interval))
                     if !isSubCard{
                        Cloud.updateCard(card:self.card!){ (bool) in
                            if bool{
                               print("update card Success")
                            }else{
                                DispatchQueue.main.async {
                                    AlertView.show(error: "Updating Failed")
                                }
                            }
                        }
                    User.updateCard(card: (self.card)!, email: loggedemail, completionHandler: { (json:JSON?) in
                        if json != nil{
                        if json!["ifSuccess"].boolValue {
                            print("update card Success")
                        }
                        }
                    })
                    
                    var index = 0
                    for card in cardList!{
                        if card.getId() != self.card?.getId(){
                            index += 1
                        }else{
                            break
                        }
                    }
                    
                        cardList![index] = card!
                        let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList as Any)
                    do{
                        try datawrite.write(to: url!)
                    }catch{
                        print("fail to add")
                    }
                    }
                }
           }
        }
        if isSubCard{
                if self.delegate != nil{
                    self.delegate?.saveSubCards!(card:self.card!)
                }
        }
        if delegate != nil{
            delegate?.cardEditor?(DidFinishSaveCard: self.card!)
        }
    }
    
    func saveSubCards(card: Card) {
     //   save(self.view)
        for subView in subCards{
            if subView.card.getId() == card.getId(){
                switch subView.card.getType(){
                case Card.CardType.card.rawValue:
                    let cardView = subView as! CardView.SubCardView
                    cardView.content.text = card.getDefinition()
                    cardView.title.text = card.getTitle()
                case Card.CardType.voice.rawValue:
                     let frame = subView.frame
                     let cardView = CardView.getSingleVoiceView(card: card as! VoiceCard)
                     cardView.frame = frame
                default:break
                }
            }
        }
        reLoad()
       // subCards.removeAll()
       // loadCard(card: self.card!)
    }
    
    
   
    
    @IBAction func addButton(_ sender: UIButton) {
        
        func createButtonWithLabel(title:String,frame:CGRect,icon:FAType)->UIView{
            let subCardLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 20))
            subCardLabel.textAlignment = .center
            subCardLabel.font = UIFont.systemFont(ofSize: 15)
            subCardLabel.textColor = .white
            subCardLabel.text = title
            subCardLabel.setFAText(prefixText: "", icon: icon, postfixText: "", size: 30)
            subCardLabel.textAlignment = .center
            let button = UIView(frame: frame)
            button.backgroundColor = .black
            button.layer.cornerRadius = 25
            button.addSubview(subCardLabel)
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: subCardLabel.frame.height, width: frame.width, height: 20))
            titleLabel.text = title
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.textAlignment = .center
            button.addSubview(titleLabel)
            return button
        }
        
        func createButtonWithLabel(title:String,frame:CGRect,image:UIImage)->UIView{
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.image = image
            imageView.center.x = frame.width/2
            
            let button = UIView(frame: frame)
            button.backgroundColor = .clear
            button.layer.cornerRadius = 25
            button.addSubview(imageView)
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.height, width: frame.width, height: 20))
            titleLabel.text = title
            titleLabel.textColor = UIColor.flatGray
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.textAlignment = .center
            button.addSubview(titleLabel)
            return button
        }
        
        if !addButtonStateisOpen{
        addButtonStateisOpen = true
            addSubCard = createButtonWithLabel(title: "SubCard", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),image:UIImage(named:"subCard")!)
        let subCardtapGesture = UITapGestureRecognizer()
        subCardtapGesture.numberOfTapsRequired = 1
        subCardtapGesture.numberOfTouchesRequired = 1
        subCardtapGesture.addTarget(self, action: #selector(addCard))
        addSubCard.addGestureRecognizer(subCardtapGesture)
        
       
            addExa = createButtonWithLabel(title: "Key-Value", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),image:UIImage(named:"keyValue")!)
        let exaTapGesture = UITapGestureRecognizer()
        exaTapGesture.numberOfTapsRequired = 1
        exaTapGesture.numberOfTouchesRequired = 1
        exaTapGesture.addTarget(self, action: #selector(addExample))
        addExa.addGestureRecognizer(exaTapGesture)
        
            
            addPicCard = createButtonWithLabel(title: "Photo", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),image:UIImage(named:"pic")!)
            let picGesture = UITapGestureRecognizer()
            picGesture.numberOfTapsRequired = 1
            picGesture.numberOfTouchesRequired = 1
            picGesture.addTarget(self, action: #selector(addPic))
            addPicCard.addGestureRecognizer(picGesture)
            
            
            addText = createButtonWithLabel(title: "Text", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),image:UIImage(named:"text")!)
        let addtextGesture = UITapGestureRecognizer()
            addtextGesture.numberOfTapsRequired = 1
            addtextGesture.numberOfTouchesRequired = 1
            addtextGesture.addTarget(self, action: #selector(addTextView))
            addText.addGestureRecognizer(addtextGesture)
            
            addVoiceView = createButtonWithLabel(title: "Voice", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),image:UIImage(named:"voice")!)
           let addVoiceGesture = UITapGestureRecognizer()
            addVoiceGesture.numberOfTapsRequired = 1
            addVoiceGesture.numberOfTouchesRequired = 1
            addVoiceGesture.addTarget(self, action: #selector(addVoice))
            addVoiceView.addGestureRecognizer(addVoiceGesture)
            
            addMapView = createButtonWithLabel(title: "Location", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),image:UIImage(named:"map")!)
            let addMapGesture = UITapGestureRecognizer()
            addMapGesture.numberOfTapsRequired = 1
            addMapGesture.numberOfTouchesRequired = 1
            addMapGesture.addTarget(self, action: #selector(addMap))
            addMapView.addGestureRecognizer(addMapGesture)
            
            addMovieView = createButtonWithLabel(title: "Video", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50), image:UIImage(named:"movie")!)
            let addVideoGesture = UITapGestureRecognizer()
            addVideoGesture.numberOfTapsRequired = 1
            addVideoGesture.numberOfTouchesRequired = 1
            addVideoGesture.addTarget(self, action: #selector(addVideo))
            addMovieView.addGestureRecognizer(addVideoGesture)
            
        addButtonList.append(addSubCard)
        addButtonList.append(addExa)
        addButtonList.append(addPicCard)
        addButtonList.append(addText)
        addButtonList.append(addVoiceView)
        addButtonList.append(addMapView)
        addButtonList.append(addMovieView)
        self.addButton.removeFromSuperview()
        toolBox = SpringView(frame: CGRect(x: addButton.frame.origin.x, y: addButton.frame.origin.y, width: 0, height: 0))
        toolBox.alpha = 1
        toolBox.backgroundColor = .white
        self.toolBox.clipsToBounds = true
        self.toolBox.layer.cornerRadius = 10
        self.view.addSubview(toolBox)
             var index = 0
            for addButton in self.addButtonList{
                let line = index/3
                let mode = index%3
                addButton.frame = CGRect(x: 25 + 60 * mode, y: 25 + 60 * line, width: 50, height: 50)
                self.toolBox.addSubview(addButton)
                index += 1
            }
            UIView.setAnimationCurve(.easeOut)
            UIView.animate(withDuration: 0.2, animations: {
                self.toolBox.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
                self.toolBox.center = self.view.center
               
            }) { (bool) in
                
            }
        }
    }
    
    
    
    @objc func turnOffToolBox(){
         if addButtonStateisOpen{
            addButtonStateisOpen = false
            for addButton in self.addButtonList{
                addButton.removeFromSuperview()
            }
            self.toolBox.animation = "fadeOut"
            self.toolBox.curve = "easeOut"
            self.toolBox.duration = 0.5
            self.toolBox.x = self.addButton.center.x - self.toolBox.center.x
            self.toolBox.y = self.addButton.center.y - self.toolBox.center.y
            self.toolBox.scaleX = 0.3
            self.toolBox.scaleY = 0.3
            self.toolBox.animate()
            self.toolBox.animateNext {
                 self.toolBox.center = self.addButton.center
                 self.addButtonList.removeAll()
                 self.toolBox.removeFromSuperview()
                 self.view.addSubview(self.addButton)
            }
            
            /*
            UIView.setAnimationCurve(.easeOut)
            UIView.animate(withDuration: 0.2, animations: {
                self.toolBox.center = self.addButton.center
            }, completion: { (ifcomplete) in
                self.addButtonList.removeAll()
                self.view.addSubview(self.addButton)
                self.toolBox.removeFromSuperview()
            })
 */
        }
    }
    
    
    
/** all cardView
 */
    
    func cardViewAddPanGesture(_ view:CardView){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(cardViewPanned))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    var theLastOrigin:CGPoint?
    @objc func cardViewPanned(gesture:UIPanGestureRecognizer){
        //get index
        
        let view = gesture.view as! CardView
       
        let id = view.card.getId()
        var index = 0
        for subCard in subCards{
            if subCard.card.getId() == id {
                break
            }
            index += 1
        }
        if gesture.state == .began{
            theLastOrigin = gesture.view?.frame.origin
        }else if gesture.state == .changed && view.isEditMode{
            gesture.view?.superview?.bringSubview(toFront: gesture.view!)
            gesture.view?.center.x += gesture.translation(in: self.scrollView).x
            gesture.view?.center.y += gesture.translation(in: self.scrollView).y
            gesture.setTranslation(CGPoint.zero, in: self.scrollView)
            /*
            addButton.setFAIcon(icon: FAType.FATrashO, forState: .normal)
            */
        }else if gesture.state == .ended{
            /*one way to delete card
            addButton.setFAIcon(icon: FAType.FAPlusCircle, forState: .normal)
            
            var frame = view.superview?.convert(view.frame, to: self.view)
            print(addButton.frame.origin.y)
            if (frame?.intersects(addButton.frame))!{
                view.removeFromSuperview()
                subCards.remove(at: index)
            }
            */
            
            var subCardIndex = 0
            for subCard in subCards{
                if (view.center.y) < subCard.center.y{
                 //   gesture.view?.center.y = subCard.center.y
                    print(view.center.y)
                    print(subCard.center.y)
                    if index < subCardIndex{
                    subCards.insert(view, at: subCardIndex)
                    subCards.remove(at: index)
                    }else if index > subCardIndex{
                        subCards.remove(at: index)
                        subCards.insert(view, at: subCardIndex)
                    }
                    break
                }
                subCardIndex += 1
            }
           
                reLoad()
            
        }
        
    }
    
/** picView
 
 */
    @objc func addPic(){
        let alertSheet = UIAlertController(title: "Select From", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromalbum = UIAlertAction(title: "Album", style: .default) { (action) in
            print("choose form album")
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addPic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .savedPhotosAlbum
            cameraPicker.mediaTypes = [kUTTypeImage as String]
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addPic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.mediaTypes = [kUTTypeImage as String]
             self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    
    
    @objc func updatePic(_ sender:UITapGestureRecognizer){
        selectedPictureView = (sender.view as! CardView.PicView)
        let alertSheet = UIAlertController(title: "Select From", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromalbum = UIAlertAction(title: "Album", style: .default) { (action) in
            print("choose form album")
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "updatePic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .savedPhotosAlbum
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "updatePic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //获得照片
        if picTureAction == "addPic"{
        print("get Photo")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let piccard = PicCard(image)
            var url = Constant.Configuration.url.PicCard
            url.appendPathComponent(piccard.getId() + ".jpg")
                let data = UIImageJPEGRepresentation(image, 0.5)
            try? data?.write(to: url)
        let picView = CardView.getSinglePicView(pic: piccard)
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.addTarget(self, action: #selector(updatePic))
        picView.addGestureRecognizer(tapGesture)
        cardViewAddPanGesture(picView)
            picView.delegate = self
            picView.commentView.delegate = self
            if subCards.count > 0{
                picView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
        
            }else{
        picView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            }
        subCards.append(picView)
        scrollView.addSubview(picView)
          scrollView.contentSize.height = picView.frame.origin.y + picView.frame.height + 20
          //  cardBackGround.frame.size.height = picView.frame.origin.y + picView.frame.height + 20
        }else if picTureAction == "updatePic"{
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if selectedPictureView != nil{
                selectedPictureView?.image.image = image
                (selectedPictureView?.card as! PicCard).pic = image
                var url = Constant.Configuration.url.PicCard
                url.appendPathComponent((selectedPictureView?.card as! PicCard).getId() + ".jpg")
                let data = UIImageJPEGRepresentation(((selectedPictureView)?.image.image)!,0.5)
                try? data?.write(to: url)
            }
        }else if picTureAction == "addVideo"{
            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            print("videoURl:\(videoURL)")
            let id = UUID().uuidString
            try? FileManager.default.createDirectory(at:Constant.Configuration.url.Movie, withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.copyItem(at: videoURL, to: URL(fileURLWithPath: Constant.Configuration.url.Movie.appendingPathComponent(id + ".mov").path))
            let movieCard = MovieCard(id: id)
           // movieCard.path = videoURL.path
            let movieView = CardView.getSingleMovieView(card: movieCard)
            cardViewAddPanGesture(movieView)
            movieView.delegate = self
            if subCards.count > 0{
                movieView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
                
            }else{
                movieView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            }
            subCards.append(movieView)
            scrollView.addSubview(movieView)
            scrollView.contentSize.height = movieView.frame.origin.y + movieView.frame.height + 20
           // cardBackGround.frame.size.height = movieView.frame.origin.y + movieView.frame.height + 20
            
        }
         self.dismiss(animated: true, completion: nil)
    }
    
   
    
    @objc func addCard(){
        let date = NSDate()
        let interval = date.timeIntervalSince1970
        let card = Card(title: "title", tag: nil, description: "", id: UUID().uuidString, definition: "definition", color: color, cardType: Card.CardType.card.rawValue, modifytime:String(interval))
        let cardView = CardView.getSubCardView(card)
        cardView.delegate = self
        cardViewAddPanGesture(cardView)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(performCardEditor))
        cardView.addGestureRecognizer(tapGesture)
        if subCards.count < 1{
        cardView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
        }else if subCards.count >= 1{
        cardView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
        }
        cumulatedheight += Int(20 + cardView.frame.size.height)
        scrollView.addSubview(cardView)
        scrollView.contentSize.height = cardView.frame.origin.y + cardView.frame.height
        + 20
        //cardBackGround.frame.size.height = cardView.frame.origin.y + cardView.frame.height + 20
        subCards.append(cardView)
    }
    
    @objc func performCardEditor(_ sender:UITapGestureRecognizer){
    
        let card = (sender.view as! CardView).card
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "cardEditor") as! CardEditor
        vc.card = card
        vc.isSubCard = true
        vc.delegate = self
        vc.type = CardEditor.type.save
        self.present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination:CardEditor = segue.destination as! CardEditor
        destination.loadCard(card: sender as! Card)
    }
    
    @objc func addExample(){
        let exampleCard = ExampleCard()
        let exaView = CardView.singleExampleView(card:exampleCard)
        cardViewAddPanGesture(exaView)
         exaView.textView.delegate = self
         exaView.delegate = self
        if subCards.count < 1{
            exaView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            self.scrollView.addSubview(exaView)
        }else if subCards.count >= 1{
            exaView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.scrollView.addSubview(exaView)
        }
        subCards.append(exaView)
      //  cardBackGround.frame.size.height = exaView.frame.origin.y + exaView.frame.height + 20
        scrollView.contentSize.height = exaView.frame.origin.y + exaView.frame.height + 20
    }
    
    @objc func addTextView(){
        let textCard = TextCard()
        let textView = CardView.getSingleTextView(card:textCard)
        cardViewAddPanGesture(textView)
        textView.textView.delegate = self
        textView.delegate = self

        if subCards.count < 1{
            textView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            self.scrollView.addSubview(textView)
        }else if subCards.count >= 1{
            textView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.scrollView.addSubview(textView)
        }
        subCards.append(textView)
     //   cardBackGround.frame.size.height = textView.frame.origin.y + textView.frame.height + 20
        scrollView.contentSize.height = textView.frame.origin.y + textView.frame.height + 20
    }
    
    @objc func autoAddTextViewAtBottom(gesture:UITapGestureRecognizer){
           let location = gesture.location(in: scrollView)
    print("x:\(location.x),y:\(location.y)")
     //   print("last height:\((subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)!)")
        if subCards.count > 0 && location.y > (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! && !(subCards.last?.isKind(of: CardView.TextView.self))! && !addButtonStateisOpen{
            let textCard = TextCard(id: UUID().uuidString)
            let view = CardView.getSingleTextView(card: textCard)
            cardViewAddPanGesture(view)
            view.delegate = self
            view.textView.delegate = self
            view.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            subCards.append(view)
            self.scrollView.addSubview(view)
            //cardBackGround.frame.size.height = view.frame.origin.y + view.frame.height
            scrollView.contentSize.height = view.frame.origin.y + view.frame.height
            view.textView.becomeFirstResponder()
        }else if subCards.count == 0 && location.y > definition.frame.origin.y + definition.frame.height && !addButtonStateisOpen{
            let textCard = TextCard(id: UUID().uuidString)
            let view = CardView.getSingleTextView(card: textCard)
            cardViewAddPanGesture(view)
            view.delegate = self
            view.textView.delegate = self
            view.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            subCards.append(view)
            self.scrollView.addSubview(view)
          //  cardBackGround.frame.size.height = view.frame.origin.y + view.frame.height
            scrollView.contentSize.height = view.frame.origin.y + view.frame.height
            view.textView.becomeFirstResponder()
        }else if subCards.count > 0 && (subCards.last?.isKind(of: CardView.TextView.self))!{
             let textView = subCards.last as! CardView.TextView
            textView.textView.becomeFirstResponder()
        }
        
    }
    
    @objc func addVideo(){
        let alertSheet = UIAlertController(title: "Select From", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromalbum = UIAlertAction(title: "Album", style: .default) { (action) in
            print("choose form album")
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addVideo"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .savedPhotosAlbum
            cameraPicker.mediaTypes = [kUTTypeMovie as String]
           
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addVideo"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.mediaTypes = [kUTTypeMovie as String]
            self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    @objc func addVoice(){
        let voiceCard = VoiceCard(id: UUID().uuidString,title:"record")
        let voiceView = CardView.getSingleVoiceView(card: voiceCard)
        voiceView.hero.id = voiceCard.getId()
        voiceView.delegate = self
        cardViewAddPanGesture(voiceView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(voiceCardTapped))
        voiceView.addGestureRecognizer(tapGesture)
        if subCards.count < 1{
            voiceView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            self.scrollView.addSubview(voiceView)
        }else if subCards.count >= 1{
            voiceView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.scrollView.addSubview(voiceView)
        }
        subCards.append(voiceView)
       // cardBackGround.frame.size.height = voiceView.frame.origin.y + voiceView.frame.height + 20
        scrollView.contentSize.height = voiceView.frame.origin.y + voiceView.frame.height + 20
    }
    
    @objc func voiceCardTapped(gesture:UITapGestureRecognizer){
       let vc = VoiceRecognitionController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.loadVoiceCardView(voiceCard: (gesture.view as! CardView.VoiceCardView).card as! VoiceCard)
        vc.hero.isEnabled = true
        vc.superCard.hero.id = (gesture.view as! CardView.VoiceCardView).card.getId()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func addMap(){
        let picker = UIMapPickerWithBaiduMap()
        picker.delegate = self
        mapAction = "add"
        picker.action = UIMapPickerWithBaiduMap.Action.add
        self.present(picker, animated: false, completion: nil)
    }
    
    @objc func updateMap(_ sender:UITapGestureRecognizer){
        let mapView = sender.view as! CardView.MapCardView
        let picker = UIMapPickerWithBaiduMap()
         picker.action = UIMapPickerWithBaiduMap.Action.update
        picker.latitude = CLLocationDegrees((mapView.card as! MapCard).latitude!)
        picker.longitude = CLLocationDegrees((mapView.card as! MapCard).longitude!)
        // picker.name = (mapView.card as! MapCard).neibourAddress
         picker.delegate = self
         mapAction = "update"
         selectedMapView = mapView
        self.present(picker,animated:false,completion: nil)
        
    }
    
    func UIMapDidSelected(image: UIImage, place: Placemark?) {
        if mapAction == "add"{
            let id = UUID().uuidString
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            let manager = FileManager.default
            var url = Constant.Configuration.url.Map
            try? manager.createDirectory(atPath: (url.path), withIntermediateDirectories: true, attributes: nil)
            url.appendPathComponent(id + ".jpg")
            do{
                try? imageData?.write(to: url)
            }catch let err{
                print(err.localizedDescription)
            }
            let mapCard = MapCard(id:id,placeMark:place!)
            let mapview = CardView.getSingleMapView(card: mapCard)
            cardViewAddPanGesture(mapview)
            mapview.delegate = self
            if subCards.count < 1{
                mapview.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
                self.scrollView.addSubview(mapview)
            }else if subCards.count >= 1{
                mapview.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
                self.scrollView.addSubview(mapview)
            }
            let tapgesture = UITapGestureRecognizer(target: self, action: #selector(updateMap))
            tapgesture.numberOfTapsRequired = 1
            tapgesture.numberOfTouchesRequired = 1
            mapview.addGestureRecognizer(tapgesture)
            subCards.append(mapview)
          //  cardBackGround.frame.size.height = mapview.frame.origin.y + mapview.frame.height + 20
            scrollView.contentSize.height = mapview.frame.origin.y + mapview.frame.height + 20
        }else if mapAction == "update"{
            selectedMapView?.image.image = image
            let mapCard = (selectedMapView?.card as! MapCard)
            mapCard.formalAddress = place?.address == nil ? "" : (place?.address)!
            mapCard.neibourAddress = (place?.name)!
            mapCard.latitude = CGFloat((place?.location?.coordinate.latitude)!)
            mapCard.longitude = CGFloat((place?.location?.coordinate.longitude)!)
            let manager = FileManager.default
            var url = Constant.Configuration.url.Map
            try? manager.createDirectory(atPath: (url.path), withIntermediateDirectories: true, attributes: nil)
            url.appendPathComponent(mapCard.getId() + ".jpg")
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            do{
                try imageData?.write(to: url)
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
    }
    
    func UIMapDidSelected(image: UIImage, name: String, address: String, coordinate: CLLocationCoordinate2D) {
        if mapAction == "add"{
            let id = UUID().uuidString
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            var url = Constant.Configuration.url.Map
            url.appendPathComponent(id + ".jpg")
            do{
                try imageData?.write(to: url)
            }catch let err{
                print(err.localizedDescription)
            }
            let mapCard = MapCard(id: id, formalAddress: address, neighbourAddress: name, longitude: CGFloat(coordinate.longitude), latitude: CGFloat(coordinate.latitude))
            let mapview = CardView.getSingleMapView(card: mapCard)
            mapview.delegate = self
            if subCards.count < 1{
                mapview.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
                self.scrollView.addSubview(mapview)
            }else if subCards.count >= 1{
                mapview.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
                self.scrollView.addSubview(mapview)
            }
            let tapgesture = UITapGestureRecognizer(target: self, action: #selector(updateMap))
            tapgesture.numberOfTapsRequired = 1
            tapgesture.numberOfTouchesRequired = 1
            mapview.addGestureRecognizer(tapgesture)
            subCards.append(mapview)
          //  cardBackGround.frame.size.height = mapview.frame.origin.y + mapview.frame.height + 20
            scrollView.contentSize.height = mapview.frame.origin.y + mapview.frame.height + 20
        }else if mapAction == "update"{
            selectedMapView?.image.image = image
            selectedMapView?.neighbourAddrees.text = name
            selectedMapView?.formalAddress.text = address
            let mapCard = (selectedMapView?.card as! MapCard)
            mapCard.formalAddress = address
            mapCard.neibourAddress = name
            mapCard.latitude = CGFloat(coordinate.latitude)
            mapCard.longitude = CGFloat(coordinate.longitude)
            let manager = FileManager.default
             var url = Constant.Configuration.url.Map
            url.appendPathComponent(mapCard.getId() + ".jpg")
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            do{
                try imageData?.write(to: url)
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
    }
    
    func UIMapDidSelected(image:UIImage,poi:AMapPOI?,formalAddress:String) {
        if mapAction == "add"{
        let id = UUID().uuidString
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let manager = FileManager.default
        var url = Constant.Configuration.url.Map
            url.appendPathComponent(id + ".jpg")
        do{
            try imageData?.write(to: url)
        }catch let err{
            print(err.localizedDescription)
        }
            let mapCard = MapCard(poi: poi, formalAddress: formalAddress, id: id)
        let mapview = CardView.getSingleMapView(card: mapCard)
            mapview.delegate = self
        if subCards.count < 1{
            mapview.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            self.scrollView.addSubview(mapview)
        }else if subCards.count >= 1{
            mapview.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.scrollView.addSubview(mapview)
        }
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(updateMap))
        tapgesture.numberOfTapsRequired = 1
        tapgesture.numberOfTouchesRequired = 1
        mapview.addGestureRecognizer(tapgesture)
        subCards.append(mapview)
        //cardBackGround.frame.size.height = mapview.frame.origin.y + mapview.frame.height + 20
        scrollView.contentSize.height = mapview.frame.origin.y + mapview.frame.height + 20
        }else if mapAction == "update"{
            selectedMapView?.image.image = image
            let mapCard = (selectedMapView?.card as! MapCard)
            mapCard.formalAddress = formalAddress
            if poi != nil{
                mapCard.neibourAddress = (poi?.name)!
            }else{
            mapCard.neibourAddress = formalAddress
            }
            mapCard.latitude = poi?.location.latitude
            mapCard.longitude = poi?.location.longitude
           
            var url = Constant.Configuration.url.Map
            url.appendPathComponent(mapCard.getId() + ".jpg")
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            do{
                try imageData?.write(to: url)
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
    }
    
    //gesture Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self){
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            if gesture.velocity(in: gesture.view).y < 500{
               return true
            }else{
               return false
            }
        }else{
             return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.view?.isKind(of: UIScrollView.self))! || (gestureRecognizer.view?.isKind(of: CardView.self))! {
            return false
        }else{
            return true
        }
    }
}

extension CardEditor:CardViewDelegate{
    func cardView(commentHide picView: CardView.PicView) {
        reLoad()
    }
    
    func cardView(commentShowed picView: CardView.PicView) {
        reLoad()
        picView.commentView.becomeFirstResponder()
    }
    
    func picView(extractText:CardView.PicView){
        let vc = OCRController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true){
            vc.loadPic(pic: extractText.image.image!)
        }
    }
    
    func cardView(translate view: CardView,text:String) {
        endEditing()
        let vc = TranslationController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true){
           vc.originalText.text = text
            if text.count > 0{
                vc.translateButton.isHidden = false
            }
        }
    }
}

extension CardEditor:TagInputViewDelegate{
    func tagDidFinishAdding(tag: String) {
        reLoad()
    }
}

extension CardEditor:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0{
            scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x,y:0), animated: false)
        }
    }
}

extension CardEditor:PaletteProtocal{
    func palette(didSelectColor: UIColor) {
        self.color = didSelectColor
        self.setColor(color: didSelectColor)
    }
}



