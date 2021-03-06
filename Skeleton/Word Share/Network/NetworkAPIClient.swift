 //
//  NetworkAPIClient.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class NetworkAPIClient: NSObject {
    
    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        request.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json as AnyObject)
                } else {
                    completion(false, json as AnyObject)
                }
            }
            }.resume()
    }
    
    private func post(request: NSMutableURLRequest?, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request!, method: "POST", completion: completion)
    }
    
    private func put(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "PUT", completion: completion)
    }
    
    private func get(request: NSMutableURLRequest?, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        if request != nil{
            dataTask(request: request!, method: "GET", completion: completion)
        }
        else
        {
            completion(false, Constants.kErrorMessage as AnyObject)
        }
    }
    
    private func clientURLRequest(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest? {
        if let url:URL = URL(string: path) {
            let request = NSMutableURLRequest(url: url)
            request.setValue("gffsVZi52omsh52gxrT335Shh8aNp128WjajsnahxEMl6530yo", forHTTPHeaderField: "X-Mashape-Key")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            return request
        }
        return nil
    }
    
    private func translationClientURLRequest(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest? {
        if let url:URL = URL(string: path) {
            let request = NSMutableURLRequest(url: url)
            request.setValue("*/*", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            if params != nil && (params?.count)! > 0{
                request.setValue("17", forHTTPHeaderField: "Content-Length")
                
                var paramString = ""
                for (key, value) in params! {
                    let escapedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    paramString += "\(escapedKey)=\(escapedValue)&"
                }
                request.httpBody = paramString.data(using: String.Encoding.utf8)
            }
            
            
            return request
        }
        return nil
    }
    
    func getObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        get(request: clientURLRequest(path: request.urlPath, params:request.parameters), completion: completion)
    }
    
    func getTranslationObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        post(request: translationClientURLRequest(path: request.urlPath, params:request.parameters), completion: completion)
    }
    
    func getLangsTranslationObject(request: Request, completion: @escaping CompletionHandler) -> Void {
        get(request: translationClientURLRequest(path: request.urlPath), completion: completion)
    }
}
