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
    @IBOutlet weak var noContentLabel: UILabel!
    var pageIndex: Int = 0
    var strTitle: String!
    var wordInfoType:WordInfoType = .definitions
    static var word:WordModel = WordModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageContentViewController.stopAnimation), name:NSNotification.Name("StopAnimationIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PageContentViewController.startAnimation), name:NSNotification.Name("StartAnimationIdentifier"), object: nil)
        
        if PageContentViewController.word.word != nil{
            tableView.reloadData()
            showNoContentView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource Methods
    
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
        let cell = (wordInfoType == .definitions) ? tableView.dequeueReusableCell(withIdentifier: "SubtitleCellIdentifier", for: indexPath) as! ContentTableViewCell : tableView.dequeueReusableCell(withIdentifier: "TitleCellIdentifier", for: indexPath) as! ContentTableViewCell
        switch wordInfoType {
        case .definitions:
            let dict = PageContentViewController.word.definitions[indexPath.row]
            if let definition = dict["definition"]{
                
                var pos:String = ""
                if let partOfSpeech = dict["partOfSpeech"] as String?{
                    pos = partOfSpeech
                }
                cell.updateContent(title: definition, subtitle: pos, searchText: PageContentViewController.word.word!)
            }
            
        case .synonyms:
            cell.updateContent(title: PageContentViewController.word.synonyms[indexPath.row], searchText: PageContentViewController.word.word!)
        case .antonyms:
            cell.updateContent(title: PageContentViewController.word.antonyms[indexPath.row], searchText: PageContentViewController.word.word!)
        case .examples:
            cell.updateContent(title: PageContentViewController.word.examples[indexPath.row], searchText: PageContentViewController.word.word!)
        case .hindiTranslation:
            cell.updateContent(title: (PageContentViewController.word.hindiTranslation)!, searchText: PageContentViewController.word.word!)
        }
        
        return cell
    }
    
    // MARK: - Private Methods
    
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
            self.showNoContentView()
        }
    }
    
    private func showNoContentView(){
        if activityIndicator.isAnimating{
            noContentLabel.isHidden = true
        }
        else{
            switch wordInfoType {
            case .definitions:
                noContentLabel.isHidden = !PageContentViewController.word.definitions.isEmpty
            case .synonyms:
                noContentLabel.isHidden = !PageContentViewController.word.synonyms.isEmpty
            case .antonyms:
                noContentLabel.isHidden = !PageContentViewController.word.antonyms.isEmpty
            case .examples:
                noContentLabel.isHidden = !PageContentViewController.word.examples.isEmpty
            case .hindiTranslation:
                noContentLabel.isHidden = !(PageContentViewController.word.hindiTranslation?.isEmpty)!
            }
        }
        
        if !noContentLabel.isHidden{
            noContentLabel.text = "No \(wordInfoType.getString()) found for \(PageContentViewController.word.word!)"
        }
        
        tableView.isHidden = !noContentLabel.isHidden || activityIndicator.isAnimating
    }
}
