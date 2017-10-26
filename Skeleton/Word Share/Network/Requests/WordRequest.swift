//
//  WordRequest.swift
// WordPower
//
//  Created by Best Peers on 16/10/17.
//  Copyright © 2017 www.BestPeers.Skeleton. All rights reserved.
//

import UIKit

class WordRequest: Request {
    
    func initWordRequest(word:String) -> WordRequest{
        let path:String = "https://wordsapiv1.p.mashape.com/words/"+word
        urlPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return self
    }
    
    func initTranslatorRequest(word:String) -> WordRequest{
        let path:String = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20171024T105142Z.903b3e1c791c4cd5.3de81202f9dda907aab4dafbe86006f16141a764&lang=\(Constants.getDefaultLanguageCode())"
        urlPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        parameters = ["text":word as AnyObject]
        return self
    }
    
    func initGetLangsRequest() -> WordRequest{
        let path:String = "https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=trnsl.1.1.20171024T105142Z.903b3e1c791c4cd5.3de81202f9dda907aab4dafbe86006f16141a764&ui=\(Constants.getDefaultLanguageCode())"
        urlPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return self
    }

}
