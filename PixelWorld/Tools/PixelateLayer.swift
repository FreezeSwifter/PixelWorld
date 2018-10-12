//
//  PixelateLayer.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/11.
//  Copyright © 2018年 mugua. All rights reserved.
//

import Foundation
import UIKit

public class PixelateLayer {
    public let shape: Shape
    public var resolution: CGFloat
    public var size: CGFloat?
    public var alpha: CGFloat
    public var offset: CGFloat
    
    public init(_ shape: Shape, resolution: CGFloat, size: CGFloat? = nil, offset: CGFloat = 0, alpha: CGFloat = 1) {
        self.shape = shape
        self.resolution = resolution
        self.size = size
        self.offset = offset
        self.alpha = alpha
    }
    
    public enum Shape {
        case circle
        case diamond
        case square
    }
}
