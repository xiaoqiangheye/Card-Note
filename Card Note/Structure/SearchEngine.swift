//
//  SearchEngine.swift
//  Card Note
//
//  Created by 强巍 on 2018/4/13.
//  Copyright © 2018年 WeiQiang. All rights reserved.
//

import Foundation



class SearchEngine{
    
    
    class func keyWordsParser(){
    
    }
    
    class func loadCards(cards:[Card],keyWords:[String])->[Card]{
            var cardList = cards
            var parsedCardlist = [Card]()
            for card in cardList{
                for keyword in keyWords{
                    if card.getDescription().lowercased().contains(keyword) || card.getDefinition().lowercased().contains(keyword) || card.getTitle().lowercased().contains(keyword) || card.getTag().contains(keyword){
                        parsedCardlist.append(card)
                    }else{
                       var locationCard = card
                       if locationCard.ifHasChild(){
                            if loadCards(cards: locationCard.getChilds(), keyWords: keyWords).count > 0{
                                parsedCardlist.append(locationCard)
                                break
                            }
                        }
                    }
            }
        }
        return parsedCardlist
    }
}
