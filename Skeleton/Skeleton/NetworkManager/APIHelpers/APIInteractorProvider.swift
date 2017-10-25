//
//  APIInteractorProvider.swift
// WordPower
//
//  Created by BestPeers on 01/06/17.
//  Copyright © 2017 BestPeers. All rights reserved.
//

import UIKit

class APIInteractorProvider: NSObject {
    
    var shouldUseRealAPI: Bool = true
    
    static let sharedInstance = APIInteractorProvider()
    
    private override init() {
        super.init()
    }
    
    public func getAPIInetractor() -> APIInteractor {
        if shouldUseRealAPI {
            return RealAPI() as APIInteractor
        } else {
            return TestAPI() as APIInteractor
        }
    }
}
