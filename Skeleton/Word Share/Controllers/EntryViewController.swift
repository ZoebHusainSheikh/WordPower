//
//  EntryViewController.swift
//  ShareByMail
//
//  Created by Martin Normark on 06/02/15.
//  Copyright (c) 2015 Martin Normark. All rights reserved.
//

import UIKit

@objc(EntryViewController)

class EntryViewController : UINavigationController {
    
     init() {
        let viewController:UIViewController = UIStoryboard(name: "MainInterface", bundle: nil).instantiateViewController(withIdentifier: "MainPageViewController") as UIViewController
        super.init(rootViewController: viewController)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }
}

//TODO: Resolve 1st time nothing happen issue
//TODO: Resolve warnings
//TODO: Resolve Orientation issue
// Voice recognition
