//
//  CardPickerController.swift
//  Card Note
//
//  Created by Wei Wei on 7/15/21.
//  Copyright © 2021 WeiQiang. All rights reserved.
//

import Foundation
import UIKit


class CardPickerController:UIViewController{
    private var scrollView: UIScrollView!
    override func viewDidLoad() {
        
    }
    
    func loadCard(){
        let manager = FileManager.default
        var cardList:[Card] = [Card]()
        
        let url = Constant.Configuration.url.Card
        do{
            let array = try manager.contentsOfDirectory(atPath: url.path)
            for file in array{
                let fileUrl = url.appendingPathComponent(file)
                let dataRead = try Data.init(contentsOf: fileUrl)
                let card = NSKeyedUnarchiver.unarchiveObject(with: dataRead) as! Card
                cardList.append(card)
            }
        }catch{
            print("Failed to load file")
        }
        
        
        let sorted = cardList.sorted { (card1, card2) -> Bool in
                if card1.getTitle().compare(card2.getTitle()) == .orderedAscending{
                    return true
                }
            }
        
        var cumulatedY:CGFloat = 70
            for card in sorted{
                let cardView:CardView = CardView(card:card)
                cardView.frame.origin.y = CGFloat(cumulatedY)
                cumulatedY += cardView.bounds.height
                    + 30
                let tapGesture = UITapGestureRecognizer()
                tapGesture.addTarget(self, action: #selector(tapped))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardView.addGestureRecognizer(tapGesture)
                
                
                scrollView.addSubview(cardView)
                if cumulatedY > scrollView.contentSize.height{
                    scrollView.contentSize = CGSize(width: self.view.bounds.width, height: cumulatedY)
                }
            }
        
            scrollView.contentOffset.y = contentOffSetY
        

    }
    
    @objc func cardTapped() {
        
    }
}
