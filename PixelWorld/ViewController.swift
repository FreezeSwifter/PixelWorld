//
//  ViewController.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/10.
//  Copyright © 2018年 mugua. All rights reserved.
//

import UIKit
import ParallaxHeader
import Hero
import Spring
import YPImagePicker
import RealmSwift
import ChameleonFramework

class ViewController: UIViewController {
    
    var notificationToken: NotificationToken? = nil
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    let header: HomeHeaderView = ViewLoader.Xib.view()
    @IBOutlet weak var pickButton: SpringButton!
    @IBOutlet weak var editButton: SpringButton! {
        didSet {
            editButton.isHidden = true
        }
    }
    @IBOutlet weak var shareButton: SpringButton! {
        didSet {
            shareButton.isHidden = true
        }
    }
    
    lazy var layout = BouncyLayout(style: .regular)
    lazy var insets = UIEdgeInsets(top: 200, left: 0, bottom: 200, right: 0)
    lazy var additionalInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    lazy var isPushed = false
    lazy var dataSouce: [PhotoModel] = []
    
    var pickConfig: YPImagePickerConfiguration = {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.onlySquare  = false
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = false
        config.showsFilters = false
        config.shouldSaveNewPicturesToAlbum = true
        
        config.albumName = "PixelWord"
        config.screens = [.library, .photo]
        config.startOnScreen = .library
        config.showsCrop = .none
        config.wordings.libraryTitle = "PixelWord"
        config.hidesStatusBar = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.spacingBetweenItems = 2
        config.isScrollToChangeModesEnabled = false
        return config
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPushed = false
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickerNavigationFont()
        setupCollectionView()
        setupButtons()
        setupRealmObserver()
        figureoutPhotoData()
        photoCollectionView.hero.id = "ironMan"
        
    }
    
    func showButtonsAnimation() {
        [shareButton, editButton].forEach{ btn in
            btn?.isHidden = false
            btn?.animation = "morph"
            btn?.curve = "linear"
            btn?.duration = 1.5
            btn?.animate()
        }
    }
    
    func figureoutPhotoData() {
        let realm = try! Realm()
        let photos = realm.objects(PhotoModel.self)
        dataSouce = Array(photos.sorted(byKeyPath: "createdTime"))
        photoCollectionView.reloadData()
    }
    
    func setupRealmObserver() {
        
        let realm = try! Realm()
        let results = realm.objects(PhotoModel.self)
        
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let collectionView = self?.photoCollectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
                
            case .update(let newData, let deletions, let insertions, let modifications):
                
                self?.dataSouce = Array(newData)
                
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    collectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
                    
                }, completion: { _ in })
                
                
            case .error(let error):
                
                fatalError("\(error)")
            }
        }
    }
    
    func setupButtons() {
        pickButton.animateNext {
            self.pickButton.animation = "squeeze"
            self.pickButton.curve = "EaseOut"
            self.pickButton.duration = 1
            self.pickButton.animate()
        }
        
        pickButton.addTarget(self, action: #selector(pickAction(_:)), for: UIControl.Event.touchUpInside)
    }
    
    func setupCollectionView() {
        
        layout.scrollDirection = .vertical
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.backgroundColor = UIColor.white
        photoCollectionView.showsVerticalScrollIndicator = true
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(UINib(nibName: "HomePhotoCell", bundle: nil), forCellWithReuseIdentifier: "HomePhotoCell")
        
        photoCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        photoCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
        
        photoCollectionView.parallaxHeader.view = header
        photoCollectionView.parallaxHeader.height = 180
        photoCollectionView.parallaxHeader.minimumHeight = 64
        photoCollectionView.parallaxHeader.mode = .centerFill
        
        photoCollectionView.parallaxHeader.parallaxHeaderDidScrollHandler = {[unowned self] parallaxHeader in
            
            self.header.imageView.blurView.alpha = 1 - parallaxHeader.progress
            
            if (1 - parallaxHeader.progress) < 0.8 {
                self.header.title.animateNext {
                    self.header.title.animation = "shake"
                    self.header.title.curve = "spring"
                    self.header.title.animateTo()
                }
            }
            
            if Int(parallaxHeader.progress) == 2 {
                
                if !self.isPushed {
                    
                    let aboutVC: AboutViewController = ViewLoader.Storyboard.controller(from: "Main")
                    self.isPushed = true
                    self.present(aboutVC, animated: true, completion: nil)
                    
                }
            }
            
        }
    }
    
    @objc func pickAction(_ button: SpringButton) {
        let picker = YPImagePicker(configuration: pickConfig)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                
                print(photo.originalImage)
                
                let realm = try! Realm()
                let p = PhotoModel()
                p.filterName = "Original"
                p.value = photo.originalImage.compressedData(quality: 0.9)
                try! realm.write {
                    realm.add(p)
                }
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func setupPickerNavigationFont() {
        
        guard let customFont = UIFont(name: "DisposableDroidBB-Bold", size: 22) else {
            fatalError("""
        Failed to load the "DisposableDroidBB-Bold" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        if #available(iOS 11.0, *) {
            let f = UIFontMetrics.default.scaledFont(for: customFont)
            let attributes = [NSAttributedString.Key.font : f]
            UINavigationBar.appearance().titleTextAttributes = attributes // Title fonts
            UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal) //
        } else {
            let attributes = [NSAttributedString.Key.font : customFont]
            UINavigationBar.appearance().titleTextAttributes = attributes // Title fonts
            UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal) //
        }
    }
}


extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HomePhotoCell
        if cell.isSelected == true {
            cell.layer.borderWidth = 8
            cell.layer.borderColor = UIColor.randomFlat.cgColor
            
            cell.photoView.curve = "pop"
            cell.photoView.animation = "spring"
            cell.photoView.duration = 1.0
            cell.photoView.scaleY = 2
            cell.photoView.scaleX = 2
            cell.photoView.animate()
        }
        
        showButtonsAnimation()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HomePhotoCell
        if cell.isSelected == false {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSouce.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePhotoCell", for: indexPath) as! HomePhotoCell
        
        cell.configure(withDataSource: dataSouce[indexPath.item])
        return cell
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: floor((UIScreen.main.bounds.width - (3 * 10)) / 2), height: floor((UIScreen.main.bounds.width - (3 * 10)) / 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
