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

class CardEditor:UIViewController,UITextViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, MAMapViewDelegate,UIMapPickerDelegate,UIActionSheetDelegate,CardViewDelegate,AttributedTextViewDelegate, UIPickerViewDelegate,UIPickerViewDataSource{
    //main components
    var cardTitle: UITextView! = UITextView()
    var tag: UITextView! = UITextView()
    var definition: UITextView! = UITextView()
    var descriptions: UITextView! = UITextView()
    var scrollView:UIScrollView = UIScrollView()
    var cardColor:UIView!
    var cardBackGround = UIView()
    var attributedView:AttributedTextView?
    var pickerView:UIPickerView!
    var pickerColorView:UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var addButton: UIButton!
    var color:UIColor = UIColor.red
    var card:Card?
    var type:CardEditor.type?
    var textMode:Constant.TextMode!
    var subCards:[CardView] = [CardView]()
    /////////addButton
    var addButtonStateisOpen:Bool = false
    var addSubCard:UIView = UIView()
    var addPicCard:UIView = UIView()
    var addExa:UIView = UIView()
    var addText:UIView = UIView()
    var addVoiceView:UIView = UIView()
    var addMapView = UIView()
    var addMovieView = UIView()
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
    var selectedMapView:CardView.MapCardView?
    private var EditingSubCard:[CardEditorView] = [CardEditorView]()
    
    
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
    func selectFont()
    {
        if Int((attributedView?.font?.pointSize)!) >= 1{
        pickerView.selectRow(Int((attributedView?.font?.pointSize)!) - 1, inComponent: 0, animated: true)
        }else{
        pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        pickerColorView.backgroundColor = attributedView?.fontColor == nil ? UIColor.black : attributedView?.fontColor
        self.view.addSubview(pickerColorView)
        self.view.addSubview(pickerView)
        let pickerViewDone = UIButton(frame: CGRect(x: pickerView.frame.width - 100, y:30, width: 100, height: 30))
        pickerViewDone.setTitle("Done", for: .normal)
        pickerViewDone.setTitleColor(UIColor.black, for: .normal)
        pickerViewDone.addTarget(self, action: #selector(getPickerViewValue), for: .touchDown)
        self.view.addSubview(pickerViewDone)
       
    }
    
    //ActionSheet
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
    }

    
    
/**TextView
 */
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
                textView.text = "Enter here"
            }
            textView.textColor = .gray
        }
       
        textView.backgroundColor = .clear
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.frame.origin.y = -50
        }, completion: nil)
        attributedView?.removeFromSuperview()
        attributedView = nil
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let y = scrollView.contentOffset.y
        let frame = textView.frame
        
        //定义一个constrainSize值用于计算textview的高度
        
        let constrainSize=CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        
        //获取textview的真实高度
        
        var size = textView.sizeThatFits(constrainSize)
        
        //如果textview的高度大于最大高度高度就为最大高度并可以滚动，否则不能滚动
        
        
        
        if textView.superview != nil{
            if let cardView = textView.superview as? CardView.TextView{
                textView.frame.size.height=size.height
                textView.superview?.frame.size.height = size.height
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
                
            }
        }
        //重新设置textview的高度
        
        
        
        
        //重新设置subViews的位置
        
        
        
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray{
            textView.text = ""
            textView.textColor = .white
        }
       textView.backgroundColor = UIColor.clear
      //textView.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
       selectedTextView = textView
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        UIView.animate(withDuration: 0.5, animations: {
           self.scrollView.frame.origin.y = -50
        }, completion: nil)
        attributedView?.removeFromSuperview()
        attributedView = nil
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        selectedTextView = textView
        return true
    }
    

    override func viewWillAppear(_ animated: Bool) {
        cardTitle.delegate = self
        tag.delegate = self
        definition.delegate = self
        descriptions.delegate = self
         if self.type == CardEditor.type.add{
           textViewDidEndEditing(cardTitle)
           textViewDidEndEditing(tag)
           textViewDidEndEditing(definition)
           textViewDidEndEditing(descriptions)
         }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        self.hero.isEnabled = true
        self.view.hero.id = "batman"
        self.view.backgroundColor = .white
        cardColor = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 150))
        cardTitle.frame = CGRect(x: 0, y: cardColor.frame.height - 50, width: self.view.bounds.width*0.8, height: 50)
        cardTitle.textColor = .white
        cardTitle.backgroundColor = .clear
        cardTitle.center.x = self.view.bounds.width/2
        cardTitle.layer.cornerRadius = 10
        cardTitle.textAlignment = .center
        cardTitle.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
       
        tag.frame = CGRect(x: 0, y: cardTitle.frame.height + cardTitle.frame.origin.y + 20, width: self.view.bounds.width*0.8, height: 30)
        tag.font =  UIFont(name: "AmericanTypewriter", size: 15)
        tag.textColor = .black
        tag.backgroundColor = .clear
        tag.center.x = self.view.bounds.width/2
        tag.layer.cornerRadius = 10
        
        let definitionLabel = UILabel()
        definitionLabel.font =  UIFont(name: "AmericanTypewriter", size: 20)
        definitionLabel.text = "Definition"
        definitionLabel.frame = CGRect(x:20, y: tag.frame.origin.y + tag.frame.height + 20, width: self.view.bounds.width, height: 20)
        definitionLabel.textColor = .black
        
        definition.frame = CGRect(x: 0, y: definitionLabel.frame.origin.y + definitionLabel.frame.height + 20, width: self.view.bounds.width*0.8, height: 100)
        definition.font = UIFont.systemFont(ofSize: 15)
        definition.textColor = .black
        definition.backgroundColor = .black
        definition.center.x = self.view.bounds.width/2
        definition.layer.cornerRadius = 10
        definition.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
      
        
        let descriptionLabel = UILabel()
        descriptionLabel.font =  UIFont(name: "AmericanTypewriter", size: 20)
        descriptionLabel.text = "Description"
        descriptionLabel.textColor = .black
        descriptionLabel.frame = CGRect(x: 20, y: definition.frame.origin.y + definition.frame.height + 20, width: self.view.bounds.width, height: 20)
        
        descriptions.frame = CGRect(x:0, y: descriptionLabel.frame.height + descriptionLabel.frame.origin.y + 20, width: self.view.bounds.width*0.8, height: 200)
        descriptions.font = .systemFont(ofSize:15)
        descriptions.textColor = .black
        descriptions.backgroundColor = .clear
        descriptions.center.x = self.view.bounds.width/2
        descriptions.layer.cornerRadius = 10
        descriptions.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
        
        cardBackGround.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height:  self.view.bounds.height)
        cardBackGround.backgroundColor = .white
        cardBackGround.addSubview(cardColor)
        cardBackGround.addSubview(cardTitle)
        cardBackGround.addSubview(tag)
        cardBackGround.addSubview(definition)
        cardBackGround.addSubview(descriptions)
        cardBackGround.addSubview(definitionLabel)
        cardBackGround.addSubview(descriptionLabel)
        let endEditingGesture = UITapGestureRecognizer()
        endEditingGesture.numberOfTapsRequired = 1
        endEditingGesture.numberOfTouchesRequired = 1
        endEditingGesture.addTarget(self, action: #selector(endEditing))
        cardBackGround.addGestureRecognizer(endEditingGesture)
        
       // cardBackGround.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(showPalette(_:)))
        cardColor.addGestureRecognizer(tapGesture)
        
        
        scrollView.frame = CGRect(x: CGFloat(0), y: -50, width: self.view.bounds.width, height: self.view.bounds.height)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        //scrollView.layer.cornerRadius = 15
        scrollView.isScrollEnabled = true
        scrollView.bounces = false
        scrollView.contentSize.height = cardBackGround.frame.height
        scrollView.contentSize.width = self.view.bounds.width
        scrollView.addSubview(cardBackGround)
        
        if card != nil{
            loadCard(card: card!)
        }
    
       self.view.addSubview(scrollView)
        
        cumulatedheight = Int(descriptions.frame.origin.y + descriptions.frame.height)
        
        self.view.bringSubview(toFront: addButton)
        self.view.bringSubview(toFront: doneButton)
        
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
    
    @objc func getPickerViewValue(sender:UIButton){
        pickerView.removeFromSuperview()
        pickerColorView.removeFromSuperview()
        sender.removeFromSuperview()
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
    }
    
    
    
    @objc func keyboardWillShow(aNotification: NSNotification){
        print("keyBoardShow")
        let userinfo: NSDictionary = aNotification.userInfo! as NSDictionary
        let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (nsValue as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        if (selectedTextView != nil){
            //add the attributed view
            if attributedView != nil && attributedView?.superview != nil{
                attributedView?.removeFromSuperview()
            }
            attributedView = AttributedTextView(y: self.view.frame.height - height! - 30, textView: selectedTextView!)
            attributedView?.delegate = self
            self.view.addSubview(attributedView!)
            //adjust the offset of the scrollview
            var relativeHeight:CGFloat!
            if !(selectedTextView?.superview?.isKind(of: CardView.TextView.self))! && !(selectedTextView?.superview?.isKind(of: CardView.ExaView.self))! && !(selectedTextView?.superview?.isKind(of: CardView.SubCardView.self))!{
            relativeHeight = (selectedTextView?.frame.origin.y)! - scrollView.contentOffset.y  + (selectedTextView?.frame.height)! + CGFloat(UIDevice.current.Xdistance())
            }else{
            relativeHeight = (selectedTextView?.superview?.frame.origin.y)! - scrollView.contentOffset.y  + (selectedTextView?.superview?.frame.height)! + CGFloat(UIDevice.current.Xdistance())
                
            }
            print(selectedTextView?.frame.origin.y)
            let heightDifference = relativeHeight - (self.view.frame.height - height!)
            if heightDifference > 0{
            UIView.animate(withDuration: 0.5) {
                self.scrollView.contentOffset.y += heightDifference
            }
            }
    }
 
    }
    
    enum type:String{
        case add = "add"
        case save = "save"
    }
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    @objc func showPalette(_ sender:UIGestureRecognizer){
        if !ifPaletteShowed{
        //let location = sender.location(in: cardBackGround)
        let location = sender.location(in:sender.view)
        let palette = Palette(frame: CGRect(x: location.x, y: location.y, width: 150, height: 150))
        palette.center = location
        var colors:[UIColor] = [UIColor]()
        colors.append(Constant.Color.西瓜红)
        colors.append(Constant.Color.水荡漾清猿啼)
        colors.append(Constant.Color.勿忘草色)
        colors.append(Constant.Color.江戸紫)
        colors.append(Constant.Color.花季色)
        palette.addColors(colors)
        palette.parentView = sender.view
        palette.viewController = self
        sender.view?.addSubview(palette)
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
    
    
    @objc func longTap(_ sender:UILongPressGestureRecognizer){
        let cardView = sender.view as! CardView
        for card in subCards{
        
        }
    }
    
    func deleteButtonClicked() {
        
    }
    
    func loadCard(card:Card){
        self.card = card
        cardTitle.text = card.getTitle()
        cardColor.backgroundColor = card.getColor()
        tag.text = card.getTag()
        definition.attributedText = NSAttributedString(string:card.getDefinition())
        descriptions.attributedText = NSAttributedString(string:card.getDescription())
        color = card.getColor()
        cardBackGround.backgroundColor = .white
       // self.view.backgroundColor = color
        var cumulatedHeight = descriptions.frame.origin.y + descriptions.frame.height + 20
        for card in card.getChilds(){
            let longTapGesture = UILongPressGestureRecognizer()
            longTapGesture.numberOfTapsRequired = 1
            longTapGesture.numberOfTouchesRequired = 1
            longTapGesture.minimumPressDuration = 2
            longTapGesture.addTarget(self, action: #selector(longTap))
            if card.isKind(of: ExampleCard.self){
                let exaView = CardView.singleExampleView(card:card)
                var dic:NSDictionary?
                exaView.textView.attributedText = try? NSAttributedString(data:(card as! ExampleCard).getExample().data(using: .utf8)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes:&dic)
                print((card as! ExampleCard).getExample())
                exaView.example = (card as! ExampleCard).getExample()
                exaView.frame.origin.y = cumulatedHeight
                exaView.textView.delegate = self
                exaView.delegate = self
                cumulatedHeight += exaView.frame.height + 20
                cardBackGround.addSubview(exaView)
                self.subCards.append(exaView)
            }else if card.isKind(of: PicCard.self){
                let picCard = CardView.getSinglePicView(pic: card as! PicCard)
                picCard.delegate = self
                cardBackGround.addSubview(picCard)
                subCards.append(picCard)
               // picCard.image.image = #imageLiteral(resourceName: "searchBar")
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent(card.getId() + ".jpg")
                if FileManager.default.fileExists(atPath: (url?.path)!){
                    let data = NSData(contentsOf: url!)
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
                let text = (card as! TextCard).getText()
                let textCard = CardView.getSingleTextView(string: text)
                textCard.delegate = self
                textCard.frame.origin.y = cumulatedHeight
                textCard.textView.delegate = self
                textCard.addSubview(textCard.textView)
                cumulatedHeight += textCard.frame.height + 20
                cardBackGround.addSubview(textCard)
                subCards.append(textCard)
            }else if card.isKind(of: VoiceCard.self){
                let voiceCard = card as! VoiceCard
                let voiceCardView = CardView.getSingleVoiceView(card: voiceCard)
                voiceCardView.delegate = self
                if voiceCard.voiceManager!.state == .willRecord || voiceCard.voiceManager!.state == .recording{
                    voiceCard.voiceManager?.state = .willRecord
                }else{
                    voiceCard.voiceManager?.state = .haveRecord
                }
                voiceCardView.frame.origin.y = cumulatedHeight
                cumulatedHeight += voiceCardView.frame.height + 20
                cardBackGround.addSubview(voiceCardView)
                subCards.append(voiceCardView)
            }else if card.isKind(of: MapCard.self){
                let mapCard = card as! MapCard
                let mapCardView = CardView.getSingleMapView(card: mapCard)
                mapCardView.delegate = self
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent("mapPic")
                url?.appendPathComponent(card.getId() + ".jpg")
                if !manager.fileExists(atPath: (url?.path)!){
                    mapCardView.image.image = #imageLiteral(resourceName: "searchBar")
                    DispatchQueue.global().async {
                        mapCardView.loadPic()
                    }
                }else{
                    
                    mapCardView.image.image = UIImage(contentsOfFile: (url?.path)!)
                }
                mapCardView.frame.origin.y = cumulatedHeight
                let tapgesture = UITapGestureRecognizer(target: self, action: #selector(updateMap))
                tapgesture.numberOfTapsRequired = 1
                tapgesture.numberOfTouchesRequired = 1
                mapCardView.addGestureRecognizer(tapgesture)
                cumulatedHeight += mapCardView.frame.height + 20
                cardBackGround.addSubview(mapCardView)
                subCards.append(mapCardView)
            }else if card.isKind(of: MovieCard.self){
                let movieCard = card as! MovieCard
                let movieCardView = CardView.getSingleMovieView(card: movieCard)
                movieCardView.frame.origin.y = cumulatedHeight
                 cumulatedHeight += movieCardView.frame.height + 20
                cardBackGround.addSubview(movieCardView)
                subCards.append(movieCardView)
            }
            else{
         let cardView = CardView.getSubCardView(card)
        cardView.delegate = self
         cardView.frame.origin.y = cumulatedHeight
         cardView.layer.shadowOpacity = 0.5
         cardView.layer.shadowColor = UIColor.black.cgColor
         cardView.layer.shadowOffset = CGSize(width:1, height:1)
         cardView.title.delegate = self
         cardView.content.delegate = self
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.addTarget(self, action: #selector(performCardEditor))
            cardView.addGestureRecognizer(tapGesture)
         cumulatedHeight += cardView.frame.height + 20
         cardBackGround.addSubview(cardView)
         self.subCards.append(cardView)
       
        }
            cardBackGround.frame.size.height = (subCards.last?.frame.height)! + (subCards.last?.frame.origin.y)! + 20
             scrollView.contentSize.height = (subCards.last?.frame.height)! + (subCards.last?.frame.origin.y)! + 20
    }
        
        
    }
    
    func reLoad(){
        descriptions.text = card?.getDescription()
        definition.text = card?.getDefinition()
        cardTitle.text = card?.getTitle()
        tag.text = card?.getTag()
        cardTitle.textColor = card?.getColor()
        
        for subview in cardBackGround.subviews{
            if subview.isKind(of: CardView.self) || subview.isKind(of: CardView.ExaView.self){
                subview.removeFromSuperview()
            }
        }
        var cumulatedHeight = descriptions.frame.origin.y + descriptions.frame.height + 20
        for card in subCards{
            cardBackGround.addSubview(card)
            cardBackGround.frame.size.height = card.frame.origin.y + card.frame.height + 20
        }
    }
    
    
    
    @objc func animationStop(){
        EditingSubCard.last?.removeFromSuperview()
    }
    
    @IBAction func save(_ sender: Any) {
        if EditingSubCard.count >= 1{
            var index = 0
            if EditingSubCard.count > 1{
                for card in EditingSubCard[EditingSubCard.count-2].subCards{
                    if card.card.getId() == EditingSubCard.last?.card!.getId(){
                        let last = EditingSubCard.last
                        last?.card?.setTag((last?.classification.text)!)
                        last?.card?.setTitle((last?.cardTitle.text)!)
                        last?.card?.setDefinition((last?.definition.text)!)
                        last?.card?.setDescription((last?.descriptions.text)!)
                        var childs:[Card] = [Card]()
                        for child in (last?.subCards)!{
                            childs.append(child.card)
                        }
                        last?.card?.setChilds(childs)
                        EditingSubCard[EditingSubCard.count-2].subCards[index].card = EditingSubCard.last?.card!
                        (EditingSubCard[EditingSubCard.count-2].subCards[index] as! CardView.SubCardView).title.text = last?.card?.getTitle()
                        (EditingSubCard[EditingSubCard.count-2].subCards[index] as! CardView.SubCardView).content.text = last?.card?.getDefinition()
                        break
                    }
                    index += 1
                }
                
                EditingSubCard[EditingSubCard.count-2].reLoad()
                scrollView.contentSize = (EditingSubCard[EditingSubCard.count-2].frame.size)
            }else{
            for card in subCards{
                if card.card.getId() == EditingSubCard.last?.card!.getId(){
                    let last = EditingSubCard.last
                    last?.card?.setTag((last?.classification.text)!)
                    last?.card?.setTitle((last?.cardTitle.text)!)
                    last?.card?.setDefinition((last?.definition.text)!)
                    last?.card?.setDescription((last?.descriptions.text)!)
                  
                    var childs:[Card] = [Card]()
                    for child in (last?.subCards)!{
                        childs.append(child.card)
                    }
                    last?.card?.setChilds(childs)
                    subCards[index].card = last?.card
                    subCards[index].label.text = last?.card?.getTitle()
                    subCards[index].labelofDes.text = last?.card?.getDefinition()
                    break
                }
                index += 1
            }
                reLoad()
                scrollView.contentSize = cardBackGround.frame.size
            }
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            UIView.setAnimationDidStop(#selector(animationStop))
            EditingSubCard.last?.alpha = 0
            EditingSubCard.removeLast()
            UIView.commitAnimations()
            
        }else{
        if self.type == CardEditor.type.add{
            var childs:[Card] = [Card]()
            if subCards.count >= 1{
                for card in self.subCards
                {
                    childs.append(card.card)
                    if card.isKind(of: CardView.PicView.self){
                        let manager = FileManager.default
                        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                        url?.appendPathComponent(loggedID)
                        url?.appendPathComponent(card.card.getId() + ".jpg")
                        if manager.fileExists(atPath: (url?.path)!){
                            let image = UIImage(data: try! NSData(contentsOf: url!) as Data)!
                           // User.uploadImageWithAF(email:loggedemail,image:image,cardID:card.card.getId())
                           // User.uploadPhotoUsingFTP(url: url!)
                            //deprecated above
                            User.uploadPhotoUsingQCloud(email: loggedemail, url: url!)
                        }
                    }else if card.isKind(of: CardView.ExaView.self){
                        (card.card as! ExampleCard).setExample((card as! CardView.ExaView).textView.attributedText.string)
                        print((card as! CardView.ExaView).textView.attributedText.string)
                    }else if card.isKind(of: CardView.TextView.self){
                        (card.card as! TextCard).setText((card as! CardView.TextView).textView.attributedText.string)
                    }else if card.isKind(of: CardView.VoiceCardView.self){
                        let manager = FileManager.default
                        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                        url?.appendPathComponent(loggedID)
                        url?.appendPathComponent("audio")
                        url?.appendPathComponent(card.card.getId() + ".wav")
                        if manager.fileExists(atPath: (url?.path)!){
                            let data = NSData(contentsOfFile: (url?.path)!)
                           
                            User.uploadAudioUsingQCloud(email: loggedemail, url: url!)
                        }
                    }else if card.isKind(of: CardView.MapCardView.self){
                        let manager = FileManager.default
                        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                        url?.appendPathComponent(loggedID)
                        url?.appendPathComponent("mapPic")
                        url?.appendPathComponent(card.card.getId() + ".jpg")
                        if manager.fileExists(atPath: (url?.path)!){
                            User.uploadPhotoUsingQCloud(email: loggedemail, url: url!)
                        }
                        else if card.isKind(of: CardView.MovieView.self){
                            if manager.fileExists(atPath:((card.card as! MovieCard).path)){
                                User.uploadMovieUsingQCloud(email: loggedemail, url: url!)
                            }
                        }
                    }else if card.isKind(of: CardView.SubCardView.self){
                        let sub = card.card
                        let view = card as! CardView.SubCardView
                        sub?.setTitle(view.title.attributedText.string)
                        sub?.setDefinition(view.content.attributedText.string)
                }
                }
            }
            
            let date = NSDate()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strNowTime = timeFormatter.string(from: date as Date) as String
            let card = Card(title: cardTitle.text, tag: tag.text, description: descriptions.attributedText.string, id: UUID().uuidString, definition: definition.attributedText.string, color: color, cardType:Card.CardType.card.rawValue,modifytime:strNowTime)
            card.addChildNotes(childs)
            User.addCard(email: loggedemail, card: card, completionHandler: { (json:JSON?) in
                if json != nil{
                    if json!["ifSuccess"].boolValue{
                        print("Add Card SuccessFul")
                    }
                }
            })
        let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent("card.txt")
            if let dateRead = try? Data.init(contentsOf: url!){
                var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                if cardList == nil{
                    cardList = [Card]()
                }
                cardList?.append(card)
                let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
                do{
                    try datawrite.write(to: url!)
                }catch{
                    print("fail to add")
                }
            }
            
        }else if self.type == CardEditor.type.save{
            let manager = FileManager.default
           // var subCards:[Card] = [Card]()
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent("card.txt")
            let data = try! Data(contentsOf: url!)
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(data)
            
            if let dateRead = try? Data.init(contentsOf: url!){
                var cardList = NSKeyedUnarchiver.unarchiveObject(with: dateRead) as? [Card]
                if cardList == nil{
                    cardList = [Card]()
                }
                if card != nil{
                    var index = 0
                    for card in cardList!{
                        if card.getId() != self.card?.getId(){
                        index += 1
                        }else{
                            break
                        }
                    }
                    self.card?.setTitle(cardTitle.text)
                    self.card?.setColor(color)
                    self.card?.setDefinition(definition.attributedText.string)
                    self.card?.setDescription(descriptions.attributedText.string)
                    self.card?.setTag(tag.text)
                    var childs = [Card]()
                    for card in self.subCards
                    {
                        childs.append(card.card)
                        if card.isKind(of: CardView.PicView.self){
                            let manager = FileManager.default
                            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                            url?.appendPathComponent(loggedID)
                            url?.appendPathComponent(card.card.getId() + ".jpg")
                            if manager.fileExists(atPath: (url?.path)!){
                            
                             //User.uploadImageWithAF(email:loggedemail,image:image,cardID:card.card.getId())
                               User.uploadPhotoUsingQCloud(email: loggedemail, url: url!)
                            }
                        }else if card.isKind(of: CardView.ExaView.self){
                            let data = try? (card as! CardView.ExaView).textView.attributedText.data(from: NSMakeRange(0, (card as! CardView.ExaView).textView.attributedText.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.html])
                            let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print(string)
                            (card.card as! ExampleCard).setExample(string as! String)
                        }else if card.isKind(of: CardView.TextView.self){
                            (card.card as! TextCard).setText((card as! CardView.TextView).textView.attributedText.string)
                        }else if card.isKind(of: CardView.VoiceCardView.self){
                            let manager = FileManager.default
                            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                            url?.appendPathComponent(loggedID)
                            url?.appendPathComponent("audio")
                            url?.appendPathComponent(card.card.getId() + ".wav")
                            if manager.fileExists(atPath: (url?.path)!){
                            
                               // User.uploadAudioWithAF(email: loggedemail, filePath: (url?.path)!, cardID: card.card.getId())
                                User.uploadAudioUsingQCloud(email: loggedemail, url: url!)
                            }
                        }else if card.isKind(of: CardView.MapCardView.self){
                            let manager = FileManager.default
                            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                            url?.appendPathComponent(loggedID)
                            url?.appendPathComponent("mapPic")
                            url?.appendPathComponent(card.card.getId() + ".jpg")
                            if manager.fileExists(atPath: (url?.path)!){
                           
                               // User.uploadImageWithAF(email: loggedemail, image: image!, cardID: card.card.getId())
                               User.uploadPhotoUsingQCloud(email: loggedemail, url: url!)
                            }
                            else if card.isKind(of: CardView.MovieView.self){
                                if manager.fileExists(atPath:((card.card as! MovieCard).path)){
                                    User.uploadMovieUsingQCloud(email: loggedemail, url: url!)
                                }
                            }
                        }else if card.isKind(of: CardView.SubCardView.self){
                             let sub = card.card
                             let view = card as! CardView.SubCardView
                             sub?.setTitle(view.title.attributedText.string)
                             sub?.setDefinition(view.content.attributedText.string)
                        }
                    }
                  
                    self.card?.setChilds(childs)
                    //update time
                    let date = NSDate()
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let strNowTime = timeFormatter.string(from: date as Date) as String
                    self.card?.updateTime(strNowTime)
                    User.updateCard(card: (self.card)!, email: loggedemail, completionHandler: { (json:JSON?) in
                        if json != nil{
                        if json!["ifSuccess"].boolValue {
                            print("update card Success")
                        }
                        }
                    })
                    cardList![index] = self.card!
                    let datawrite = NSKeyedArchiver.archivedData(withRootObject:cardList)
                    do{
                        try datawrite.write(to: url!)
                    }catch{
                        print("fail to add")
                    }
                }
           }
       }
        self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func createButtonWithLabel(title:String,frame:CGRect, icon:FAType)->UIView{
        let subCardLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        subCardLabel.textAlignment = .center
        subCardLabel.font = UIFont.systemFont(ofSize: 15)
        subCardLabel.textColor = .white
        subCardLabel.text = title
        subCardLabel.setFAText(prefixText: "", icon: icon, postfixText: "", size: 20)
        let button = UIView(frame: frame)
        button.backgroundColor = .black
        button.layer.cornerRadius = 25
        button.addSubview(subCardLabel)
        return button
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        if !addButtonStateisOpen{
        addButtonStateisOpen = true
            addSubCard = createButtonWithLabel(title: "SubCard", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),icon:FAType.FAIdCard)
        let subCardtapGesture = UITapGestureRecognizer()
        subCardtapGesture.numberOfTapsRequired = 1
        subCardtapGesture.numberOfTouchesRequired = 1
        subCardtapGesture.addTarget(self, action: #selector(addCard))
        addSubCard.addGestureRecognizer(subCardtapGesture)
        
       
       addExa = createButtonWithLabel(title: "Example", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),icon: FAType.FAApple)
        let exaTapGesture = UITapGestureRecognizer()
        exaTapGesture.numberOfTapsRequired = 1
        exaTapGesture.numberOfTouchesRequired = 1
        exaTapGesture.addTarget(self, action: #selector(addExample))
        addExa.addGestureRecognizer(exaTapGesture)
        
            
            addPicCard = createButtonWithLabel(title: "Photo", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),icon:FAType.FAPhoto)
            let picGesture = UITapGestureRecognizer()
            picGesture.numberOfTapsRequired = 1
            picGesture.numberOfTouchesRequired = 1
            picGesture.addTarget(self, action: #selector(addPic))
            addPicCard.addGestureRecognizer(picGesture)
            
            
            addText = createButtonWithLabel(title: "Text", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),icon:FAType.FAFont)
        let addtextGesture = UITapGestureRecognizer()
            addtextGesture.numberOfTapsRequired = 1
            addtextGesture.numberOfTouchesRequired = 1
            addtextGesture.addTarget(self, action: #selector(addTextView))
            addText.addGestureRecognizer(addtextGesture)
            
            addVoiceView = createButtonWithLabel(title: "Voice", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),icon:FAType.FAMicrophone)
           let addVoiceGesture = UITapGestureRecognizer()
            addVoiceGesture.numberOfTapsRequired = 1
            addVoiceGesture.numberOfTouchesRequired = 1
            addVoiceGesture.addTarget(self, action: #selector(addVoice))
            addVoiceView.addGestureRecognizer(addVoiceGesture)
            
            addMapView = createButtonWithLabel(title: "Location", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50),icon:FAType.FAMapMarker)
            let addMapGesture = UITapGestureRecognizer()
            addMapGesture.numberOfTapsRequired = 1
            addMapGesture.numberOfTouchesRequired = 1
            addMapGesture.addTarget(self, action: #selector(addMap))
            addMapView.addGestureRecognizer(addMapGesture)
            
            addMovieView = createButtonWithLabel(title: "Video", frame: CGRect(x: sender.center.x, y: sender.center.y, width: 50, height: 50), icon: .FAVideoCamera)
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
            
        for addButton in addButtonList{
                self.view.addSubview(addButton)
            }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.1)
        var cumulatedHeight = CGFloat(75)
            for addButton in addButtonList{
                addButton.center.x = sender.center.x - 20
                addButton.center.y = sender.center.y - cumulatedHeight
                cumulatedHeight += 75
            }
        UIView.commitAnimations()
        }else if addButtonStateisOpen{
            addButtonStateisOpen = false
            var addcumulatedHeight = 75
            UIView.animate(withDuration: 0.1, animations: {
                for addButton in self.addButtonList{
                    addButton.center.x = sender.center.x + 20
                    addButton.center.y = sender.center.y + CGFloat(addcumulatedHeight)
                    addcumulatedHeight += 75
                }
            }, completion: { (ifcomplete) in
                for addButton in self.addButtonList{
                    addButton.removeFromSuperview()
                }
                self.addButtonList.removeAll()
            })
     }
    }
    
    
    @objc func addPic(){
        
        let alertSheet = UIAlertController(title: "Select From", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let fromalbum = UIAlertAction(title: "Album", style: .default) { (action) in
            print("choose form album")
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addPic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .savedPhotosAlbum
             cameraPicker.mediaTypes = [kUTTypeImage as! String]
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addPic"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.mediaTypes = [kUTTypeImage as! String]
             self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    @objc func updatePic(_ sender:UITapGestureRecognizer){
        selectedPictureView = sender.view as! CardView.PicView
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
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent(piccard.getId() + ".jpg")
                let data = UIImageJPEGRepresentation(image, 0.5)
                try? data?.write(to: url!)
        let picView = CardView.getSinglePicView(pic: piccard)
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.addTarget(self, action: #selector(updatePic))
        picView.addGestureRecognizer(tapGesture)
        picView.layer.shadowColor = UIColor.black.cgColor
        picView.layer.shadowOpacity = 0.5
        picView.layer.shadowOffset = CGSize(width:1,height:1)
            if subCards.count > 0{
                picView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
        
            }else{
        picView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            }
        subCards.append(picView)
        cardBackGround.addSubview(picView)
          scrollView.contentSize.height = picView.frame.origin.y + picView.frame.height + 20
            cardBackGround.frame.size.height = picView.frame.origin.y + picView.frame.height + 20
        }else if picTureAction == "updatePic"{
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if selectedPictureView != nil{
                selectedPictureView?.image.image = image
                (selectedPictureView?.card as! PicCard).pic = image
                let manager = FileManager.default
                var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
                url?.appendPathComponent(loggedID)
                url?.appendPathComponent((selectedPictureView?.card as! PicCard).getId() + ".jpg")
                let data = UIImageJPEGRepresentation(((selectedPictureView)?.image.image)!,0.5)
                try? data?.write(to: url!)
            }
        }else if picTureAction == "addVideo"{
            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            print("videoURl:\(videoURL)")
            let id = UUID().uuidString
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: Constant.Configuration.url.Movie.path), withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.copyItem(at: videoURL, to: URL(fileURLWithPath: Constant.Configuration.url.Movie.appendingPathComponent(id + ".mov").path))
            let movieCard = MovieCard(id: id)
           // movieCard.path = videoURL.path
            let movieView = CardView.getSingleMovieView(card: movieCard)
            if subCards.count > 0{
                movieView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
                
            }else{
                movieView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            }
            subCards.append(movieView)
            cardBackGround.addSubview(movieView)
            scrollView.contentSize.height = movieView.frame.origin.y + movieView.frame.height + 20
            cardBackGround.frame.size.height = movieView.frame.origin.y + movieView.frame.height + 20
            
        }
         self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addCard(){
        let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: date as Date) as String
        let card = Card(title: "title", tag: "", description: "", id: UUID().uuidString, definition: "", color: color, cardType: Card.CardType.card.rawValue, modifytime:strNowTime)
        let cardView = CardView.getSubCardView(card)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width:1, height:1)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(performCardEditor))
        cardView.addGestureRecognizer(tapGesture)
        if subCards.count < 1{
        cardView.frame.origin.y = CGFloat(cumulatedheight + 20)
        }else if subCards.count >= 1{
            cardView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
        }
        cumulatedheight += Int(20 + cardView.frame.size.height)
        cardBackGround.addSubview(cardView)
        scrollView.contentSize.height = cardView.frame.origin.y + cardView.frame.height
        + 20
        cardBackGround.frame.size.height = cardView.frame.origin.y + cardView.frame.height + 20
        subCards.append(cardView)
    }
    
    @objc func performCardEditor(_ sender:UITapGestureRecognizer){
    let card = (sender.view as! CardView.SubCardView).card
    let cardEditorView = CardEditorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - CGFloat(UIDevice.current.Xdistance() - UIDevice.current.BottomDistance())))
        cardEditorView.loadCard(card!)
        cardEditorView.cardTitle.text = (sender.view as! CardView.SubCardView).title.text
        cardEditorView.definition.text = (sender.view as! CardView.SubCardView).content.text
        self.scrollView.addSubview(cardEditorView)
        self.scrollView.contentSize = CGSize(width: cardEditorView.frame.width, height: cardEditorView.frame.height)
        self.scrollView.contentOffset.y = 0
        cardEditorView.cardTitle.delegate = self
        cardEditorView.definition.delegate = self
        cardEditorView.descriptions.delegate = self
        cardEditorView.classification.delegate = self
        EditingSubCard.append(cardEditorView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination:CardEditor = segue.destination as! CardEditor
        destination.loadCard(card: sender as! Card)
    }
    
    @objc func addExample(){
        let exampleCard = ExampleCard(example: "")
        var exaView = CardView.singleExampleView(card:exampleCard)
         exaView.textView.delegate = self
        if subCards.count < 1{
            exaView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            self.cardBackGround.addSubview(exaView)
        }else if subCards.count >= 1{
            exaView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.cardBackGround.addSubview(exaView)
        }
        subCards.append(exaView)
        cardBackGround.frame.size.height = exaView.frame.origin.y + exaView.frame.height + 20
        scrollView.contentSize.height = exaView.frame.origin.y + exaView.frame.height + 20
    }
    
    @objc func addTextView(){
        let textView = CardView.getSingleTextView(string: "")
        textView.textView.delegate = self
        textView.addSubview(textView.textView)
        if subCards.count < 1{
            textView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            self.cardBackGround.addSubview(textView)
        }else if subCards.count >= 1{
            textView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.cardBackGround.addSubview(textView)
        }
        subCards.append(textView)
        cardBackGround.frame.size.height = textView.frame.origin.y + textView.frame.height + 20
        scrollView.contentSize.height = textView.frame.origin.y + textView.frame.height + 20
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
            cameraPicker.mediaTypes = [kUTTypeMovie as! String]
           
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let cameraPicker = UIImagePickerController()
            self.picTureAction = "addVideo"
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.mediaTypes = [kUTTypeMovie as! String]
            self.present(cameraPicker, animated: true, completion: nil)
        }
        alertSheet.addAction(cancelAction)
        alertSheet.addAction(fromalbum)
        alertSheet.addAction(takePhoto)
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    @objc func addVoice(){
        let voiceCard = VoiceCard(id: UUID().uuidString)
        let voiceView = CardView.getSingleVoiceView(card: voiceCard)
        if subCards.count < 1{
            voiceView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            self.cardBackGround.addSubview(voiceView)
        }else if subCards.count >= 1{
            voiceView.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.cardBackGround.addSubview(voiceView)
        }
        subCards.append(voiceView)
        cardBackGround.frame.size.height = voiceView.frame.origin.y + voiceView.frame.height + 20
        scrollView.contentSize.height = voiceView.frame.origin.y + voiceView.frame.height + 20
    }
    
    @objc func addMap(){
        let picker = UIMapPicker()
        picker.delegate = self
        mapAction = "add"
        picker.action = UIMapPicker.Action.add.rawValue
        self.present(picker, animated: false, completion: nil)
    }
    
    @objc func updateMap(_ sender:UITapGestureRecognizer){
        let mapView = sender.view as! CardView.MapCardView
        let picker = UIMapPicker()
         picker.action = UIMapPicker.Action.update.rawValue
         picker.latitude = (mapView.card as! MapCard).latitude
         picker.longitude = (mapView.card as! MapCard).longitude
         picker.delegate = self
         mapAction = "update"
         selectedMapView = mapView
        self.present(picker,animated:false,completion: nil)
        
    }
    
    func UIMapDidSelected(image:UIImage,poi:AMapPOI?,formalAddress:String) {
        if mapAction == "add"{
        let id = UUID().uuidString
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let manager = FileManager.default
        var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
        url?.appendPathComponent(loggedID)
        url?.appendPathComponent("mapPic")
        try? manager.createDirectory(atPath: (url?.path)!, withIntermediateDirectories: true, attributes: nil)
        url?.appendPathComponent(id + ".jpg")
        do{
            try? imageData?.write(to: url!)
        }catch let err{
            print(err.localizedDescription)
        }
        let mapCard = MapCard(poi: poi, formalAddress: formalAddress, id:id)
        let mapview = CardView.getSingleMapView(card: mapCard)
        if subCards.count < 1{
            mapview.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
            self.cardBackGround.addSubview(mapview)
        }else if subCards.count >= 1{
            mapview.frame.origin.y = (subCards.last?.frame.origin.y)! + (subCards.last?.frame.height)! + 20
            self.cardBackGround.addSubview(mapview)
        }
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(updateMap))
        tapgesture.numberOfTapsRequired = 1
        tapgesture.numberOfTouchesRequired = 1
        mapview.addGestureRecognizer(tapgesture)
        subCards.append(mapview)
        cardBackGround.frame.size.height = mapview.frame.origin.y + mapview.frame.height + 20
        scrollView.contentSize.height = mapview.frame.origin.y + mapview.frame.height + 20
        }else if mapAction == "update"{
            selectedMapView?.image.image = image
            let mapCard = (selectedMapView?.card as! MapCard)
            mapCard.image = image
            let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent(loggedID)
            url?.appendPathComponent("mapPic")
            try? manager.createDirectory(atPath: (url?.path)!, withIntermediateDirectories: true, attributes: nil)
            url?.appendPathComponent(mapCard.getId() + ".jpg")
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            do{
                try? imageData?.write(to: url!)
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
    }
}
