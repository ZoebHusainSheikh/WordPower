//
//  ViewController.swift
// WordPower
//
//  Created by BestPeers on 31/05/17.
//  Copyright © 2017 BestPeers. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SFSpeechRecognizerDelegate {
    
    var speechButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var translationContainerView: UIView!
    @IBOutlet weak var wordContainerView: UIView!
    @IBOutlet weak var noContentContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: Translation variables
    var hindiTranslation:String?
    var langsInfo:Dictionary<String, String> = [:]
    
    // MARK: Speech Recognition Variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    var request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var timer:Timer?
    var micTimer:Timer?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        
        textField.resignFirstResponder()
        let value:String = Array(langsInfo.keys)[indexPath.row]
        Constants.setDefaultLanguageCode(language:value)
        showPageView(state: false)
        performTranslationAPICall()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func initialSetup() {
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        navigationController?.navigationBar.barTintColor = UIColor.black
        leftBarButton()
        rightBarButton()
        langsInfo = Constants.getLanguagesInfo()
        if langsInfo.keys.count == 0 {
            self.tableView.isHidden = true
            performGetLangsAPICall()
        }
        self.requestSpeechAuthorization()
    }
    
    private func showPageView(state:Bool = true) {
        
        UIView.transition(with: view,
                          duration:0.5,
                          options: .curveLinear,
                          animations: {
                            self.wordContainerView.isHidden = !state
                            self.closeButton.isHidden = !state
                            self.translationContainerView.isHidden = state
        },
                          completion: nil)
        
    }
    
    private func loadAnimation(isLoading:Bool = true){
        DispatchQueue.main.async {
            isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            self.showNoContentView()
        }
    }
    
    private func showNoContentView(){
        noContentLabel.isHidden = activityIndicator.isAnimating ? true : hindiTranslation != nil
        
        if !noContentLabel.isHidden{
            noContentLabel.text = "No translation found for \"\(textField.text!)\""
        }
        
        textView.isHidden = !noContentLabel.isHidden || activityIndicator.isAnimating
        if !textView.isHidden {
            textView.text = hindiTranslation
        }
        
        noContentContainerView.isHidden = !textView.isHidden
    }
    
    private func startTimer(){
        stopTimer();
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(performTranslationAPICall), userInfo: nil, repeats: false)
    }
    
    private func stopTimer(){
        if (timer != nil)
        {
            timer?.invalidate()
            self.timer = nil;
        }
    }
    
    private func startMicTimer(){
        stopMicTimer();
        micTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(finishSpeechRecognition), userInfo: nil, repeats: false)
    }
    
    private func stopMicTimer(){
        if (micTimer != nil)
        {
            micTimer?.invalidate()
            self.micTimer = nil;
        }
    }
    
    private func recordAndRecognizeSpeech(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.textField.text = bestString
                
                //perform API call after few sec
                self.startTimer()
                
            } else if let error = error {
                print(error)
            }
        })
    }
    
    private func cancelRecording() {
        DispatchQueue.main.async {
            if(self.audioEngine.isRunning){
                let node = self.audioEngine.inputNode
                node.removeTap(onBus: 0)
                node.reset()
                self.audioEngine.stop()
                self.request.endAudio()
                self.recognitionTask?.cancel()
                self.recognitionTask = nil;
                self.request = SFSpeechAudioBufferRecognitionRequest()
            }
        }
    }
    
    private func leftBarButton(){
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "language_icon"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(ViewController.languageButtonTapped(sender:)), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 32)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    private func rightBarButton(){
        speechButton = UIButton.init(type: .custom)
        speechButton.setImage(UIImage.init(named: "mic_off"), for: UIControlState.normal)
        speechButton.setImage(UIImage.init(named: "mic_on"), for: UIControlState.selected)
        speechButton.addTarget(self, action:#selector(ViewController.speechButtonTapped(sender:)), for:.touchUpInside)
        speechButton.frame = CGRect.init(x: 0, y: 0, width: 24, height: 36)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: speechButton)
    }
    
    private func beginSpeechRecognition() {
        print("begin")
        if !self.speechButton.isSelected {
            self.recordAndRecognizeSpeech()
            speechButton.isSelected = true
            startMicTimer()
        }
    }
    
    @objc private func finishSpeechRecognition() {
        print("released")
        if self.speechButton.isSelected {
            cancelRecording()
            speechButton.isSelected = false
            stopMicTimer()
        }
    }
    
    //MARK: - Alert
    
    private func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Check Authorization Status
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.speechButton.isEnabled = true
                case .denied:
                    self.speechButton.isEnabled = false
                    self.textField.text = "User denied access to speech recognition"
                case .restricted:
                    self.speechButton.isEnabled = false
                    self.textField.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.speechButton.isEnabled = false
                    self.textField.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showPageView(state: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        performTranslationAPICall()
        self.textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool{
        finishSpeechRecognition()
        return true
    }
    
    // MARK: - IBActions Methods
    @IBAction func closePagesButtonTapped(_ sender: Any) {
        showPageView(state: false)
    }
    
    @objc func languageButtonTapped(sender: UIBarButtonItem) {
        if self.wordContainerView.isHidden {
            textField.resignFirstResponder()
            showPageView()
            if langsInfo.keys.count > 0 {
                if let rowIndex = Array(langsInfo.keys).index(of: Constants.getDefaultLanguageCode()) {
                    self.tableView.scrollToRow(at: IndexPath(row: rowIndex, section: 0), at: .middle, animated: true)
                }
            }
        }
        else{
            showPageView(state: false)
        }
    }
    
    @objc func speechButtonTapped(sender: UIBarButtonItem?) {
        if self.speechButton.isSelected {
            finishSpeechRecognition()
        }
        else {
            beginSpeechRecognition()
        }
    }
    
    // MARK: - API calls
    
    private func performGetLangsAPICall(){
        activityIndicator.startAnimating()
        RequestManager().getLangsList() { (success, response) in
            print(response ?? Constants.kErrorMessage)
            DispatchQueue.main.async {
                if let langsInfo = response as? Dictionary<String, String>{
                    self.langsInfo = langsInfo
                    Constants.setLanguagesInfo(languagesInfo: langsInfo)
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc func performTranslationAPICall(){
        if (textField.text?.count)! > 0 {
            loadAnimation()
            RequestManager().getTranslationInformation(word: textField.text!) { (success, response) in
                print(response ?? Constants.kErrorMessage)
                // Notify translator controller
                DispatchQueue.main.async {
                    if let word = response as? String{
                        self.hindiTranslation = word
                    }
                    self.loadAnimation(isLoading: false)
                }
            }
        }
    }
    
    // MARK: - Observer Methods
    
    // Force the text in a UITextView to always center itself.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
}

