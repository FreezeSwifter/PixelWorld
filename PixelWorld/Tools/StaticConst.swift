//
//  StaticConst.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification.Name {
    
    public static let statuBarDidChnage = NSNotification.Name(rawValue: "StatuBarDidChnage")
    public static let loginStateDidChnage = NSNotification.Name(rawValue: "loginStateDidChnage")
    public static let refreshState = NSNotification.Name(rawValue: "refreshState")
}


struct DatabaseKey {
    
    static let userTable = "_User"
    static let privacyTable = "PrivacyModel"
    static let labelTable = "LabelTable"
    static let amdinPwdTable = "amdinPwdTable"
}


struct Keys {
    
    static let leanCloudId = "MGHYcjRFWPmEJXlswj1uA4lT-gzGzoHsz"
    static let leanCloudClentKey = "PkcPHPBL6L0RD32pz4n0Qme0"
}
