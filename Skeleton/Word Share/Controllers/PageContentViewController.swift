//
//  PageContentViewController.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var pageIndex: Int = 0
    var strTitle: String!
    var wordInfoType:WordInfoType = .definitions
    static var word:WordModel = WordModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageContentViewController.stopAnimation), name:NSNotification.Name("StopAnimationIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PageContentViewController.startAnimation), name:NSNotification.Name("StartAnimationIdentifier"), object: nil)
        
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "TitleCellIdentifier")
        tableView.register(ContentTableViewCell.self, forCellReuseIdentifier: "SubtitleCellIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func stopAnimation(){
        loadAnimation(isLoading: false)
    }
    
    @objc func startAnimation(){
        loadAnimation()
    }
    
    func loadAnimation(isLoading:Bool = true){
        DispatchQueue.main.async {
            isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch wordInfoType {
        case .definitions:
            return PageContentViewController.word.definitions.count
        case .synonyms:
            return PageContentViewController.word.synonyms.count
        case .antonyms:
            return PageContentViewController.word.antonyms.count
        case .examples:
            return PageContentViewController.word.examples.count
        case .hindiTranslation:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (wordInfoType == .definitions) ? tableView.dequeueReusableCell(withIdentifier: "SubtitleCellIdentifier", for: indexPath) : tableView.dequeueReusableCell(withIdentifier: "TitleCellIdentifier", for: indexPath)
        return cell
        let titleLabel:UILabel = cell.contentView.viewWithTag(100) as! UILabel
        
        switch wordInfoType {
        case .definitions:
            let subtitleLabel:UILabel = cell.contentView.viewWithTag(101) as! UILabel
            let dict = PageContentViewController.word.definitions[indexPath.row]
            if let definition = dict["definition"]{
                titleLabel.text = definition
            }
            if let partOfSpeech = dict["partOfSpeech"]{
                subtitleLabel.text = partOfSpeech
            }
            
        case .synonyms:
            titleLabel.text = PageContentViewController.word.synonyms[indexPath.row]
        case .antonyms:
            titleLabel.text = PageContentViewController.word.antonyms[indexPath.row]
        case .examples:
            titleLabel.text = PageContentViewController.word.examples[indexPath.row]
        case .hindiTranslation:
            titleLabel.text = PageContentViewController.word.hindiTranslation
        }
        
        return cell
    }
    /*private func isDataExist() ->Bool{
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
    }*/

}
