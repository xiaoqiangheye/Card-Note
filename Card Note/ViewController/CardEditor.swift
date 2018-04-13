//
//  CardEditor.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/4.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation
import UIKit

class CardEditor:UIViewController,UITextViewDelegate,UIScrollViewDelegate{
    var cardTitle: UITextView! = UITextView()
    var tag: UITextView! = UITextView()
    var definition: UITextView! = UITextView()
    var descriptions: UITextView! = UITextView()
    var scrollView:UIScrollView = UIScrollView()
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var addButton: UIButton!
    var color:UIColor = UIColor.red
    var card:Card?
    var type:CardEditor.type?
    var textMode:Constant.TextMode!
    var subCards:[CardView] = [CardView]()
    var examples:[CardView.ExaView] = [CardView.ExaView]()
    var addButtonStateisOpen:Bool = false
    var addSubCard:UIView = UIView()
    var addExa:UIView = UIView()
    var cardBackGround = UIView()
    var cumulatedheight:Int = 0
    var ifPaletteShowed:Bool = false
    private var EditingSubCard:[CardEditorView] = [CardEditorView]()
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
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray{
            textView.text = ""
            textView.textColor = .white
        }
       
       textView.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
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
    
    override func viewDidLoad() {
        cardTitle.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width*0.8, height: 50)
        cardTitle.font = UIFont.boldSystemFont(ofSize: 20)
        cardTitle.textColor = .white
        cardTitle.backgroundColor = .clear
        cardTitle.center.x = self.view.bounds.width/2
        cardTitle.layer.cornerRadius = 10
        cardTitle.textAlignment = .center
       
        
        tag.frame = CGRect(x: 0, y: 50, width: self.view.bounds.width*0.8, height: 30)
        tag.font = UIFont.systemFont(ofSize: 15)
        tag.textColor = .white
        tag.backgroundColor = .clear
        tag.center.x = self.view.bounds.width/2
        tag.layer.cornerRadius = 10
        let definitionLabel = UILabel()
        definitionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        definitionLabel.text = "Definition"
        definitionLabel.frame = CGRect(x:20, y: tag.frame.origin.y + tag.frame.height + 20, width: self.view.bounds.width, height: 20)
        definitionLabel.textColor = .white
        
        definition.frame = CGRect(x: 0, y: definitionLabel.frame.origin.y + definitionLabel.frame.height + 20, width: self.view.bounds.width*0.8, height: 100)
        definition.font = UIFont.systemFont(ofSize: 15)
        definition.textColor = .white
        definition.backgroundColor = .clear
        definition.center.x = self.view.bounds.width/2
        definition.layer.cornerRadius = 10
        definition.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
      
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        descriptionLabel.text = "Description"
        descriptionLabel.textColor = .white
        descriptionLabel.frame = CGRect(x: 20, y: definition.frame.origin.y + definition.frame.height + 20, width: self.view.bounds.width, height: 20)
        
        descriptions.frame = CGRect(x:0, y: descriptionLabel.frame.height + descriptionLabel.frame.origin.y + 20, width: self.view.bounds.width*0.8, height: 200)
        descriptions.font = .systemFont(ofSize:15)
        descriptions.textColor = .white
        descriptions.backgroundColor = .clear
        descriptions.center.x = self.view.bounds.width/2
        descriptions.layer.cornerRadius = 10
        descriptions.backgroundColor = UIColor(red: 54/255, green: 61/255, blue: 90/255, alpha: 0.2)
        
        cardBackGround.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height-20)
        cardBackGround.backgroundColor = color
        cardBackGround.addSubview(cardTitle)
        cardBackGround.addSubview(tag)
        cardBackGround.addSubview(definition)
        cardBackGround.addSubview(descriptions)
        cardBackGround.addSubview(definitionLabel)
        cardBackGround.addSubview(descriptionLabel)
        cardBackGround.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(showPalette))
        cardBackGround.addGestureRecognizer(tapGesture)
        
        
        scrollView.frame = CGRect(x: 0, y: 20, width: self.view.bounds.width, height: self.view.bounds.height-20)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.layer.cornerRadius = 15
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
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
    }
    
    enum type:String{
        case add = "add"
        case save = "save"
    }
    
    @objc func showPalette(_ sender:UIGestureRecognizer){
        self.view.endEditing(true)
        if !ifPaletteShowed{
        //let location = sender.location(in: cardBackGround)
        let location = sender.location(in: cardBackGround)
        let palette = Palette(frame: CGRect(x: location.x, y: location.y, width: 150, height: 150))
        palette.center = location
        var colors:[UIColor] = [UIColor]()
        colors.append(Constant.Color.西瓜红)
        colors.append(Constant.Color.水荡漾清猿啼)
        colors.append(Constant.Color.勿忘草色)
        colors.append(Constant.Color.江戸紫)
        colors.append(Constant.Color.花季色)
        palette.addColors(colors)
        palette.parentView = cardBackGround
        palette.viewController = self
        self.cardBackGround.addSubview(palette)
        ifPaletteShowed = true
        }else{
            for subView in cardBackGround.subviews{
                if subView.isKind(of: Palette.self){
                subView.removeFromSuperview()
                ifPaletteShowed = false
                }
            }
        }
    }
    
    func loadCard(card:Card){
        self.card = card
        cardTitle.text = card.getTitle()
        tag.text = card.getTag()
        definition.text = card.getDefinition()
        descriptions.text = card.getDescription()
        color = card.getColor()
        cardBackGround.backgroundColor = color
        
        var cumulatedHeight = descriptions.frame.origin.y + descriptions.frame.height + 20
        for example in card.getExamples(){
         let exaView = CardView.singleExampleView()
         exaView.textView.text = example
         exaView.example = example
         exaView.frame.origin.y = cumulatedHeight
         cumulatedHeight += exaView.frame.height + 20
         cardBackGround.addSubview(exaView)
         scrollView.contentSize.height += exaView.frame.height + 20
         cardBackGround.frame.size.height += exaView.frame.height + 20
        self.examples.append(exaView)
        }
        
        for card in card.getChilds(){
         let cardView = CardView.getSubCardView(card)
         cardView.frame.origin.y = cumulatedHeight
         cardView.layer.shadowOpacity = 0.5
         cardView.layer.shadowColor = UIColor.black.cgColor
         cardView.layer.shadowOffset = CGSize(width:1, height:1)
        let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.addTarget(self, action: #selector(performCardEditor))
            cardView.addGestureRecognizer(tapGesture)
         cumulatedHeight += cardView.frame.height + 20
         cardBackGround.addSubview(cardView)
         scrollView.contentSize.height += cardView.frame.height + 20
         cardBackGround.frame.size.height += cardView.frame.height + 20
         self.subCards.append(cardView)
        }
        
    }
    
    func reLoad(){
        descriptions.text = card?.getDescription()
        definition.text = card?.getDefinition()
        cardTitle.text = card?.getTitle()
        tag.text = card?.getTag()
        cardBackGround.backgroundColor = card?.getColor()
        
        for subview in cardBackGround.subviews{
            if subview.isKind(of: CardView.self) || subview.isKind(of: CardView.ExaView.self){
                subview.removeFromSuperview()
            }
        }
        
        var cumulatedHeight = descriptions.frame.origin.y + descriptions.frame.height + 20
        for example in examples{
            cardBackGround.addSubview(example)
            cardBackGround.frame.size.height += example.frame.height + 20
        }
        
        for card in subCards{
            cardBackGround.addSubview(card)
            cardBackGround.frame.size.height += card.frame.height + 20
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
                        
                        var examples:[String] = [String]()
                        for example in (last?.examples)!{
                            examples.append(example.textView.text)
                        }
                        last?.card?.setExamples(examples)
                        
                        var childs:[Card] = [Card]()
                        for child in (last?.subCards)!{
                            childs.append(child.card)
                        }
                        last?.card?.setChilds(childs)
                        EditingSubCard[EditingSubCard.count-2].subCards[index].card = EditingSubCard.last?.card!
                        EditingSubCard[EditingSubCard.count-2].subCards[index].label.text = last?.card?.getTitle()
                        EditingSubCard[EditingSubCard.count-2].subCards[index].labelofDes.text = last?.card?.getDefinition()
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
                    var examples:[String] = [String]()
                    for example in (last?.examples)!{
                        examples.append(example.textView.text)
                    }
                    last?.card?.setExamples(examples)
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
            var examples:[String] = [String]()
            for example in self.examples{
                examples.append(example.textView.text)
            }
            var subCards:[Card] = [Card]()
            if subCards.count >= 1{
            for subcard in self.subCards{
                subCards.append(subcard.card!)
            }
            }
            let card = Card(title: cardTitle.text, tag: tag.text, description: descriptions.text, id: UUID().uuidString, definition: definition.text, examples:examples, color: color)
            card.addChildNotes(subCards)
            
        let manager = FileManager.default
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
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
            var url = manager.urls(for: .documentDirectory, in:.userDomainMask).first
            url?.appendPathComponent("card.txt")
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
                    self.card?.setDefinition(definition.text)
                    self.card?.setDescription(descriptions.text)
                    self.card?.setTag(tag.text)
                    var childs = [Card]()
                    for card in subCards
                    {
                        childs.append(card.card)
                    }
                    var examples = [String]()
                    for example in self.examples{
                        examples.append(example.textView.text)
                    }
                    self.card?.setChilds(childs)
                    self.card?.setExamples(examples)
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
    
    @IBAction func addButton(_ sender: UIButton) {
        if !addButtonStateisOpen{
        addButtonStateisOpen = true
        addSubCard.isHidden = false
        addExa.isHidden = false
        addSubCard.layer.cornerRadius = 10
        addSubCard.frame = CGRect(x: sender.center.x, y: sender.center.y, width: 100, height: 50)
        addSubCard.backgroundColor = UIColor.orange
        let subCardLabel = UILabel(frame: CGRect(x:addSubCard.bounds.midX, y: addSubCard.bounds.midY, width: addSubCard.bounds.width, height: addSubCard.bounds.height))
        subCardLabel.center.x = addSubCard.bounds.width/2
        subCardLabel.center.y = addSubCard.bounds.height/2
        subCardLabel.textAlignment = .center
        subCardLabel.font = UIFont.systemFont(ofSize: 15)
        subCardLabel.textColor = .white
        subCardLabel.text = "Subcard"
        addSubCard.addSubview(subCardLabel)
        
        let subCardtapGesture = UITapGestureRecognizer()
        subCardtapGesture.numberOfTapsRequired = 1
        subCardtapGesture.numberOfTouchesRequired = 1
        subCardtapGesture.addTarget(self, action: #selector(addCard))
        addSubCard.addGestureRecognizer(subCardtapGesture)
        
       
        addExa.layer.cornerRadius = 10
        addExa.frame = CGRect(x: sender.center.x, y: sender.center.y, width: 100, height: 50)
        addExa.backgroundColor = .orange
        let exaLabel = UILabel(frame: CGRect(x:addExa.bounds.midX, y: addExa.bounds.midY, width: addExa.bounds.width, height: addExa.bounds.height))
        exaLabel.center.x = addExa.bounds.width/2
        exaLabel.center.y = addExa.bounds.height/2
        exaLabel.textAlignment = .center
        exaLabel.font = .systemFont(ofSize:15)
        exaLabel.textColor = .white
        exaLabel.text = "Eg."
        addExa.addSubview(exaLabel)
        
        let exaTapGesture = UITapGestureRecognizer()
        exaTapGesture.numberOfTapsRequired = 1
        exaTapGesture.numberOfTouchesRequired = 1
        exaTapGesture.addTarget(self, action: #selector(addExample))
        addExa.addGestureRecognizer(exaTapGesture)
        
        self.view.addSubview(addSubCard)
        self.view.addSubview(addExa)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.1)
        addExa.center.x = sender.center.x - 20
        addExa.center.y = sender.center.y - 75
        addSubCard.center.x = sender.center.x - 20
        addSubCard.center.y = sender.center.y - 150
        UIView.commitAnimations()
        }else if addButtonStateisOpen{
            addButtonStateisOpen = false
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.1)
            addExa.center.x = sender.center.x + 20
            addExa.center.y = sender.center.y + 75
            addSubCard.center.x = sender.center.x + 20
            addSubCard.center.y = sender.center.y + 150
            addExa.isHidden = true
            addSubCard.isHidden = true
            UIView.commitAnimations()
        }
    }
    
    
    
    @objc func addCard(){
        let card = Card(title: "title", tag: "", description: "", id: UUID().uuidString, definition: "", examples: [String](), color: color)
        let cardView = CardView.getSubCardView(card)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width:1, height:1)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.addTarget(self, action: #selector(performCardEditor))
        cardView.addGestureRecognizer(tapGesture)
        if examples.count < 1 && subCards.count < 1{
        cardView.frame.origin.y = CGFloat(cumulatedheight + 20)
        }else if examples.count >= 1 && subCards.count < 1{
            cardView.frame.origin.y = (examples.last?.frame.origin.y)! + (examples.last?.frame.height)! + 20
        }else if subCards.count >= 1{
            cardView.frame.origin.y = (subCards.last?.frame.origin.y)! + cardView.frame.height + 20
        }
        cumulatedheight += Int(20 + cardView.frame.size.height)
        cardBackGround.addSubview(cardView)
        scrollView.contentSize.height = cardView.frame.origin.y + cardView.frame.height
        + 20
        cardBackGround.frame.size.height = cardView.frame.origin.y + cardView.frame.height + 20
        subCards.append(cardView)
    }
    
    @objc func performCardEditor(_ sender:UITapGestureRecognizer){
    let card = (sender.view as! CardView).card
    let cardEditorView = CardEditorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        cardEditorView.loadCard(card!)
        self.scrollView.addSubview(cardEditorView)
        self.scrollView.contentSize = CGSize(width: cardEditorView.frame.width, height: cardEditorView.frame.height)
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
        var exaView = CardView.singleExampleView()
        if examples.count < 1{
        exaView.frame.origin.y = descriptions.frame.origin.y + descriptions.frame.height + 20
        exaView.textView.delegate = self
        self.cardBackGround.addSubview(exaView)
            examples.append(exaView)
        cardBackGround.frame.size.height += exaView.frame.height
        scrollView.contentSize.height += exaView.frame.height
        }else if examples.count >= 1{
            exaView.frame.origin.y = (examples.last?.frame.origin.y)! + exaView.frame.height + 20
        self.cardBackGround.addSubview(exaView)
            exaView.textView.delegate = self
            examples.append(exaView)
             cardBackGround.frame.size.height += exaView.frame.height
            scrollView.contentSize.height += exaView.frame.height
        }
        if subCards.count >= 1{
            for card in self.subCards{
                card.frame.origin.y += exaView.frame.height + 20
            }
        }
    }
}
