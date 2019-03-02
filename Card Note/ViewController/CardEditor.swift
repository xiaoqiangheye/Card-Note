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
import MobileCoreServices
import Spring


class CardEditor:UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,AttributedTextViewDelegate, UIPickerViewDelegate,UIPickerViewDataSource,CardEditorDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate{
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
    var colorButton:UIButton!
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
            if subCards.count > 0{
                if (subCards.last?.isKind(of:CardView.TextView.self))!{
                    subCards.last?.removeFromSuperview()
                    subCards.removeLast()
                }
            }
        }
       
        textView.backgroundColor = .clear
        attributedView?.removeFromSuperview()
        attributedView = nil
    }
    
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
    
    }
    

    var lastNumOfLines = 1
    var currentNumOfLines = 1
    var lastCharacter = ""
    var currentCharacter = ""
    func textViewDidChange(_ textView: UITextView) {
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
        
        let frame = textView.frame
        
        //定义一个constrainSize值用于计算textview的高度
        
        let constrainSize=CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        
        //获取textview的真实高度
        let size = textView.sizeThatFits(constrainSize)
        
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        if textView.superview != nil{
            if (textView.superview as? CardView.TextView) != nil{
                textView.frame.size.height = size.height
                textView.superview?.frame.size.height = size.height
               reLoad()
            }else if (textView.superview as? CardView.ExaView) != nil{
                textView.frame.size.height = size.height
                textView.superview?.frame.size.height = textView.frame.origin.y + textView.frame.height
                reLoad()
            }
            else if textView == definition{
                textView.frame.size.height = size.height
               reLoad()
            }
        }
        
      //Mode Caculation
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
    
    
    private func setColor(color:UIColor){
        var backGroundHeight:CGFloat = 100
        if UIDevice.current.isX(){
            backGroundHeight = 120
        }
        
        gl.removeFromSuperlayer()
        gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:backGroundHeight)
        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        gl.colors = [color.cgColor,getRightColorFromLeftGradient(left: color).cgColor]
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        cardColor.layer.addSublayer(gl)
        self.color = color
        cardColor.bringSubview(toFront: cardTitle)
        tagInputView.plusButton.setTitleColor(color, for: .normal)
    }
    
    var gl:CAGradientLayer!
    override func viewDidLoad() {
        self.hero.isEnabled = true
        if self.card != nil{
        self.view.hero.id = self.card?.getId()
        }
        self.view.backgroundColor = .clear
        var backGroundHeight:CGFloat = 100
        if UIDevice.current.isX(){
            backGroundHeight = 120
        }
        //backGround
        gl = CAGradientLayer.init()
        gl.frame = CGRect(x:0,y:0,width:self.view.frame.width,height:backGroundHeight)

        gl.startPoint = CGPoint(x:0, y:0);
        gl.endPoint = CGPoint(x:1, y:1);
        if card != nil{
            gl.colors = [(card?.getColor().cgColor)!,getRightColorFromLeftGradient(left: (card?.getColor())!).cgColor]
        }else{
            gl.colors = [Constant.Color.blueLeft.cgColor,Constant.Color.blueRight.cgColor]
        }
        gl.locations = [NSNumber(value:0),NSNumber(value:1)]
        gl.cornerRadius = 0
        
       
        cardColor = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: backGroundHeight))
        cardColor.layer.addSublayer(gl)
        
        let saveButton = UIButton(frame: CGRect(x: 0, y: 20, width: 100, height: 30))
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.white, for: .focused)
        saveButton.addTarget(self, action: #selector(willExitandSave), for: .touchDown)
        
        
        doneButton = UIButton()
        doneButton.setFAIcon(icon: FAType.FATimes,iconSize: 30,forState: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.frame = CGRect(x: self.view.frame.width - 50, y: 20, width: 30, height: 30)
        doneButton.addTarget(self, action: #selector(dismissView), for: .touchDown)
        
        
        modeButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 20, width: 30, height: 30))
       // modeButton.center.y = backGroundHeight/2
        modeButton.setBackgroundImage(UIImage(named: "edit"), for: .normal)
        modeButton.setTitleColor(.clear, for: .normal)
        modeButton.addTarget(self, action: #selector(modeChanged), for: .touchDown)
        modeButton.layer.cornerRadius = 15
        if self.type == .add{
            modeButton.isHidden = true
        }
        
        colorButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: 20, width: 30, height: 30))
        colorButton.setBackgroundImage(UIImage(named: "palette"), for: .normal)
        colorButton.setTitleColor(.clear, for: .normal)
        colorButton.backgroundColor = .white
        colorButton.layer.cornerRadius = 15
        colorButton.isHidden = true
        colorButton.addTarget(self, action: #selector(showPalette), for: .touchDown)
        //self.view.addSubview(colorButton)
        
        //addButton
        addButton.setBackgroundImage(UIImage(named: "plusButton"), for: .normal)
        addButton.setTitleColor(.clear, for: .normal)
        addButton.frame.origin = CGPoint(x: self.view.frame.width - 50, y: self.view.frame.height - 200)
        addButton.frame.size = CGSize(width: 50, height: 50)
        
        
        cardTitle = UITextView()
        cardTitle.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: 40)
        cardTitle.textColor = .white
        cardTitle.backgroundColor = .clear
        cardTitle.center.x = self.view.bounds.width/2
        cardTitle.center.y = cardColor.frame.height - 40
        cardTitle.layer.cornerRadius = 10
        cardTitle.textAlignment = .center
        cardTitle.font = UIFont.boldSystemFont(ofSize: 20)
        cardTitle.isScrollEnabled = false
        cardColor.addSubview(cardTitle)
        if(card == nil){
            cardTitle.text = "Title"
        }else{
            cardTitle.isSelectable = false
            cardTitle.isEditable = false
        }
        
        
        tagInputView = TagInputView(frame: CGRect(x: 0, y: backGroundHeight - 15, width: self.view.bounds.width*0.9, height: 50), tags:[String]())
        tagInputView.delegate = self
        tagInputView.center.x = self.view.frame.width/2
        tagInputView.plusButton.setTitleColor(card?.getColor() == nil ? Constant.Color.blueLeft:card?.getColor(), for: .normal)
        if card != nil{
            tagInputView.loadTag(tags: (card?.getTag())!)
            color = (card?.getColor())!
        }else{
            color = Constant.Color.blueLeft
        }
        definitionLabel = UILabel()
        definitionLabel.font =  UIFont.boldSystemFont(ofSize: 20)
        definitionLabel.text = "Definition"
        definitionLabel.frame = CGRect(x:20, y: tagInputView.frame.origin.y + tagInputView.frame.height + 20, width: self.view.bounds.width, height: 20)
        definitionLabel.textColor = UIColor(red: 132/255, green: 141/255, blue: 163/255, alpha: 1)
        
        definition = UITextView()
        definition.frame = CGRect(x: 20, y: definitionLabel.frame.origin.y + definitionLabel.frame.height + 20, width: self.view.bounds.width - 40, height: 100)
        definition.font = UIFont.systemFont(ofSize: 18)
        definition.textColor = UIColor(red: 132/255, green: 141/255, blue: 163/255, alpha: 1)
        definition.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.8)
       // definition.center.x = self.view.bounds.width/2
        definition.layer.cornerRadius = 10
        definition.isScrollEnabled = false
       // definition.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
        if self.card != nil{
            definition.text = card?.getDefinition()
            let constrainSize = CGSize(width:definition.frame.size.width,height:CGFloat(MAXFLOAT))
            definition.sizeThatFits(constrainSize)
        }else{
            definition.text = "What does this card record?"
        }
    

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
        scrollView.addSubview(saveButton)
        if self.type == .add{
        scrollView.addSubview(doneButton)
        }
       // scrollView.addSubview(cardTitle)
        scrollView.addSubview(definition)
        //cardBackGround.addSubview(descriptions)
        scrollView.addSubview(definitionLabel)
        scrollView.addSubview(tagInputView)
        scrollView.addSubview(modeButton)
        scrollView.addSubview(colorButton)
        
        let endEditingGesture = UITapGestureRecognizer()
       endEditingGesture.addTarget(self, action: #selector(endEditing))
       endEditingGesture.addTarget(self, action: #selector(autoAddTextViewAtBottom))
       endEditingGesture.addTarget(self, action: #selector(turnOffToolBox))
        scrollView.addGestureRecognizer(endEditingGesture)
        
        if card != nil{
            loadCard(card: card!)
        }
        
       self.view.addSubview(scrollView)
        

      self.view.bringSubview(toFront: addButton)
        
    let centerDefault = NotificationCenter.default
        centerDefault.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        centerDefault.addObserver(self, selector: #selector(keyboardWillExit), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        //addButtonSetting
        addButtonSetting()
        
    }
    
    
    @objc private func modeChanged(){
        if isEditMode{
            isEditMode = false
            cardTitle.isEditable = false
            cardTitle.isSelectable = false
            modeButton.setBackgroundImage(UIImage(named:"edit"), for: .normal)
            modeButton.setTitle("", for: .normal)
            modeButton.backgroundColor = .clear
            UIView.animate(withDuration: 0.2) {
                self.colorButton.center = self.modeButton.center
                self.colorButton.isHidden = true
            }
            
            for subCard in subCards{
                subCard.observeMode()
            }
        }else{
            isEditMode = true
            cardTitle.isEditable = true
            cardTitle.isSelectable = true
            modeButton.setBackgroundImage(nil, for: .normal)
            modeButton.setFAIcon(icon: FAType.FACheckCircle, iconSize: 30,forState: .normal)
            modeButton.setTitleColor(.white, for: .normal)
            modeButton.backgroundColor = .clear
            UIView.animate(withDuration: 0.2) {
                self.colorButton.center.y = self.cardColor.frame.origin.y + self.cardColor.frame.height
                self.colorButton.isHidden = false
            }
            for subCard in subCards{
                subCard.editMode()
            }
        }
    }
 
    
    @objc private func viewSwiped(gesture:UISwipeGestureRecognizer){
        if gesture.state == .ended && gesture.direction == .down{
          self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc private func willExitandSave(){
        self.dismiss(animated: true) {
            self.save(UIView())
        }
    }
    
    var isSaved = false
    @objc private func viewPaned(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed{
            self.view.center.x += gesture.translation(in: gesture.view).x
            self.view.center.y += gesture.translation(in: gesture.view).y
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: gesture.view)
            if gesture.velocity(in: gesture.view).y > 100 && isSaved == false{
                isSaved = true
                self.dismiss(animated: true) {
                    self.save(UIView())
                }
            }
        }else if gesture.state == .cancelled || gesture.state == .ended{
            UIView.animate(withDuration: 0.3) {
                 self.view.frame.origin = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    
    //color picker
    @objc private func getPickerViewValue(sender:UIButton){
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
    
    
    @objc private func keyboardWillExit(aNotification:NSNotification){
        print("keyboard will hide")
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.frame.origin.y = 0
        }, completion: nil)
    }
    
    
    
    @objc private func keyboardWillShow(aNotification: NSNotification){
        if addButtonStateisOpen{turnOffToolBox()}
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
        
        if selectedView != nil && selectedView?.superview != nil{
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
        for sub in subCards{
            if sub.isKind(of: CardView.TextView.self){
                let sub = sub as! CardView.TextView
                sub.textView.resignFirstResponder()
                
            }
        }
    }
    
    @objc private func showPalette(){
        if !ifPaletteShowed{
        //let location = sender.location(in: cardBackGround)
        let location = colorButton.center
        let palette = Palette(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            palette.center = location
        palette.delegate = self
        palette.center = location
        var colors:[UIColor] = [UIColor]()
        colors.append(Constant.Color.redLeft)
        colors.append(Constant.Color.blueLeft)
        colors.append(Constant.Color.greenLeft)
        palette.addColors(colors)
        palette.parentView = cardColor
        palette.viewController = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showPalette))
        palette.addGestureRecognizer(gesture)
        self.view.addSubview(palette)
        self.view.bringSubview(toFront: palette)
        ifPaletteShowed = true
        }else{
            for subView in self.view.subviews{
                if subView.isKind(of: Palette.self){
                subView.removeFromSuperview()
                ifPaletteShowed = false
                }
            }
        }
    }
    
    //cardView LongTap
    @objc private func longTap(_ sender:UILongPressGestureRecognizer){
      
    }
    
    
    internal func deleteButtonClicked(view:CardView) {
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
        definition.text = card.getText() == nil ? "" : card.getText()?.string
        color = card.getColor()
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
                let frame = view.textView.frame
                
                //定义一个constrainSize值用于计算textview的高度
                
                let constrainSize=CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
                
                //获取textview的真实高度
                let size = view.textView.sizeThatFits(constrainSize)
                view.textView.frame.size = size
                
                nxtView.removeFromSuperview()
                let data = try? view.textView.attributedText.data(from: NSMakeRange(0, view.textView.attributedText.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtf])
                var url = Constant.Configuration.url.attributedText
                url.appendPathComponent(view.card.getId() + ".rtf")
                do{
                    try data?.write(to: url)
                }catch let error{
                    print(error.localizedDescription)
                }
                subCards.remove(at: index + 1)
            }
            UIView.animate(withDuration: 0.5) {
            card.frame.origin.y = cumulatedHeight
            card.center.x = self.view.frame.width/2
            }
            cumulatedHeight += card.frame.height + 20
            self.scrollView.contentSize.height = card.frame.origin.y + card.frame.height + 20
            index += 1
        }
        self.scrollView.contentSize.height += 50
        scrollView.contentOffset.y = contentoffSetY
    }
    
    @IBAction func save(_ sender: Any) {
        let manager = FileManager.default
        if self.type == CardEditor.type.add{
            var childs:[Card] = [Card]()
            if subCards.count >= 1{
                for card in self.subCards
                {
                    childs.append(card.card)
                    if card.isKind(of: CardView.PicView.self){
                        
                        var url = Constant.Configuration.url.PicCard
                        url.appendPathComponent(card.card.getId() + ".jpg")
                        let picView = card as! CardView.PicView
                        if picView.commentView.text != nil{
                        card.card.setDescription(picView.commentView.text!)
                        }
                        if isPremium() && manager.fileExists(atPath: (url.path)){
                            //User.uploadPhotoUsingQCloud(url: url)
                            Cloud.upload(image: url, id: card.card.getId()){_,_ in
                                
                            }
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
                       if isPremium() && manager.fileExists(atPath: (url.path)){
                            Cloud.upload(text: url, id: card.card.getId()){_,_ in
                                
                            }
                        }
 
                    }else if card.isKind(of: CardView.VoiceCardView.self){
                        let voiceCard = card as! CardView.VoiceCardView
                        voiceCard.card.setTitle((voiceCard.title.text)!)
                        
                        var url = Constant.Configuration.url.Audio
                        url.appendPathComponent(card.card.getId() + ".wav")
                        if isPremium() && manager.fileExists(atPath: (url.path)){
                           // User.uploadAudioUsingQCloud(url: url)
                            Cloud.upload(audio: url, id: card.card.getId()){_,_ in
                                
                            }
                        }
                    }else if card.isKind(of: CardView.MapCardView.self){
                        
                        var url = Constant.Configuration.url.Map
                        url.appendPathComponent(card.card.getId() + ".jpg")
                        if isPremium() && manager.fileExists(atPath: (url.path)){
                            //User.uploadPhotoUsingQCloud(url: url)
                            Cloud.upload(image: url, id: card.card.getId()){_,_ in
                                
                            }
                        }
                        
                    }else if card.isKind(of: CardView.MovieView.self){
                       
                        var url = Constant.Configuration.url.Movie
                        url.appendPathComponent(card.card.getId() + ".mov")
                            if isPremium() && manager.fileExists(atPath:((card.card as! MovieCard).path)){
                               // User.uploadMovieUsingQCloud(url: url)
                                Cloud.upload(video: url, id: card.card.getId()){_,_ in
                                    
                                }
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
            let card = Card(title: cardTitle.text, tag: tagInputView?.tags.sorted(), description:"", id: UUID().uuidString, definition: "", color: color, cardType:Card.CardType.card.rawValue,modifytime:String(interval))
            let attr = NSAttributedString(string: definition.text)
            card.setText(attr: attr)
            
            var url = Constant.Configuration.url.attributedText
            url.appendPathComponent(card.getId() + "_DEFINITION.rtf")
            if isPremium(){
                Cloud.uploadDefinition(id: card.getId(), url: url) { (bool, error) in
                    if error != nil{
                        DispatchQueue.main.async {
                            AlertView.show(error: "Error Uploading Cards.")
                        }
                    }
                }
            }
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
                    self.card?.setText(attr: definition.attributedText)
                    self.card?.setTag(tagInputView!.tags.sorted())
                    var childs = [Card]()
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
                               // User.uploadPhotoUsingQCloud(url: url)
                                Cloud.upload(image: url, id: card.card.getId()){_,_ in
                                    
                                }
                            }
                        }else if card.isKind(of: CardView.ExaView.self){
                             let exa = card.card
                             let exaView = card as! CardView.ExaView
                             exa?.setTitle(exaView.title.text!)
                             exa?.setDefinition(exaView.textView.text)
                        }else if card.isKind(of: CardView.TextView.self){
                            var url = Constant.Configuration.url.attributedText
                            url.appendPathComponent(card.card.getId() + ".rtf")
                           // User.uploadAttrUsingQCloud(url:url)
                            let manager = FileManager.default
                            if manager.fileExists(atPath: (url.path)){
                                Cloud.upload(text: url, id: card.card.getId()){_,_ in}
                            }
                        }else if card.isKind(of: CardView.VoiceCardView.self){
                            let voiceCard = card as! CardView.VoiceCardView
                            voiceCard.card.setTitle((voiceCard.title.text)!)
                            let manager = FileManager.default
                            var url = Constant.Configuration.url.Audio
                            url.appendPathComponent(card.card.getId() + ".wav")
                            if manager.fileExists(atPath: (url.path)){
                               // User.uploadAudioUsingQCloud(url: url)
                                Cloud.upload(audio: url, id: card.card.getId()){_,_ in}
                            }
                        }else if card.isKind(of: CardView.MapCardView.self){
                            let manager = FileManager.default
                            var url = Constant.Configuration.url.Map
                            url.appendPathComponent(card.card.getId() + ".jpg")
                            if manager.fileExists(atPath: (url.path)){
                                //User.uploadPhotoUsingQCloud(url: url)
                                Cloud.upload(image: url, id: card.card.getId()){_,_ in}
                            }
                        }else if card.isKind(of: CardView.MovieView.self){
                                var url = Constant.Configuration.url.Movie
                                url.appendPathComponent(card.card.getId() + ".mov")
                                if manager.fileExists(atPath:url.path){
                                   // User.uploadMovieUsingQCloud(url: url)
                                    Cloud.upload(video: url, id: card.card.getId()){_,_ in}
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
                    
                    //update definition
                    var textUrl = Constant.Configuration.url.attributedText
                    textUrl.appendPathComponent(card!.getId() + "_DEFINITION.rtf")
                    Cloud.uploadDefinition(id: card!.getId(), url: textUrl) { (bool, error) in
                        if(error != nil){
                            DispatchQueue.main.async {
                                AlertView.show(error: "Error Uploading Cards.")
                            }
                        }
                    }
                    
                    //upload card to icloud
                     if !isSubCard{
                       
                        Cloud.updateCard(card:self.card!){ (bool) in
                            if bool{
                               print("update card Success")
                            }else{
                                DispatchQueue.main.async {
                                    AlertView.show(error: "Updating subcards Failed")
                                }
                            }
                        }
                        
                   
                    
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
        for subView in subCards{
            if subView.card.getId() == card.getId(){
                switch subView.card.getType(){
                case Card.CardType.card.rawValue:
                    let cardView = subView as! CardView.SubCardView
                    cardView.content.text = card.getText() == nil ? "" : card.getText()?.string
                    cardView.title.text = card.getTitle()
                case Card.CardType.voice.rawValue:
                    let cardView = subView as! CardView.VoiceCardView
                    cardView.reload()
                default:break
                }
            }
        }
        reLoad()
    }
    
    
    @IBAction private func addButton(_ sender: UIButton) {
        if !addButtonStateisOpen{
            addButtonStateisOpen = true
            addButton.removeFromSuperview()
            self.view.addSubview(toolBox)
            self.view.bringSubview(toFront: toolBox)
            self.toolBox.center = self.view.center
            self.toolBox.animation = "fadeIn"
            self.toolBox.curve = "easeOut"
            self.toolBox.duration = 0.5
            self.toolBox.x = (self.addButton.center.x - self.toolBox.center.x)
            self.toolBox.y = (self.addButton.center.y - self.toolBox.center.y)
            self.toolBox.animate()
        }
    }
    
    
    private func addButtonSetting(){
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
        
            addSubCard = createButtonWithLabel(title: "SubCard", frame: CGRect(x: 0, y: 0, width: 50, height: 50),image:UIImage(named:"subCard")!)
            let subCardtapGesture = UITapGestureRecognizer()
            subCardtapGesture.numberOfTapsRequired = 1
            subCardtapGesture.numberOfTouchesRequired = 1
            subCardtapGesture.addTarget(self, action: #selector(addCard))
            addSubCard.addGestureRecognizer(subCardtapGesture)
            
            
            addExa = createButtonWithLabel(title: "Key-Value", frame: CGRect(x: 0, y: 0, width: 50, height: 50),image:UIImage(named:"keyValue")!)
            let exaTapGesture = UITapGestureRecognizer()
            exaTapGesture.numberOfTapsRequired = 1
            exaTapGesture.numberOfTouchesRequired = 1
            exaTapGesture.addTarget(self, action: #selector(addExample))
            addExa.addGestureRecognizer(exaTapGesture)
            
            
            addPicCard = createButtonWithLabel(title: "Photo", frame: CGRect(x: 0, y: 0, width: 50, height: 50),image:UIImage(named:"pic")!)
            let picGesture = UITapGestureRecognizer()
            picGesture.numberOfTapsRequired = 1
            picGesture.numberOfTouchesRequired = 1
            picGesture.addTarget(self, action: #selector(addPic))
            addPicCard.addGestureRecognizer(picGesture)
            
            
            addText = createButtonWithLabel(title: "Text", frame: CGRect(x: 0, y: 0, width: 50, height: 50),image:UIImage(named:"text")!)
            let addtextGesture = UITapGestureRecognizer()
            addtextGesture.numberOfTapsRequired = 1
            addtextGesture.numberOfTouchesRequired = 1
            addtextGesture.addTarget(self, action: #selector(addTextView))
            addText.addGestureRecognizer(addtextGesture)
            
            addVoiceView = createButtonWithLabel(title: "Voice", frame: CGRect(x: 0, y: 0, width: 50, height: 50),image:UIImage(named:"voice")!)
            let addVoiceGesture = UITapGestureRecognizer()
            addVoiceGesture.numberOfTapsRequired = 1
            addVoiceGesture.numberOfTouchesRequired = 1
            addVoiceGesture.addTarget(self, action: #selector(addVoice))
            addVoiceView.addGestureRecognizer(addVoiceGesture)
            
        
            
            addMovieView = createButtonWithLabel(title: "Video", frame: CGRect(x: 0, y: 0, width: 50, height: 50), image:UIImage(named:"movie")!)
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
            addButtonList.append(addMovieView)
        
            toolBox = SpringView(frame: CGRect(x: addButton.frame.origin.x, y: addButton.frame.origin.y, width: 0, height: 0))
            self.toolBox.frame = CGRect(x: 0, y: 0, width: 220, height: 160)
            toolBox.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 253/255, alpha: 1)
            self.toolBox.clipsToBounds = true
            self.toolBox.layer.cornerRadius = 10
            var index = 0
            for addButton in self.addButtonList{
                let line = index/3
                let mode = index%3
                addButton.frame = CGRect(x: 25 + 60 * mode, y: 25 + 60 * line, width: 50, height: 50)
                self.toolBox.addSubview(addButton)
                index += 1
            }
    }
    
    
    
    @objc func turnOffToolBox(){
         if addButtonStateisOpen{
            addButtonStateisOpen = false
            self.toolBox.animation = "fadeOut"
            self.toolBox.curve = "easeOut"
            self.toolBox.duration = 0.5
            self.toolBox.x = self.addButton.center.x - self.toolBox.center.x
            self.toolBox.y = self.addButton.center.y - self.toolBox.center.y
            self.toolBox.scaleX = 0.1
            self.toolBox.scaleY = 0.1
            self.toolBox.animate()
            self.toolBox.animateNext {
                 self.toolBox.center = self.addButton.center
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
    
    internal func cardViewAddPanGesture(_ view:CardView){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(cardViewPanned))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    var theLastOrigin:CGPoint?
    @objc internal func cardViewPanned(gesture:UIPanGestureRecognizer){
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
            var subCardIndex = 0
            for subCard in subCards{
                if (view.center.y) < subCard.center.y{
                    if index < subCardIndex{
                        subCards.insert(view, at: subCardIndex)
                        subCards.remove(at: index)
                    }else if index > subCardIndex{
                        subCards.remove(at: index)
                        subCards.insert(view, at: subCardIndex)
                    }
                    break
                }else if(view.center.y > (subCards.last?.center.y)!){
                    subCards.append(view)
                    subCards.remove(at: subCardIndex)
                }
                subCardIndex += 1
            }
           
                reLoad()
            
        }
        
    }
    
/** picView
 
 */
    @objc private func addPic(){
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
    
    
    
    @objc private func updatePic(_ sender:UITapGestureRecognizer){
        selectedPictureView = (sender.view as! CardView.PicView)
        let alertSheet = UIAlertController(title: "Select From", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromalbum = UIAlertAction(title: "Album", style: .default) { (action) in
            print("choose form album")
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "updatePic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .savedPhotosAlbum
            cameraPicker.allowsEditing = true
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "updatePic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    
    
   internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
                movieView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            }
            subCards.append(movieView)
            scrollView.addSubview(movieView)
            scrollView.contentSize.height = movieView.frame.origin.y + movieView.frame.height + 20
           // cardBackGround.frame.size.height = movieView.frame.origin.y + movieView.frame.height + 20
            
        }
         self.dismiss(animated: true, completion: nil)
    }
    
   
    
    @objc private func addCard(){
        let date = NSDate()
        let interval = date.timeIntervalSince1970
        let card = Card(title: "title", tag: nil, description: "", id: UUID().uuidString, definition: "definition", color: color, cardType: Card.CardType.card.rawValue, modifytime:String(interval))
        let cardView = CardView.getSubCardView(card)
        cardView.hero.id = cardView.card.getId()
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
    
    @objc private func performCardEditor(_ sender:UITapGestureRecognizer){
        let card = (sender.view as! CardView).card
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "cardEditor") as! CardEditor
        //vc.hero.isEnabled = true
        //vc.view.hero.id = card?.getId()
        vc.card = card
        vc.isSubCard = true
        vc.delegate = self
        vc.type = CardEditor.type.save
        self.present(vc, animated: true, completion: nil)
    }
    
    override internal func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination:CardEditor = segue.destination as! CardEditor
        destination.loadCard(card: sender as! Card)
    }
    
    @objc private func addExample(){
        let exampleCard = ExampleCard()
        let exaView = CardView.singleExampleView(card:exampleCard)
        cardViewAddPanGesture(exaView)
         exaView.textView.delegate = self
         exaView.title.delegate = self
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
    
    @objc private func addTextView(){
        if addButtonStateisOpen{turnOffToolBox()}
        let textCard = TextCard()
        let textView = CardView.getSingleTextView(card:textCard)
        cardViewAddPanGesture(textView)
        textView.textView.delegate = self
        textView.delegate = self
        if subCards.count < 1{
            textView.frame.origin.y = definition.frame.origin.y + definition.frame.height + 20
            scrollView.contentSize.height = textView.frame.origin.y + textView.frame.height + 20
            self.scrollView.addSubview(textView)
             subCards.append(textView)
        }else if subCards.count >= 1{
            if (subCards.last?.isKind(of: CardView.TextView.self))!{
                let text = subCards.last as! CardView.TextView
                selectedView = text.textView
                text.textView.becomeFirstResponder()
            }else{
            textView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            scrollView.contentSize.height = textView.frame.origin.y + textView.frame.height + 20
            self.scrollView.addSubview(textView)
             subCards.append(textView)
            }
        }
     //   cardBackGround.frame.size.height = textView.frame.origin.y + textView.frame.height + 20
        
    }
    
    @objc private func autoAddTextViewAtBottom(gesture:UITapGestureRecognizer){
        if addButtonStateisOpen{
            turnOffToolBox()
            return
        }
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
        }
        
    }
    
    @objc private func addVideo(){
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
    
    @objc private func addVoice(){
        let voiceCard = VoiceCard(id: UUID().uuidString,title:"record")
        let voiceView = CardView.getSingleVoiceView(card: voiceCard)
        voiceView.hero.id = voiceCard.getId()
        voiceView.delegate = self
        voiceView.title.delegate = self
        cardViewAddPanGesture(voiceView)
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
    

    
    
    
    /**
        gesture delegate
    */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && gestureRecognizer.view == cardColor{
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            if gesture.velocity(in: gesture.view).y < 500{
               return true
            }else{
               return false
            }
        }else if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && (gestureRecognizer.view?.isKind(of: CardView.self))!{
            let view = gestureRecognizer.view as! CardView
            if view.isEditMode{
                return true
            }else{
                return false
            }
        }else{
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.view?.isKind(of: CardView.self))! && (otherGestureRecognizer.view?.isKind(of: UIScrollView.self))! {
           return false
        }else if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self){
            return true
    }else{
            return true
        }
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.view?.isKind(of: CardView.self))!{
            let cardView = gestureRecognizer.view as! CardView
            if cardView.isEditMode{
                return true
            }else{
                return false
            }
        }else{
            return true
        }
    }
    
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.view?.isKind(of: CardView.self))! && (otherGestureRecognizer.view?.isKind(of: UIScrollView.self))!{
            let cardView = gestureRecognizer.view as! CardView
            if !cardView.isEditMode{
                return true
            }else{
                return false
            }
        }else if (gestureRecognizer.view?.isKind(of: CardView.self))! && (otherGestureRecognizer.view?.isKind(of: ProgressBar.self))!{
            return true
        }else{
            return false
        }
    }
    
  
    
    
}

/**
 extensions for cardeditor
 */
extension CardEditor:CardViewDelegate{
    
    internal func movieView(expand videoView: CardView.MovieView) {
        let vc = VideoController()
        vc.loadMovie(avPlayer: videoView.player!)
        self.present(vc, animated: true){
            
        }
    }
    
    internal func voiceView(recognition cardView: CardView.VoiceCardView) {
        cardView.hero.id = cardView.card.getId()
        let vc = VoiceRecognitionController()
        vc.modalPresentationStyle = .currentContext
        vc.loadVoiceCardView(voiceCard: cardView.card as! VoiceCard)
        vc.hero.isEnabled = true
        vc.superCard.hero.id = cardView.card.getId()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    internal func cardView(commentHide picView: CardView.PicView) {
        reLoad()
    }
    
    internal func cardView(commentShowed picView: CardView.PicView) {
        reLoad()
        picView.commentView.becomeFirstResponder()
    }
    
    internal func picView(extractText:CardView.PicView){
        let vc = OCRController()
        vc.modalPresentationStyle = .currentContext
        vc.hero.isEnabled = true
        vc.image = extractText.image.image
        extractText.hero.id = extractText.card.getId()
        self.present(vc, animated: true){
            vc.imageView.hero.id = extractText.hero.id
        }
    }
    
    internal func cardView(translate view: CardView,text:String) {
        endEditing()
        let vc = TranslationController()
        vc.modalPresentationStyle = .currentContext
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



