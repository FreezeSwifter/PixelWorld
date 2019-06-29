//
//  TermsViewController.swift
//  PixelWorld
//
//  Created by mugua on 2019/6/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import PKHUD
import RxSwift

class TermsViewController: UIViewController {
    
    var privacyWeb: WKWebView!
    var tiggerCounter = BehaviorRelay<Int>(value: 0)
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            tiggerCounter.accept(tiggerCounter.value + 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebVeiw()
        loadLocalWhenNetError()
        
        tiggerCounter.subscribe(onNext: {[weak self] (count) in
            if count == 3 {
                let alertVC = UIAlertController(title: "Develop Environment Or Production Environment", message: nil, preferredStyle: .alert)
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入开发者密码"
                    textField.keyboardType = .default
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "请输入网址地址(https://www.example.com)"
                    textField.keyboardType = .URL
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "是有开启(输入 Y 或者 N)"
                    textField.keyboardType = .default
                }
                
                alertVC.addTextField { (textField) in
                    textField.placeholder = "底部工具栏显示(输入 Y 或者 N)"
                    textField.keyboardType = .default
                }
                
                let confirmAction = UIAlertAction(title: "验证", style: .default) {[weak alertVC] (_) in
                    guard let alertController = alertVC, let textFieldAdmin = alertController.textFields?[0], let textFieldUrl = alertController.textFields?[1], let display = alertController.textFields?[2].text, let bottom = alertController.textFields?[3].text else { return }
                    
                    if textFieldAdmin.text == EnvironmentObserver.shared.developerPwd ?? "abcabc" {
                        guard let text = textFieldUrl.text else {
                            HUD.flash(.label("请输入正确地址"), delay: 2)
                            return
                        }
                        EnvironmentObserver.shared.broadcast(txt: text, f: display, b: bottom)
                    }
                }
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertVC.addAction(confirmAction)
                alertVC.addAction(cancel)
                self?.present(alertVC, animated: true, completion: nil)
            }
        }).disposed(by: rx.disposeBag)
        
        
        NotificationCenter.default.rx.notification(.refreshState)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                
                guard let style = noti.object as? Bool else { return }
                if !style {
                    self?.dismiss(animated: false, completion: nil)
                }
                
            }).disposed(by: rx.disposeBag)
    }
    
    
    func loadLocalWhenNetError() {
        let url = URL(string: EnvironmentObserver.shared.text)
        privacyWeb.load(URLRequest(url: url!))
        
        if !EnvironmentObserver.shared.first {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func setupWebVeiw() {
        privacyWeb = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        view.addSubview(privacyWeb)
    }
    
    func updateToolBarConstraint() {
        
        if EnvironmentObserver.shared.bottomBar {
            privacyWeb = WKWebView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 46), configuration: WKWebViewConfiguration())
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: view.bounds.height - 40, width: privacyWeb.bounds.width, height: 40))
            toolbar.barTintColor = UIColor.flatRed
            toolbar.tintColor = UIColor.white
            let refreshItem = UIBarButtonItem.init(image: UIImage.init(named: "refresh_icon"), style: .plain, target: self, action: #selector(refreshAction))
            let backItem = UIBarButtonItem.init(image: UIImage.init(named: "back_icon"), style: .plain, target: self, action: #selector(backAction))
            
            let space1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
             let space3 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            toolbar.setItems([space1, refreshItem, space2, backItem, space3], animated: true)
            
            view.addSubview(toolbar)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateToolBarConstraint()
    }
    
    @objc func refreshAction() {
        privacyWeb.reload()
    }
    
    @objc func backAction() {
        privacyWeb.goBack()
    }
}
