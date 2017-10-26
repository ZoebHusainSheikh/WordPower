//
//  TranslatorViewController.swift
//  Word Share
//
//  Created by Best Peers on 25/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class TranslatorViewController: BaseContentViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var yandrexButton: UIButton!
    
    var langsInfo:Dictionary<String, String> = [:]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordInfoType = .hindiTranslation
        NotificationCenter.default.addObserver(self, selector: #selector(TranslatorViewController.stopAnimation), name:NSNotification.Name("StopTranslatorAnimationIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TranslatorViewController.startAnimation), name:NSNotification.Name("StartTranslatorAnimationIdentifier"), object: nil)
        
        if BaseContentViewController.word.word != nil{
            showNoContentView()
        }
        
        performGetLangsAPICall()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Change your default language"
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
            isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            self.showNoContentView()
        }
    }
    
    private func showNoContentView(){
        noContentLabel.isHidden = activityIndicator.isAnimating ? true : (BaseContentViewController.word.hindiTranslation != nil)
        
        if !noContentLabel.isHidden{
            noContentLabel.text = "No \(wordInfoType.getString()) found for \(BaseContentViewController.word.word!)"
        }
        
        textView.isHidden = !noContentLabel.isHidden || activityIndicator.isAnimating
        yandrexButton.isHidden = textView.isHidden
        if !textView.isHidden {
            textView.text = BaseContentViewController.word.hindiTranslation
        }
    }
    
    // MARK: - IBActions

    @IBAction func yandrexButtonTapped(_ sender: Any) {
        let url = NSURL(string: "http://translate.yandex.com/")! as URL
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - API calls
    
    func performGetLangsAPICall(){
        activityIndicator.startAnimating()
        RequestManager().getLangsList() { (success, response) in
            print(response ?? Constants.kErrorMessage)
            DispatchQueue.main.async {
                if let langsInfo = response as? Dictionary<String, String>{
                    self.langsInfo = langsInfo
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}
