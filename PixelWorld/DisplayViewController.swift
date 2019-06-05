//
//  DisplayViewController.swift
//  PixelWorld
//
//  Created by mugua on 2019/6/5.
//  Copyright © 2019 mugua. All rights reserved.
//
import JXSegmentedView
import UIKit
import RxCocoa
import RxSwift

class DisplayViewController: UIViewController {
    
    
    typealias CurrentShowImageBlock = (UIImage) -> Void
    
    let filterTpye = BehaviorSubject<Int>(value: 0)
    var photoModel: PhotoModel!
    
    private var filters: FilterHelper = .buffing
    var displayImage: CurrentShowImageBlock?
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        createdFilters()
    }
    
    func createdFilters() {
        
        filterTpye.subscribe(onNext: {[unowned self] (type) in
            
            self.filters = FilterHelper(rawValue: type) ?? .buffing
            let img = self.filters.getFilter(image: self.photoModel.getImage())
            self.ImageView.image = img
            self.displayImage?(img)
            
        }).disposed(by: rx.disposeBag)
    }
}


extension DisplayViewController: JXSegmentedListContainerViewListDelegate {
    
    func listView() -> UIView {
        
        return view
    }
}
