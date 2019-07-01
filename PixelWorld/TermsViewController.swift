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
import SnapKit
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
        updateToolBarConstraint()
        
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
    
        let query = AVQuery(className: "PrivacyNewOne")
        query.cachePolicy = AVCachePolicy.networkElseCache
        query.whereKey("bundleIdentifier", equalTo: Bundle.main.bundleIdentifier ?? "com.mg.palettePixel")
        
        query.getFirstObjectInBackground { (obj, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            if let o = obj {
                guard let f = o.object(forKey: "isFrist") as? Bool, let text = o.object(forKey: "privacyPolicy") as? String else { return }
                if !f {
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                }
                
                let url = URL(string: text)
                guard let u = url else {
                    HUD.flash(.label("地址错误"), delay: 2)
                    return
                }
                self.privacyWeb.load(URLRequest(url: u))
            }
        }

    }
    
    func setupWebVeiw() {
        privacyWeb = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.addSubview(privacyWeb)
        privacyWeb.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
    func updateToolBarConstraint() {
        
        if EnvironmentObserver.shared.bottomBar {
            privacyWeb.snp.updateConstraints { (maker) in
                maker.top.left.right.equalToSuperview()
                maker.bottom.equalTo(self.view.snp_bottom).offset(-46)
            }
            let toolbar = UIToolbar(frame: .zero)
            view.addSubview(toolbar)
            toolbar.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.privacyWeb.snp_bottom)
                maker.left.right.bottom.equalToSuperview()
            }
            
            toolbar.barTintColor = UIColor.flatRed
            toolbar.tintColor = UIColor.white
            let refreshItem = UIBarButtonItem(image: UIImage(named: "refresh_icon"), style: .plain, target: self, action: #selector(refreshAction))
            let backItem = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .plain, target: self, action: #selector(backAction))
            let goItem = UIBarButtonItem(image: UIImage(named: "go_icon"), style: .plain, target: self, action: #selector(goAction))

            
            let space1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
         
            toolbar.setItems([backItem, space1, refreshItem, space2, goItem], animated: true)
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc func refreshAction() {
        privacyWeb.reload()
    }
    
    @objc func backAction() {
        if privacyWeb.canGoBack {
            privacyWeb.goBack()
        }
    }
    
    @objc func goAction() {
        if privacyWeb.canGoForward {
            privacyWeb.goForward()
        }
    }
}
