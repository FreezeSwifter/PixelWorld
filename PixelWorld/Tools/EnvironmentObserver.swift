//
//  EnvironmentObserver.swift
//  PixelWorld
//
//  Created by mugua on 2019/6/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation


class EnvironmentObserver {
    
    static let shared = EnvironmentObserver()
    
    var developerPwd: String?
    var first: Bool? {
        get {
            return PWStorage.load(key: "first") as? Bool
        }
    }
    
    var text: String? {
        get {
            return PWStorage.load(key: "txt") as? String
        }
    }
    
    var bottomBar: Bool {
        get {
            return PWStorage.load(key: "bottomBar") as? Bool ?? true
        }
    }
    
    
    private init() {
        let obj = AVQuery(className: "Admin")
        obj.cachePolicy = .networkElseCache
        
        obj.whereKey("bundleIdentifier", equalTo: Bundle.main.bundleIdentifier ?? "com.mg.palettePixel")
        obj.getFirstObjectInBackground {[unowned self] (objc, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                self.developerPwd = objc?.object(forKey: "amdinPwd") as? String
            }
        }
    }
    
    func broadcast(txt: String, f: String, b: String) {
        #if DEBUG
        AVPush.setProductionMode(false)
        #else
        AVPush.setProductionMode(true)
        #endif
        
        AVPush.setProductionMode(false)
        let push = AVPush()
        push.setMessage("\(txt),\(f),\(b)")
        push.sendInBackground()
        
        let query = AVQuery(className: "PrivacyNewOne")
        query.cachePolicy = AVCachePolicy.networkElseCache
        query.whereKey("bundleIdentifier", equalTo: Bundle.main.bundleIdentifier ?? "com.mg.palettePixel")
        
        query.getFirstObjectInBackground { (obj, error) in
            if let e = error {
                print(e.localizedDescription)
            }
            if let o = obj {
                o.setObject(txt, forKey: "privacyPolicy")
                if f == "Y" {
                    o.setObject(true, forKey: "isFrist")
                } else {
                    o.setObject(false, forKey: "isFrist")
                }
                if b == "Y" {
                    o.setObject(true, forKey: "bottomBar")
                } else {
                    o.setObject(false, forKey: "bottomBar")
                }
                o.saveInBackground()
            }
        }
    }
}
