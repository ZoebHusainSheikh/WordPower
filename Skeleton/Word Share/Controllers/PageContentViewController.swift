//
//  PageContentViewController.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class PageContentViewController: MainViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var pageIndex: Int = 0
    var strTitle: String!
    var wordInfoType:WordInfoType = .definitions
    static var word:WordModel = WordModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = strTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func performAPICall(){
        guard isDataExist() else {
            PageContentViewController.word.word = shareWord
            let pageController:MainPageViewController = self.parent as! MainPageViewController
            pageController.navigationItem.title = shareWord
            RequestManager().getWordInformation(word: self.shareWord!, wordInfoType: wordInfoType) { (success, response) in
                print(response ?? Constants.kErrorMessage)
                if let word = response as! WordModel?{
                    switch self.wordInfoType {
                    case .definitions:
                        PageContentViewController.word.definitions = word.definitions
                    case .synonyms:
                        PageContentViewController.word.synonyms = word.synonyms
                    case .antonyms:
                        PageContentViewController.word.antonyms = word.antonyms
                    case .examples:
                        PageContentViewController.word.examples = word.examples
                    case .hindiTranslation:
                        PageContentViewController.word.hindiTranslation = word.hindiTranslation
                    }
                }
            }
            
            return
        }
    }
    
    // MARK: - Private Methods
    
    private func isDataExist() ->Bool{
        return true
        if PageContentViewController.word.word != shareWord{
            PageContentViewController.word = WordModel()
            return false
        }
        switch wordInfoType {
        case .definitions:
            return !(PageContentViewController.word.definitions.isEmpty)
        case .synonyms:
            return !(PageContentViewController.word.synonyms.isEmpty)
        case .antonyms:
            return !(PageContentViewController.word.antonyms.isEmpty)
        case .examples:
            return !(PageContentViewController.word.examples.isEmpty)
        case .hindiTranslation:
            return !(PageContentViewController.word.hindiTranslation.isEmpty)
        }
    }

}
