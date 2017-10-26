//
//  CategoryInterface.swift
// WordPower
//
//  Created by BestPeers on 05/06/17.
//  Copyright © 2017 BestPeers. All rights reserved.
//

import UIKit

class WordInterface: Interface {
    
    public func getWordInformation(request: WordRequest, completion: @escaping CompletionHandler) {
        interfaceBlock = completion
        
        NetworkAPIClient().getObject(request: request) { (success, response) in
            self.parseSuccessResponse(request:request, response:response as AnyObject)
        }
    }
    
    public func getTranslationInformation(request: WordRequest, completion: @escaping CompletionHandler) {
        interfaceBlock = completion
        
        NetworkAPIClient().getTranslationObject(request: request) { (success, response) in
            self.parseSuccessResponse(request:request, response:response as AnyObject)
        }
    }
    
    public func getTranslationLangs(request: WordRequest, completion: @escaping CompletionHandler) {
        interfaceBlock = completion
        
        NetworkAPIClient().getLangsTranslationObject(request: request) { (success, response) in
            self.parseGetLangsSuccessResponse(request:request, response:response as AnyObject)
        }
    }

    // MARK: Parse Response
    
    func parseSuccessResponse(request:WordRequest, response: AnyObject?) -> Void {
        if validateResponse(response: response!){
            let responseDict = response as! Dictionary<String, Any>
            guard let wordItem = responseDict["word"] as? String else {
                
                guard let translatedText = responseDict["text"] else {
                    failureResponse()
                    return
                    
                }
                let responseList = translatedText as! Array<AnyObject>
                if responseDict.count > 0{
                    let word:WordModel = WordModel()
                    word.word = request.urlPath
                    word.hindiTranslation = responseList[0] as? String
                    interfaceBlock!(true, word)
                    return
                }
                
                failureResponse()
                return
            }
            
            let word:WordModel = WordModel()
            word.word = wordItem
            //TODO: Use ObjectMapper for parsing
            let results = responseDict["results"] as? Array<Dictionary<String, AnyObject>>
            if results != nil{
                for itemInfo in results!{
                    let definition:String? = itemInfo["definition"] as? String
                    let partOfSpeech:String? = itemInfo["partOfSpeech"] as? String
                    if definition != nil && partOfSpeech != nil{
                        word.definitions.append(["definition": definition!, "partOfSpeech": partOfSpeech!])
                    }
                    
                    let synonyms:Array<String>? = itemInfo["synonyms"] as? Array<String>
                    if synonyms != nil{
                        for synonymsItem in synonyms!{
                            if word.synonyms.index(of: synonymsItem) == nil{
                                word.synonyms.append(synonymsItem)
                            }
                        }
                    }
                    
                    let antonyms:Array<String>? = itemInfo["antonyms"] as? Array<String>
                    if antonyms != nil{
                        for antonymsItem in antonyms!{
                            if word.antonyms.index(of: antonymsItem) == nil{
                                word.antonyms.append(antonymsItem)
                                
                            }
                        }
                    }
                    
                    let examples:Array<String>? = itemInfo["examples"] as? Array<String>
                    if examples != nil{
                        for examplesItem in examples!{
                            if word.examples.index(of: examplesItem) == nil{
                                word.examples.append(examplesItem)
                                
                            }
                        }
                    }
                }
            }
            
            interfaceBlock!(true, word)
        }
    }
    
    func parseGetLangsSuccessResponse(request:WordRequest, response: AnyObject?) -> Void {
        if validateResponse(response: response!){
            let responseDict = response as! Dictionary<String, Any>
            guard let langs = responseDict["langs"] as? Dictionary<String,String> else {
                failureResponse()
                return
            }
            
            interfaceBlock!(true, langs)
        }
    }
}
