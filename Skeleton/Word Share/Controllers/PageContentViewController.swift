//
//  PageContentViewController.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class PageContentViewController: BaseContentViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PageContentViewController.stopAnimation), name:NSNotification.Name("DidFetchWordAPIIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PageContentViewController.startAnimation), name:NSNotification.Name("WillFetchWordAPIIdentifier"), object: nil)
        
        if BaseContentViewController.word.word != nil{
            tableView.reloadData()
            showNoContentView(isLoading: false)
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch wordInfoType {
        case .definitions:
            return BaseContentViewController.word.definitions.count
        case .synonyms:
            return BaseContentViewController.word.synonyms.count
        case .antonyms:
            return BaseContentViewController.word.antonyms.count
        case .examples:
            return BaseContentViewController.word.examples.count
        case .hindiTranslation:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (wordInfoType == .definitions) ? tableView.dequeueReusableCell(withIdentifier: "SubtitleCellIdentifier", for: indexPath) as! ContentTableViewCell : tableView.dequeueReusableCell(withIdentifier: "TitleCellIdentifier", for: indexPath) as! ContentTableViewCell
        switch wordInfoType {
        case .definitions:
            let dict = BaseContentViewController.word.definitions[indexPath.row]
            if let definition = dict["definition"]{
                
                var pos:String = ""
                if let partOfSpeech = dict["partOfSpeech"] as String?{
                    pos = partOfSpeech
                }
                cell.updateContent(title: definition, subtitle: pos, searchText: BaseContentViewController.word.word!)
            }
            
        case .synonyms:
            cell.updateContent(title: BaseContentViewController.word.synonyms[indexPath.row], searchText: BaseContentViewController.word.word!)
        case .antonyms:
            cell.updateContent(title: BaseContentViewController.word.antonyms[indexPath.row], searchText: BaseContentViewController.word.word!)
        case .examples:
            cell.updateContent(title: BaseContentViewController.word.examples[indexPath.row], searchText: BaseContentViewController.word.word!)
        case .hindiTranslation:
            cell.updateTranslationContent(title: (BaseContentViewController.word.hindiTranslation)!)
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
            self.tableView.reloadData()
            self.showNoContentView(isLoading:isLoading)
        }
    }
    
    private func showNoContentView(isLoading:Bool){
        if isLoading {
            noContentLabel.isHidden = true
        }
        else{
            switch wordInfoType {
            case .definitions:
                noContentLabel.isHidden = !BaseContentViewController.word.definitions.isEmpty
            case .synonyms:
                noContentLabel.isHidden = !BaseContentViewController.word.synonyms.isEmpty
            case .antonyms:
                noContentLabel.isHidden = !BaseContentViewController.word.antonyms.isEmpty
            case .examples:
                noContentLabel.isHidden = !BaseContentViewController.word.examples.isEmpty
            case .hindiTranslation:
                noContentLabel.isHidden = ((BaseContentViewController.word.hindiTranslation != nil))
            }
        }
        
        if !noContentLabel.isHidden{
            noContentLabel.text = "No \(wordInfoType.getString()) found for \"\(BaseContentViewController.word.word!)\""
        }
        
        tableView.isHidden = !noContentLabel.isHidden || isLoading
    }
}
