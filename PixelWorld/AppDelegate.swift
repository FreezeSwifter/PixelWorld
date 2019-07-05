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
        setupJPush(launchOptions: launchOptions)
        return true
    }
    
    private func setupJPush(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let jpEntity = JPUSHRegisterEntity()
        jpEntity.types = Int(UInt8(JPAuthorizationOptions.alert.rawValue) | UInt8(JPAuthorizationOptions.badge.rawValue) | UInt8(JPAuthorizationOptions.sound.rawValue))
        JPUSHService.register(forRemoteNotificationConfig: jpEntity, delegate: self)
        #if DEBUG
        JPUSHService.setup(withOption: launchOptions, appKey: "9fe9b534aa7f894b67edd5a7", channel: "iOS", apsForProduction: false)
        #else
        JPUSHService.setup(withOption: launchOptions, appKey: "9fe9b534aa7f894b67edd5a7", channel: "iOS", apsForProduction: true)
        #endif
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


extension AppDelegate: JPUSHRegisterDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        JPUSHService.registerDeviceToken(deviceToken)
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
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo
        print(userInfo.description)
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            let invalidLogin = userInfo["Type"] as? String
            if let invalidLogin = invalidLogin, invalidLogin == "1" {
                
            }
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        
    }
    
}

