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
    var word:WordModel? = nil
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
        setupUI()
        setupShareWord()
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
    
    private func performAPICall(){
        RequestManager().getWordInformation(word: self.shareWord!, wordInfoType: .definitions) { (success, response) in
            print(response ?? Constants.kErrorMessage)
            if let word = response as! WordModel?{
                self.word = word
            }
        }
    }
    
    @objc func saveButtonTapped(sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.cancelRequest(withError: NSError())
        })
    }
    
    func hideExtensionWithCompletionHandler(completion:@escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.20, animations: {
            
            self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
        }, completion: completion)
    }
    private func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Word Power"
        navigationController?.navigationBar.backgroundColor = UIColor.red//(red:0.97, green:0.44, blue:0.12, alpha:1.00)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MainViewController.saveButtonTapped(sender:)))
        view.addSubview(tableView)
    }

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
