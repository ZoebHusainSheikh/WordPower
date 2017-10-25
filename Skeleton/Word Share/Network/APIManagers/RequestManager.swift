//
//  RequestManager.swift
// WordPower
//
//  Created by BestPeers on 05/06/17.
//  Copyright © 2017 BestPeers. All rights reserved.
//

import UIKit

class RequestManager: NSObject {
    
    // MARK: - Word API
    func getWordInformation(word:String, completion:@escaping CompletionHandler){
        WordInterface().getWordInformation(request: WordRequest().initWordRequest(word: word), completion: completion)
    }
    
    // MARK: - Traslation API
    func getTranslationInformation(word:String, completion:@escaping CompletionHandler){
        WordInterface().getTranslationInformation(request: WordRequest().initWordRequest(word: word), completion: completion)
    }
}
