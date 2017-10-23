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
    
    //Mark: CollectionView Datasource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPageTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WordCollectionViewCell
        cell.textLabel.text = arrPageTitle[indexPath.row] as? String
        
        if (indexPath.row == 0){
            cell.textLabel.textColor = UIColor.white
            cell.backgroungTabImageView.image = UIImage(named: "SelectedTab")
        }
        else{
            cell.textLabel.textColor = UIColor.lightGray
            cell.backgroungTabImageView.image = UIImage(named: "UnSelectedTab")
        }
        return cell
    }
    
    //Mark: CollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(selectedPageIndex != indexPath.item){
            for cell in collectionView.visibleCells {
                (cell as! WordCollectionViewCell).textLabel.textColor = UIColor.lightGray
                (cell as! WordCollectionViewCell).backgroungTabImageView.image = UIImage(named: "UnSelectedTab")
            }
            if let cell = collectionView.cellForItem(at: indexPath) as! WordCollectionViewCell? {
                cell.textLabel.textColor = UIColor.white
                cell.backgroungTabImageView.image = UIImage(named: "SelectedTab")
            }
            
            selectPageAtIndex(index: indexPath.item)
            selectedPageIndex = indexPath.item
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
    
    // Mark: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        arrPageTitle = ["Definitions", "Synonyms", "Antonyms", "Examples"];
        for index in 0..<arrPageTitle.count {
            viewControllerList.append(getViewControllerAtIndex(index: index))
        }
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([viewControllerList[0]] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - Private Methods
    
    private func setupUI() {
        self.navigationItem.title = "Word Power"
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.init(red: 44.0/255.0, green:  193.0/255.0, blue:  133.0/255.0, alpha: 1.0) // Green color Theme
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MainPageViewController.saveButtonTapped(sender:)))
        
        view.addSubview(collectionView)
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> PageContentViewController{
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! PageContentViewController
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
    
    // Mark: - IBActions Methods
    
    @objc func saveButtonTapped(sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    
    // Mark: - UIPageVieControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed && finished) {
            if let currentVC:PageContentViewController = pageViewController.viewControllers?.last as? PageContentViewController {
                if(selectedPageIndex != currentVC.pageIndex){
                    let indexPath = IndexPath(item: currentVC.pageIndex, section: 0)
                    collectionView.delegate?.collectionView!(collectionView, didSelectItemAt: indexPath)
                    selectedPageIndex = currentVC.pageIndex
                    
                }
            }
        }
    }
    
    // Mark: - - UIPageVieControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent: PageContentViewController = viewController as! PageContentViewController
        var index = pageContent.pageIndex
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        index -= 1
        return viewControllerList[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent: PageContentViewController = viewController as! PageContentViewController
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
