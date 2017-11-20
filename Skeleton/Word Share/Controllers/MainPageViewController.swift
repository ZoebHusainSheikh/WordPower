//
//  MainPageViewController.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import AVFoundation
import MapKit

class MainPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var waterImageView: UIImageView!
    @IBOutlet weak var translationContainerView: UIView!
    @IBOutlet weak var wordContainerView: UIView!
    @IBOutlet weak var noContentContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var translationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    var pageControlViewController:UIPageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var viewControllerList:[UIViewController] = []
    var selectedPageIndex:Int? = nil
    var shareWord:String? = nil
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var arrPageTitle: NSArray = ["Definitions", "Synonyms", "Antonyms", "Examples"]
    var tempLongitude: Double = -122.02962
    var tempLatitude: Double = 37.332077
    
    private lazy var pageControllerView: UIView = {
        for index in 0...arrPageTitle.count {
            viewControllerList.append(getViewControllerAtIndex(index: index))
        }
        
        pageControlViewController.dataSource = self
        pageControlViewController.delegate = self
        pageControlViewController.setViewControllers([viewControllerList[0]] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        let pageControllerView = pageControlViewController.view!
        pageControllerView.backgroundColor = UIColor.clear
        
        return pageControllerView
    }()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    
    private func initialSetup() {
        textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPageViewController.showAnimation), name:NSNotification.Name("WillFetchLanguagesAPICallIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPageViewController.hideAnimation), name:NSNotification.Name("DidFetchLanguagesAPICallIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPageViewController.performTranslationAPICall), name:NSNotification.Name("PerformTranslatorAPICallIdentifier"), object: nil)
        BaseContentViewController.word = WordModel()
        setupUI()
        setupShareWord()
    }
    
    private func setupUI() {
        setupPageVC()
//        getMapImage(increment: 0.0)
        self.navigationItem.title = "Word Power"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.black
        
        leftBarButton()
        rightBarButton()
    }
    
    private func applyPageConstraints() {
        pageControllerView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let leadingContraints = NSLayoutConstraint(item: pageControllerView, attribute:
            .leadingMargin, relatedBy: .equal, toItem: guide,
                            attribute: .leadingMargin, multiplier: 1.0,
                            constant: 20)
        let trailingContraints = NSLayoutConstraint(item: pageControllerView, attribute:
            .trailingMargin, relatedBy: .equal, toItem: guide,
                             attribute: .trailingMargin, multiplier: 1.0, constant: -20)
        let topConstraints = NSLayoutConstraint(item: pageControllerView, attribute: .top, relatedBy: .equal,
                                                toItem: guide, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomConstraints = NSLayoutConstraint(item: pageControllerView, attribute: .bottom, relatedBy: .equal,
                                                   toItem: guide, attribute: .bottom, multiplier: 1.0, constant: -40)
        
        NSLayoutConstraint.activate([leadingContraints, trailingContraints,topConstraints, bottomConstraints])
    }
    
    private func setupPageVC(){
        view.addSubview(pageControllerView)
        applyPageConstraints()
        pageControllerView.isHidden = true
        view.bringSubview(toFront: closeButton)
        view.bringSubview(toFront: translationButton)
    }
    
    private func leftBarButton(){
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "speaker"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(MainPageViewController.speakerButtonTapped(sender:)), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 32, height: 32)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    private func rightBarButton(){
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "done"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(MainPageViewController.saveButtonTapped(sender:)), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 36)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupShareWord(){
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeText = kUTTypeText as String
        
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText)
            {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    let text = results as! String
                    if self.validateStringIsNotUrl(urlString: text){
                        self.shareWord = text
                        self.navigationItem.title = text
                        self.performTranslationAPICall()
                    }
                    else{
                        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                })
            }
        }
    }
    
    func showPageView(state:Bool = true) {
        
        UIView.transition(with: view,
                          duration:0.5,
                          options: .curveLinear,
                          animations: {
                            self.wordContainerView.isHidden = !state
                            self.pageControllerView.isHidden = !state
                            self.closeButton.isHidden = !state
                            self.translationContainerView.isHidden = state
        },
                          completion: nil)
        
    }
    
    func loadAnimation(isLoading:Bool = true){
        DispatchQueue.main.async {
            isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            self.showNoContentView()
        }
    }
    
    @objc func showAnimation(){
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    @objc func hideAnimation(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func showNoContentView(){
        noContentContainerView.isHidden = activityIndicator.isAnimating ? true : (BaseContentViewController.word.hindiTranslation != nil)
        
        if !noContentContainerView.isHidden{
            noContentLabel.text = "No translation found for \"\(shareWord!)\""
        }
    }
    
    func validateStringIsNotUrl (urlString: String) -> Bool {
        if let url:URL = URL(string: urlString){
            if (url.scheme != nil) && (url.host != nil){
                return false
            }
        }
        return true
    }
    
    func clearCollectionViewSelection(){
        for cell in collectionView.visibleCells {
            let wordCollectionViewCell = cell as! WordCollectionViewCell
            let isSelectedCell:Bool = (wordCollectionViewCell.index == selectedPageIndex)
            wordCollectionViewCell.textLabel.font = UIFont(name: wordCollectionViewCell.textLabel.font.fontName, size:  isSelectedCell ? 22 : 16)
        }
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> BaseContentViewController{
        // Create a new view controller and pass suitable data.
        var pageContentViewController:BaseContentViewController!
        if index == (arrPageTitle.count){
            pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "TranslatorViewController") as! BaseContentViewController
        }
        else{
            pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! BaseContentViewController
        }
        
        pageContentViewController.pageIndex = index
        pageContentViewController.wordInfoType = index == 0 ? .definitions : index == 1 ? .synonyms : index == 2 ? .antonyms : index == 3 ? .examples : .hindiTranslation
        return pageContentViewController
    }
    
    func selectPageAtIndex(index:Int, isAnimated:Bool = false)
    {
        if index < viewControllerList.count{
            if selectedPageIndex == nil {
                selectedPageIndex = 0
            }
            let page = viewControllerList[index]
            weak var pvcw = pageControlViewController
            pageControlViewController.setViewControllers([page], direction: (selectedPageIndex! < index ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse), animated: isAnimated) { _ in
                if let pvcs = pvcw {
                    DispatchQueue.main.async{
                        pvcs.setViewControllers([page], direction: (self.selectedPageIndex! < index ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse), animated: false, completion: nil)
                    }
                }
            }
            changeWaterImage(index: index)
        }
    }
    
    func changeWaterImage(index:Int) {
        var image: UIImage?
        switch index {
        case 0:
            image = UIImage(named: "definitions_messagebox")
        case 1:
            image = UIImage(named: "synonyms_messagebox")
        case 2:
            image = UIImage(named: "antonyms_messagebox")
        case 3:
            image = UIImage(named: "examples_messagebox")
        default:
            image = UIImage(named: "change_language_messagebox")
        }
        
        UIView.transition(with: waterImageView,
                          duration:0.5,
                          options: .curveLinear,
                          animations: { self.waterImageView.image = image },
                          completion: nil)
    }
    
    func getMapImage(increment: Double){
        tempLongitude += increment
        tempLatitude += increment/2
        let mapSnapshotOptions = MKMapSnapshotOptions()
        
        // Set the region of the map that is rendered.
        let location = CLLocationCoordinate2DMake(tempLatitude, tempLongitude) // Apple HQ
        let region = MKCoordinateRegionMakeWithDistance(location, 1500000, 1500000)
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start { (snapshot:MKMapSnapshot?, error:Error?) in
            
            let image = snapshot?.image
            DispatchQueue.main.async {
                
                UIView.transition(with: self.backgroundImageView,
                                  duration:0.5,
                                  options: .curveLinear,
                                  animations: { self.backgroundImageView.image = image },
                                  completion: nil)
                
                self.getMapImage(increment: 0.100000)
            }
        }
    }
    
    func hideExtensionWithCompletionHandler(completion:@escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.20, animations: {
            
            self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
        }, completion: completion)
    }
    
    // MARK: - API Calls Methods
    
    func performAPICall(){
        NotificationCenter.default.post(name: Notification.Name("WillFetchWordAPIIdentifier"), object: nil)
        BaseContentViewController.word.word = shareWord
        RequestManager().getWordInformation(word: self.shareWord!) { (success, response) in
            print(response ?? Constants.kErrorMessage)
            // Notify page content controllers
            DispatchQueue.main.async {
                if let word = response as? WordModel{
                    BaseContentViewController.word = word
                }
                
                UIView.transition(with: self.collectionView,
                                  duration:0.5,
                                  options: .curveLinear,
                                  animations: { self.collectionView.isHidden = false
                                    self.translationButton.isHidden = false
                },
                                  completion: nil)
                
                
                NotificationCenter.default.post(name: Notification.Name("DidFetchWordAPIIdentifier"), object: nil)
            }
        }
    }
    
    @objc func performTranslationAPICall(){
        selectedPageIndex = nil
        DispatchQueue.main.async {
            self.loadAnimation()
            if !self.pageControllerView.isHidden {
                self.showPageView(state: false)
                self.textView.isHidden = true
            }
        }
        RequestManager().getTranslationInformation(word: self.shareWord!) { (success, response) in
            print(response ?? Constants.kErrorMessage)
            // Notify translator controller
            DispatchQueue.main.async {
                if let word = response as? WordModel{
                    BaseContentViewController.word.hindiTranslation = word.hindiTranslation
                    self.textView.text = word.hindiTranslation
                    self.textView.isHidden = false
                }
                
                self.loadAnimation(isLoading: false)
                self.performAPICall()
            }
        }
    }
    
    // MARK: - CollectionView Datasource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPageTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WordCollectionViewCell
        cell.index = indexPath.row
        cell.textLabel.text = arrPageTitle[indexPath.row] as? String
        clearCollectionViewSelection()
        if (indexPath.row == selectedPageIndex){
            cell.textLabel.font = UIFont(name: cell.textLabel.font.fontName, size: 22)
        }
        else{
            cell.textLabel.font = UIFont(name: cell.textLabel.font.fontName, size: 16)
        }
        return cell
    }
    
    // MARK: - CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(selectedPageIndex != indexPath.item){
            selectPageAtIndex(index: indexPath.item)
            selectedPageIndex = indexPath.item
            collectionView.reloadData()
            
            if self.pageControllerView.isHidden {
                showPageView()
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let equalWidth: CGFloat = UIScreen.main.bounds.size.width/4
        let newWidth: CGFloat = UIScreen.main.bounds.size.width/4.5
        var width = equalWidth
        
        if selectedPageIndex != nil && selectedPageIndex != arrPageTitle.count {
            if selectedPageIndex == indexPath.item {
                // large size
                width = UIScreen.main.bounds.size.width - newWidth*3
            }
            else {
                // small size
                width = newWidth
            }
        }
        
        return CGSize(width: width, height: 40)
    }
    
    // MARK: - UIPageVieControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed && finished) {
            if let currentVC:BaseContentViewController = pageViewController.viewControllers?.last as? BaseContentViewController {
                if(selectedPageIndex != currentVC.pageIndex){
                    selectedPageIndex = currentVC.pageIndex
                    collectionView.reloadData()
                    changeWaterImage(index: selectedPageIndex!)
                }
            }
        }
    }
    
    // MARK: - UIPageVieControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent: BaseContentViewController = viewController as! BaseContentViewController
        var index = pageContent.pageIndex
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        index -= 1
        return viewControllerList[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent: BaseContentViewController = viewController as! BaseContentViewController
        var index = pageContent.pageIndex
        if (index == NSNotFound)
        {
            return nil;
        }
        index += 1
        if (index > arrPageTitle.count)
        {
            return nil;
        }
        return viewControllerList[index]
    }
    
    // MARK: - IBActions Methods
    @IBAction func closePagesButtonTapped(_ sender: Any) {
        showPageView(state: false)
        selectedPageIndex = nil
        self.collectionView.reloadData()
    }
    
    @IBAction func languageButtonTapped(_ sender: Any) {
        let index:Int = arrPageTitle.count
        if(selectedPageIndex != index) {
            selectedPageIndex = index
            selectPageAtIndex(index: index)
            collectionView.reloadData()
            
            if self.pageControllerView.isHidden {
                showPageView()
            }
            
        }
    }
    
    @objc func saveButtonTapped(sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    @objc func speakerButtonTapped(sender: UIBarButtonItem) {
        myUtterance = AVSpeechUtterance(string: shareWord ?? "")
        synth.speak(myUtterance)
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

