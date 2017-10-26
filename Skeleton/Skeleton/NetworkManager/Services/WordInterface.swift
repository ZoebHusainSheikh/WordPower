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
        RealAPI().getObject(request: request) { (success, response) in
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
            guard let translatedText = responseDict["text"] else {
                failureResponse()
                return
                
            }
            let responseList = translatedText as! Array<AnyObject>
            if responseDict.count > 0{
                interfaceBlock!(true, responseList[0] as? String)
                return
            }
            
            failureResponse()
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
