//
//  EditViewController.swift
//  PixelWorld
//
//  Created by mugua on 2019/6/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import JXSegmentedView
import RealmSwift
import Realm
import PKHUD

class EditViewController: UIViewController {
    
    var photoModel: PhotoModel!
    @IBOutlet weak var segContainerView: UIView!
    
    var segmentedView: JXSegmentedView!
    let segmentedDataSource = JXSegmentedTitleDataSource()
    var listContainerView: JXSegmentedListContainerView!
    
    var afterFilterType = 0
    var afterImage: UIImage!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIs()
        self.hero.isEnabled = true
        self.listContainerView.hero.id = "photoCool"
    }
    
    func setupUIs() {
        segmentedView = JXSegmentedView(frame: segContainerView.bounds)
        segContainerView.addSubview(segmentedView)
        segmentedView.delegate = self
        
        segmentedDataSource.titles = ["Buffing", "Liquidation", "Rhombus", "Fissured", "Oil", "Telescopic", "Electronization", "Gasify", "Wood"]
        segmentedDataSource.titleNormalColor = UIColor.white
        segmentedDataSource.titleSelectedColor = UIColor.white
        if let customFont =  UIFont(name: "DisposableDroidBB-Bold", size: 28) {
            segmentedDataSource.titleSelectedFont = customFont
            segmentedDataSource.titleNormalFont = customFont
        }
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.reloadData(selectedIndex: photoModel.filterType)
        segmentedView.dataSource = segmentedDataSource
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor = UIColor.white
        segmentedView.indicators = [indicator]
        
        listContainerView = JXSegmentedListContainerView(dataSource: self)
        view.addSubview(self.listContainerView)
        segmentedView.contentScrollView = listContainerView.scrollView
    }
    
    @IBAction func dismissTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteTap(_ sender: UIButton) {
        self.showActionSheet(title: nil, message: "You sure you want to delete it?", buttonTitles: ["Delete", "Cancel"], highlightedButtonIndex: 1) {[weak self] (index) in
            guard let this = self else { return }
            if index == 0 {
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(this.photoModel)
                }
                
                HUD.flash(.label("Deleting..."), delay: 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {[weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func saveTap(_ sender: UIButton) {
        let realm = try! Realm()
        try! realm.write {
            if let filterName = FilterHelper(rawValue: afterFilterType) {
                photoModel.filterName = filterName.description
            }
            
            photoModel.createdTime = Date()
            photoModel.value = afterImage.compressedData(quality: 0.9)
            photoModel.filterType = afterFilterType
        }
        
        HUD.flash(.label("Saving..."), delay: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedView.frame = segContainerView.bounds
        listContainerView.frame = CGRect(x: 0, y: 160, width: view.bounds.size.width, height: view.bounds.size.height - 160 - 105)
    }
}


extension EditViewController: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
        listContainerView.didClickSelectedItem(at: index)
        
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        
        listContainerView.segmentedViewScrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
    
}


extension EditViewController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource.titles.count
    }
    
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        afterFilterType = index
        let displayVC: DisplayViewController = ViewLoader.Storyboard.controller(from: "Main")
        displayVC.photoModel = photoModel
        displayVC.filterTpye.onNext(index)
        displayVC.displayImage = {[weak self] (currentImage) in
            
            self?.afterImage = currentImage
        }
        return displayVC
    }
}
