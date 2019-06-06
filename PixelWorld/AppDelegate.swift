//
//  AppDelegate.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/10.
//  Copyright © 2018年 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        let _ = ServerHelper.shared
        
        ServerHelper.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (_, object, _) = block
            
            guard let p = object as? AVObject else {
                return
            }
            guard let isAlert = p.object(forKey: "isFristShow") as? Bool else {
                return
            }
            
            if isAlert {
                let array = [1]
                let _ = array[1]
            }
        }).disposed(by: rx.disposeBag)
        
        return true
    }
}

