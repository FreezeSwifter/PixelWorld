//
//  AboutViewController.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/12.
//  Copyright © 2018年 mugua. All rights reserved.
//
import Spring
import UIKit
import StoreKit

class AboutViewController: UITableViewController {
    
    let header: AboutHeaderView = ViewLoader.Xib.view()
    @IBOutlet weak var descriptionLabel: SpringLabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        self.hero.isEnabled = true
        tableView.hero.id = "ironMan"
        tableView.hero.modifiers = [.fade, .scale(0.5)]
        descriptionLabel.animate()
        
        checkAndAskForReview()
    }
    
    func setupTableView() {
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.parallaxHeader.view = header
        tableView.parallaxHeader.height = 180
        tableView.parallaxHeader.minimumHeight = 64
        tableView.parallaxHeader.mode = .centerFill
        
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = {[weak self] parallaxHeader in
            
            self?.header.image.blurView.alpha = 1 - parallaxHeader.progress
            if Int(parallaxHeader.progress) == 2 {
                self?.dismiss(animated: true, completion: nil)
            }
            
        }
    }
}


extension AboutViewController {
    
    private func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    fileprivate func checkAndAskForReview() {
        
        guard let appOpenCount = PWStorage.load(key: "AppOpenCount") as? Int else {
            PWStorage.save(key: "AppOpenCount", value: 1)
            return
        }
        
        switch appOpenCount {
        case 1,5:
            requestReview()
        case _ where appOpenCount % 100 == 0 :
            requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
        AboutViewController.incrementAppOpenedCount()
    }
    
    private static func incrementAppOpenedCount() {
        guard var appOpenCount = PWStorage.load(key: "AppOpenCount") as? Int else {
            PWStorage.save(key: "AppOpenCount", value: 1)
            return
        }
        appOpenCount += 1
        PWStorage.save(key: "AppOpenCount", value: appOpenCount)
    }
}
