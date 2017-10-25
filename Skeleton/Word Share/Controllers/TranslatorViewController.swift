//
//  TranslatorViewController.swift
//  Word Share
//
//  Created by Best Peers on 25/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class TranslatorViewController: BaseContentViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var yandrexButton: UIButton!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordInfoType = .hindiTranslation
        NotificationCenter.default.addObserver(self, selector: #selector(TranslatorViewController.stopAnimation), name:NSNotification.Name("StopTranslatorAnimationIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TranslatorViewController.startAnimation), name:NSNotification.Name("StartTranslatorAnimationIdentifier"), object: nil)
        
        if BaseContentViewController.word.word != nil{
            showNoContentView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
