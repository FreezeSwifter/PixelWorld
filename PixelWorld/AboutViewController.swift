//
//  AboutViewController.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/12.
//  Copyright © 2018年 mugua. All rights reserved.
//
import Spring
import UIKit

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
