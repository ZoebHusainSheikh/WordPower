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

class MainPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    var pageControlViewController:UIPageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var viewControllerList:[UIViewController] = []
    var selectedPageIndex:Int = 0
    var shareWord:String? = nil
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var arrPageTitle: NSArray = ["Definitions", "Synonyms", "Antonyms", "Examples", "Translator"]
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(MainPageViewController.performTranslationAPICall), name:NSNotification.Name("PerformTranslatorAPICallIdentifier"), object: nil)
        BaseContentViewController.word = WordModel()
        setupUI()
        setupShareWord()
    }
    
    private func setupUI() {
        setupPageVC()
        self.navigationItem.title = "Word Power"
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.init(red: 44.0/255.0, green:  193.0/255.0, blue:  133.0/255.0, alpha: 1.0) // Green color Theme
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MainPageViewController.saveButtonTapped(sender:)))
        leftBarButton()
        view.addSubview(collectionView)
        self.view.isUserInteractionEnabled = false
    }
    
    private func setupPageVC(){
        for index in 0..<arrPageTitle.count {
            viewControllerList.append(getViewControllerAtIndex(index: index))
        }
        
        pageControlViewController.dataSource = self
        pageControlViewController.delegate = self
        pageControlViewController.setViewControllers([viewControllerList[0]] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        let pageControllerView = pageControlViewController.view!
        pageControllerView.backgroundColor = UIColor.clear
        view.addSubview(pageControllerView)
        
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
    
    private func leftBarButton(){
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "speaker"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(MainPageViewController.speakerButtonTapped(sender:)), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 32, height: 32)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
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
                        self.performAPICall()
                    }
                    else{
                        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                })
            }
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
            wordCollectionViewCell.textLabel.textColor = isSelectedCell ? UIColor.white : UIColor.lightGray
            wordCollectionViewCell.backgroungTabImageView.image = UIImage(named: isSelectedCell ? "SelectedTab" : "UnSelectedTab")
            wordCollectionViewCell.textLabel.font = UIFont(name: wordCollectionViewCell.textLabel.font.fontName, size:  isSelectedCell ? 16 : 10)
        }
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> BaseContentViewController{
        // Create a new view controller and pass suitable data.
        
        var pageContentViewController:BaseContentViewController!
        if index == (arrPageTitle.count-1){
            pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "TranslatorViewController") as! BaseContentViewController
        }
        else{
            pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! BaseContentViewController
        }
        
        pageContentViewController.strTitle = "\(arrPageTitle[index])"
        pageContentViewController.pageIndex = index
        pageContentViewController.wordInfoType = index == 0 ? .definitions : index == 1 ? .synonyms : index == 2 ? .antonyms : index == 3 ? .examples : .hindiTranslation
        return pageContentViewController
    }
    
    func selectPageAtIndex(index:NSInteger)
    {
        if index < viewControllerList.count{
            let page = viewControllerList[index]
            weak var pvcw = pageControlViewController
            pageControlViewController.setViewControllers([page], direction: (selectedPageIndex < index ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse), animated: true) { _ in
                if let pvcs = pvcw {
                    DispatchQueue.main.async{
                        pvcs.setViewControllers([page], direction: (self.selectedPageIndex < index ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse), animated: false, completion: nil)
                    }
                }
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
        NotificationCenter.default.post(name: Notification.Name("StartAnimationIdentifier"), object: nil)
        BaseContentViewController.word.word = shareWord
        RequestManager().getWordInformation(word: self.shareWord!) { (success, response) in
            print(response ?? Constants.kErrorMessage)
            // Notify page content controllers
            DispatchQueue.main.async {
                if let word = response as? WordModel{
                    BaseContentViewController.word = word
                }
                
                self.view.isUserInteractionEnabled = true
                NotificationCenter.default.post(name: Notification.Name("StopAnimationIdentifier"), object: nil)
                
                self.performTranslationAPICall()
            }
        }
    }
    
    @objc func performTranslationAPICall(){
        NotificationCenter.default.post(name: Notification.Name("StartTranslatorAnimationIdentifier"), object: nil)
        RequestManager().getTranslationInformation(word: self.shareWord!) { (success, response) in
            print(response ?? Constants.kErrorMessage)
            // Notify translator controller
            DispatchQueue.main.async {
                if let word = response as? WordModel{
                    BaseContentViewController.word.hindiTranslation = word.hindiTranslation
                }
                
                NotificationCenter.default.post(name: Notification.Name("StopTranslatorAnimationIdentifier"), object: nil)
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
            cell.textLabel.textColor = UIColor.white
            cell.backgroungTabImageView.image = UIImage(named: "SelectedTab")
            cell.textLabel.font = UIFont(name: cell.textLabel.font.fontName, size: 16)
        }
        else{
            cell.textLabel.textColor = UIColor.lightGray
            cell.backgroungTabImageView.image = UIImage(named: "UnSelectedTab")
            cell.textLabel.font = UIFont(name: cell.textLabel.font.fontName, size: 10)
        }
        return cell
    }
    
    // MARK: - CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(selectedPageIndex != indexPath.item){
            selectPageAtIndex(index: indexPath.item)
            selectedPageIndex = indexPath.item
            
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/4, height: 40)
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        let navigationBarHeight: CGFloat = 20 + self.navigationController!.navigationBar.frame.height
        let rect = CGRect(
            origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height - 40),
            size: CGSize(width: UIScreen.main.bounds.size.width, height: 40)
        )
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "WordCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.init(red: 228.0/255.0, green:  233.0/255.0, blue:  231.0/255.0, alpha: 1.0)
        
        collectionView.allowsMultipleSelection = false
        print("Collection view initialised")
        return collectionView
    }()
    
    // MARK: - IBActions Methods
    
    @objc func saveButtonTapped(sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    @objc func speakerButtonTapped(sender: UIBarButtonItem) {
        myUtterance = AVSpeechUtterance(string: shareWord ?? "")
        synth.speak(myUtterance)
    }
    
    // MARK: - UIPageVieControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed && finished) {
            if let currentVC:BaseContentViewController = pageViewController.viewControllers?.last as? BaseContentViewController {
                if(selectedPageIndex != currentVC.pageIndex){
                    let indexPath = IndexPath(item: currentVC.pageIndex, section: 0)
                    collectionView.delegate?.collectionView!(collectionView, didSelectItemAt: indexPath)
                    selectedPageIndex = currentVC.pageIndex
                    
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
        if (index == arrPageTitle.count)
        {
            return nil;
        }
        return viewControllerList[index]
    }
    
}

