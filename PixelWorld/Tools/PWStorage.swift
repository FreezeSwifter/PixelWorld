//
//  PWStorage.swift
//  PixelWorld
//
//  Created by mugua on 2019/6/28.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation

public struct PWStorage {
    
    public static func save(key: String, value: Any?) {
        guard let value = value else {
            UserDefaults.standard.setValue(nil, forKey: key)
            return
        }
        UserDefaults.standard.setValue(value, forKey: key)
        do {
            UserDefaults.standard.synchronize()
        }
    }
    
    public static func load(key: String) -> Any? {
        return UserDefaults.standard.value(forKey:key)
    }
    
    public static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        do {
            UserDefaults.standard.synchronize()
        }
    }
}
