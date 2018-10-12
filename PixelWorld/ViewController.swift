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

class ViewController: UIViewController {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    lazy var layout = BouncyLayout(style: .regular)
    let header: HomeHeaderView = ViewLoader.Xib.view()
    @IBOutlet weak var pickButton: SpringButton!
    
    lazy var insets = UIEdgeInsets(top: 200, left: 0, bottom: 200, right: 0)
    lazy var additionalInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    lazy var isPushed = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPushed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupButtons()
        photoCollectionView.hero.id = "ironMan"
    }
    
    func setupButtons() {
        pickButton.animateNext {
            self.pickButton.animation = "squeeze"
            self.pickButton.curve = "EaseOut"
            self.pickButton.duration = 1
            self.pickButton.animate()
        }
    }
    
    func setupCollectionView() {
        
        layout.scrollDirection = .vertical
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.backgroundColor = UIColor.white
        photoCollectionView.showsVerticalScrollIndicator = false
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
    
}


extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePhotoCell", for: indexPath) as! HomePhotoCell
        
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
