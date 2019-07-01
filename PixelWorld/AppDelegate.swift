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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        createExamplePhoto()
        setupLC()
        setupNotification()
        return true
    }
    
    private func setupLC() {
        AVOSCloud.setApplicationId("MGHYcjRFWPmEJXlswj1uA4lT-gzGzoHsz", clientKey: "PkcPHPBL6L0RD32pz4n0Qme0")
    }
    
    private func createExamplePhoto() {
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
    }
    
    private func setupNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            default:
                break
            }
        }
    }
}


extension AppDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // do something
        
        let dict = userInfo.values.first as? [String: Any]
        
        guard let result = dict?["alert"] as? String else { return }
        
        if result.count == 2 {
            if let en = result.components(separatedBy: ",").first {
                PWStorage.save(key: "txt", value: en)
            }
            
            if let f = result.components(separatedBy: ",").last {
                switch f {
                case "N", "n":
                    PWStorage.save(key: "first", value: false)
                    NotificationCenter.default.post(name: .refreshState, object: false)
                case "Y", "y":
                    NotificationCenter.default.post(name: .refreshState, object: true)
                    PWStorage.save(key: "first", value: true)
                default: break
                }
            }
        } else {
            let en = result.components(separatedBy: ",")[0]
            PWStorage.save(key: "txt", value: en)
            
            
            let f = result.components(separatedBy: ",")[1]
            switch f {
            case "N", "n":
                PWStorage.save(key: "first", value: false)
                NotificationCenter.default.post(name: .refreshState, object: false)
            case "Y", "y":
                NotificationCenter.default.post(name: .refreshState, object: true)
                PWStorage.save(key: "first", value: true)
            default: break
            }
            
            let b = result.components(separatedBy: ",")[2]
            
            switch b {
            case "N", "n":
                PWStorage.save(key: "bottomBar", value: false)
               
            case "Y", "y":
                PWStorage.save(key: "bottomBar", value: true)
            default: break
            }
        }
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
}

