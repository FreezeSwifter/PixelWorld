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
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let realm = try! Realm()
        let photos = realm.objects(PhotoModel.self)
        if Array(photos.sorted(byKeyPath: "createdTime")).count == 0 {
            let p = PhotoModel()
            p.filterName = "Example Photo"
            p.value = UIImage(named: "example_photo")?.compressedData(quality: 0.9)
            try! realm.write {
                realm.add(p)
            }
        }
        
        return true
    }
}

