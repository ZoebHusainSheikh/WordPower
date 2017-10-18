//
//  RequestManager.swift
//  Skeleton
//
//  Created by BestPeers on 05/06/17.
//  Copyright © 2017 BestPeers. All rights reserved.
//

import UIKit

class RequestManager: NSObject {
    
    //MARK: Word API 
    func getWordInformation(word:String, wordInfoType:WordInfoType, completion:@escaping CompletionHandler){
        WordInterface().getWordInformation(request: WordRequest().initWordRequest(word: word, wordInfoType: wordInfoType), completion: completion)
    }
}
