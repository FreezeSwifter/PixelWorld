//
//  TaskService.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/19.
//  Copyright © 2018年 mugua. All rights reserved.
//

import Foundation
import RxSwift

enum TaskEvent {
    case create(PhotoModel)
    case update(PhotoModel)
    case delete(PhotoModel)
}
