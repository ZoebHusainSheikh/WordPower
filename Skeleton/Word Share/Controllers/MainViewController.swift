//
//  MainViewController.swift
//  Word Share
//
//  Created by Best Peers on 17/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

protocol MainViewControllerDelegate: class {
    func selected()
}

class MainViewController: UIViewController {
    var shareWord:String? = nil
    weak var delegate: MainViewControllerDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.DeckCell)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupShareWord()
        //view.addSubview(tableView)
    }
    
    private func setupShareWord(){
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeText = kUTTypeText as String
        
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText)
            {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    let text = results as! String
                    self.shareWord = text
                    self.performAPICall()
                })
            }
        }
    }
    
     func performAPICall(){}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.DeckCell, for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        cell.backgroundColor = .clear
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        delegate?.selected()
        
        
        
    }
}

private extension MainViewController {
    struct Identifiers {
        static let DeckCell = "deckCell"
    }
}
