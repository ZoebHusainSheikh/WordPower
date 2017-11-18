//
//  TranslatorViewController.swift
//  Word Share
//
//  Created by Best Peers on 25/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class TranslatorViewController: BaseContentViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var langsInfo:Dictionary<String, String> = [:]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordInfoType = .hindiTranslation
        langsInfo = Constants.getLanguagesInfo()
        if langsInfo.keys.count == 0 {
            NotificationCenter.default.post(name: Notification.Name("WillFetchLanguagesAPICallIdentifier"), object: nil)
            performGetLangsAPICall()
        }
        else
        {
            loadAnimation(isLoading: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if langsInfo.keys.count > 0 {
            if let rowIndex = Array(langsInfo.keys).index(of: Constants.getDefaultLanguageCode()) {
                self.tableView.scrollToRow(at: IndexPath(row: rowIndex, section: 0), at: .middle, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return langsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCellIdentifier", for: indexPath) as! ContentTableViewCell
        cell.titleLabel.text = Array(langsInfo.values)[indexPath.row]
        cell.accessoryType = Array(langsInfo.keys)[indexPath.row] == Constants.getDefaultLanguageCode() ? .checkmark : .disclosureIndicator
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        let value:String = Array(langsInfo.keys)[indexPath.row]
        Constants.setDefaultLanguageCode(language:value)
        tableView.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name("PerformTranslatorAPICallIdentifier"), object: nil)
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
            self.tableView.isHidden = isLoading
        }
    }
    
    // MARK: - IBActions

    @IBAction func yandrexButtonTapped(_ sender: Any) {
        let url = NSURL(string: "http://translate.yandex.com/")! as URL
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - API calls
    
    func performGetLangsAPICall(){
        startAnimation()
        RequestManager().getLangsList() { (success, response) in
            print(response ?? Constants.kErrorMessage)
            DispatchQueue.main.async {
                if let langsInfo = response as? Dictionary<String, String>{
                    self.langsInfo = langsInfo
                    Constants.setLanguagesInfo(languagesInfo: langsInfo)
                    self.tableView.reloadData()
                }
                self.stopAnimation()
                NotificationCenter.default.post(name: Notification.Name("DidFetchLanguagesAPICallIdentifier"), object: nil)
            }
        }
    }
}
