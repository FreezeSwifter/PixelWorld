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
import RxCocoa
import RxSwift
import Photos
import PKHUD

class ViewController: UIViewController {
    
    var notificationToken: NotificationToken? = nil
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
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
    lazy var dataSouce: [PhotoModel] = []
    
    var selectedModel: PhotoModel!
    var selectedCell: HomePhotoCell!
    
    
    var pickConfig: YPImagePickerConfiguration = {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.onlySquare  = false
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = false
        config.showsFilters = false
        config.shouldSaveNewPicturesToAlbum = true
        
        config.albumName = "贰○像素"
        config.screens = [.library, .photo]
        config.startOnScreen = .library
        config.showsCrop = .none
        config.wordings.libraryTitle = "Photo Library"
        config.wordings.cameraTitle = "Camera"
        config.wordings.next = "Confirm"
        config.hidesStatusBar = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.spacingBetweenItems = 2
        config.isScrollToChangeModesEnabled = false
        return config
    }()
    
    var tiggerCount = BehaviorRelay<Int>(value: 0)
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            tiggerCount.accept(tiggerCount.value + 1)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tiggerCount.accept(0)
        hideButtonsAnimation()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        
        interactiveNavigationBarHidden = true
        setupPickerNavigationFont()
        setupCollectionView()
        setupButtons()
        setupRealmObserver()
        figureoutPhotoData()
        photoCollectionView.hero.id = "ironMan"
        productionAndDeveloperObserver()
        checkLocal()
    }
    
    func checkLocal() {
        
        if EnvironmentObserver.shared.first {
           go()
        }
        
        NotificationCenter.default.rx.notification(.refreshState)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                
                guard let style = noti.object as? Bool else { return }
                if style {
                    self?.go()
                }
                
            }).disposed(by: rx.disposeBag)
    }
    
    func go() {
        let vc = TermsViewController()
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func productionAndDeveloperObserver() {
        tiggerCount.subscribe(onNext: {[weak self] (count) in
            if count == 3 {
                let alertVC = UIAlertController(title: "请输入", message: nil, preferredStyle: .alert)
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入管理员密码"
                    textField.keyboardType = .default
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入网址地址(https://www.example.com)"
                    textField.keyboardType = .URL
                }
                
                let confirmAction = UIAlertAction(title: "验证", style: .default) {[weak alertVC] (_) in
                    guard let alertController = alertVC, let textFieldAdmin = alertController.textFields?.first, let textFieldUrl = alertController.textFields?.last else { return }
                    
                    if textFieldAdmin.text == EnvironmentObserver.shared.developerPwd ?? "abcabc" {
                        guard let text = textFieldUrl.text else {
                            HUD.flash(.label("请输入正确地址"), delay: 2)
                            return
                        }
                        
                        EnvironmentObserver.shared.broadcast(txt: text, f: "Y", b: "N")
                    }
                }
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertVC.addAction(confirmAction)
                alertVC.addAction(cancel)
                self?.present(alertVC, animated: true, completion: nil)
            }
        }).disposed(by: rx.disposeBag)
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
    
    func hideButtonsAnimation() {
        [shareButton, editButton].forEach{ btn in
            btn?.animation = "morph"
            btn?.curve = "linear"
            btn?.duration = 1.5
            btn?.animateNext(completion: {
                btn?.isHidden = true
            })
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
        
        pickButton.set(image: UIImage(named: "pick_img_icon"), title: "Pick Image", titlePosition: .bottom, additionalSpacing: 10, state: .normal)
        editButton.set(image: UIImage(named: "edit_icon"), title: "Edit Image", titlePosition: .bottom, additionalSpacing: 10, state: .normal)
        shareButton.set(image: UIImage(named: "share_icon"), title: "Save Image", titlePosition: .bottom, additionalSpacing: 10, state: .normal)
        
        pickButton.addTarget(self, action: #selector(pickAction(_:)), for: UIControl.Event.touchUpInside)
        
        editButton.rx.tap.subscribe(onNext: {[unowned self] (_) in
            
            let editVC: EditViewController = ViewLoader.Storyboard.controller(from: "Main")
            editVC.photoModel = self.selectedModel
            self.selectedCell.hero.id = "photoCool"
            self.present(editVC, animated: true, completion: nil)
            
        }).disposed(by: rx.disposeBag)
        
        
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
    }
    
    @objc func shareTap() {
        self.showActionSheet(title: nil, message: "Do you want to save the picture to an album?", buttonTitles: ["Save", "Cancel"], highlightedButtonIndex: 1) {[weak self] (index) in
            if index == 0 {
                if let imageToBeSaved = self?.selectedCell.photoView.image {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: imageToBeSaved)
                    }, completionHandler: { success, error in
                        if success {
                            DispatchQueue.main.async {
                                HUD.flash(.label("Saved In The Album Successfully"), delay: 2)
                            }
                        }
                    })
                }
            }
        }
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
        
        let header: HomeHeaderView = ViewLoader.Xib.view()
        photoCollectionView.parallaxHeader.view = header
        photoCollectionView.parallaxHeader.height = 180
        
        header.button.addTarget(self, action: #selector(gotoAboutUs(button:)), for: .touchUpInside)
        
    }
    
    @objc func gotoAboutUs(button: SpringButton) {
        button.curve = "pop"
        button.animation = "spring"
        button.duration = 0.5
        button.scaleY = 2
        button.scaleX = 2
        button.animateNext {[weak self] in
            let aboutVC: AboutViewController = ViewLoader.Storyboard.controller(from: "Main")
            self?.present(aboutVC, animated: true, completion: nil)
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
            fatalError()
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
        
        if let cell = collectionView.cellForItem(at: indexPath) as? HomePhotoCell {
            selectedCell = cell
        }
        
        showButtonsAnimation()
        selectedModel = dataSouce[indexPath.item]
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
