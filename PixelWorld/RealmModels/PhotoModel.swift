//
//  PhotoModel.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/15.
//  Copyright © 2018年 mugua. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoModel: Object {
    
    @objc dynamic var createdTime = Date()
    @objc dynamic var filterName: String? = nil
    @objc dynamic var value: Data? = nil
    
    override static func indexedProperties() -> [String] {
        return ["createdTime"]
    }
}

extension PhotoModel: HomePhotoCellDataSource {
    
    var imageValue: Data {
        return value ?? Data()
    }
    
    var title: String {
        return filterName ?? ""
    }
}

