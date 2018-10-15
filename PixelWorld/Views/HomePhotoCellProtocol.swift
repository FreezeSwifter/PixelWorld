//
//  HomePhotoCellProtocol.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/15.
//  Copyright © 2018年 mugua. All rights reserved.
//

import Foundation
import UIKit

protocol HomePhotoCellDataSource {

    var imageValue: Data { get }
    var createdTime: Date { get }
    var title: String { get }
}

