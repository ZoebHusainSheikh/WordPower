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

class MainPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var viewControllerList:[UIViewController] = []
    var selectedPageIndex:Int = 0
    var shareWord:String? = nil
    
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
        }
        else{
            cell.textLabel.textColor = UIColor.lightGray
            cell.backgroungTabImageView.image = UIImage(named: "UnSelectedTab")
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
            origin: CGPoint(x: 0, y: navigationBarHeight),
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
    
    var arrPageTitle: NSArray = NSArray()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MainPageViewController.performTranslationAPICall), name:NSNotification.Name("PerformTranslatorAPICallIdentifier"), object: nil)
        BaseContentViewController.word = WordModel()
        arrPageTitle = ["Definitions", "Synonyms", "Antonyms", "Examples", "Translator"];
        for index in 0..<arrPageTitle.count {
            viewControllerList.append(getViewControllerAtIndex(index: index))
        }
        
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([viewControllerList[0]] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        setupUI()
        setupShareWord()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        self.navigationItem.title = "Word Power"
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.init(red: 44.0/255.0, green:  193.0/255.0, blue:  133.0/255.0, alpha: 1.0) // Green color Theme
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MainPageViewController.saveButtonTapped(sender:)))
        
        view.addSubview(collectionView)
        self.view.isUserInteractionEnabled = false
    }
    
    private func setupShareWord(){
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeText = kUTTypeText as String
        
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText)
            {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    let text = results as! String
                    if self.validateStringNotUrl(urlString: text){
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
    
    func validateStringNotUrl (urlString: String) -> Bool {
        if let url:URL = URL(string: urlString){
            if (url.scheme != nil) && (url.host != nil){
                return false
            }
        }
        return true
    }
    
    func clearCollectionViewSelection(){
        for cell in collectionView.visibleCells {
            let isSelectedCell:Bool = ((cell as! WordCollectionViewCell).index == selectedPageIndex)
            (cell as! WordCollectionViewCell).textLabel.textColor = isSelectedCell ? UIColor.white : UIColor.lightGray
            (cell as! WordCollectionViewCell).backgroungTabImageView.image = UIImage(named: isSelectedCell ? "SelectedTab" : "UnSelectedTab")
        }
    }
    
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
            weak var pvcw = self
            self.setViewControllers([page], direction: (selectedPageIndex < index ? UIPageViewControllerNavigationDirection.forward : UIPageViewControllerNavigationDirection.reverse), animated: true) { _ in
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
    
    // MARK: - IBActions Methods
    
    @objc func saveButtonTapped(sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
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

private extension MainPageViewController {
    struct Identifiers {
        static let DeckCell = "deckCell"
    }
}

