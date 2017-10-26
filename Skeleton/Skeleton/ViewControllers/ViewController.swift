//
//  ViewController.swift
// WordPower
//
//  Created by BestPeers on 31/05/17.
//  Copyright © 2017 BestPeers. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var yandrexButton: UIButton!
    
    var hindiTranslation:String?
    var langsInfo:Dictionary<String, String> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        performTranslationAPICall()
        tableView.reloadData()
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
        noContentLabel.isHidden = activityIndicator.isAnimating ? true : hindiTranslation != nil
        
        if !noContentLabel.isHidden{
            noContentLabel.text = "No translation found for " + textField.text!
        }
        
        textView.isHidden = !noContentLabel.isHidden || activityIndicator.isAnimating
        yandrexButton.isHidden = textView.isHidden
        if !textView.isHidden {
            textView.text = hindiTranslation
        }
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        performTranslationAPICall()
        self.textField.resignFirstResponder()
        return true
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
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func performTranslationAPICall(){
        if (textField.text?.count)! > 0 {
            startAnimation()
            RequestManager().getTranslationInformation(word: textField.text!) { (success, response) in
                print(response ?? Constants.kErrorMessage)
                // Notify translator controller
                DispatchQueue.main.async {
                    if let word = response as? String{
                        self.hindiTranslation = word
                    }
                    self.stopAnimation()
                }
            }
        }
    }

}

