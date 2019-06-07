//
//  PixelFilters.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/15.
//  Copyright © 2018年 mugua. All rights reserved.
//

import Foundation
import UIKit
import FlexibleImage

enum PixelFilters: String {
    case frostedCanvas = "Artists' Canvas"
    case artOppo = "Art Oppo"
    case diamondShining = "Diamond Shining"
    case gridding = "Gridding"
    case rhombus = "Rhombus"
    case benz = "Benz"
    case superDot = "Super Dot"
    case amazedFace = "Amazed Face"
    case quadrelFool = "Quadrel Fool"
    
    case mix = "Hard Mix"
    
    func ultimateFactories(_ image: UIImage) -> UIImage {
        let bitmap = image.cgImage!
        switch self {
        case .frostedCanvas:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.diamond, resolution: 48, size: 50),
                                         PixelateLayer(.diamond, resolution: 48, offset: 24),
                                         PixelateLayer(.diamond, resolution: 8, size: 6))
            return UIImage(cgImage: result!)
            
        case .artOppo:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.square, resolution: 32),
                                         PixelateLayer(.circle, resolution: 32, offset: 15),
                                         PixelateLayer(.circle, resolution: 32, size: 26, offset: 13),
                                         PixelateLayer(.circle, resolution: 32, size: 18, offset: 10),
                                         PixelateLayer(.circle, resolution: 32, size: 12, offset: 8))
            return UIImage(cgImage: result!)
            
        case .diamondShining:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.square, resolution: 48),
                                         PixelateLayer(.diamond, resolution: 48, offset: 12, alpha: 0.5),
                                         PixelateLayer(.diamond, resolution: 48, offset: 36, alpha: 0.5),
                                         PixelateLayer(.diamond, resolution: 16, size: 8, offset: 4))
            return UIImage(cgImage: result!)
            
        case .gridding:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.circle, resolution: 32, size: 6, offset: 8),
                                         PixelateLayer(.circle, resolution: 32, size: 9, offset: 8),
                                         PixelateLayer(.circle, resolution: 32, size: 12, offset: 24),
                                         PixelateLayer(.circle, resolution: 32, size: 9, offset: 0))
            return UIImage(cgImage: result!)
            
        case .rhombus:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.diamond, resolution: 24, size: 25),
                                         PixelateLayer(.diamond, resolution: 24, offset: 12),
                                         PixelateLayer(.square, resolution: 24, alpha: 0.6))
            return UIImage(cgImage: result!)
            
        case .benz:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.square, resolution: 32),
                                         PixelateLayer(.circle, resolution: 32, offset: 16),
                                         PixelateLayer(.circle, resolution: 32, offset: 0, alpha: 0.5),
                                         PixelateLayer(.circle, resolution: 16, size: 9, offset: 0, alpha: 0.5))
            return UIImage(cgImage: result!)
            
        case .superDot:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.circle, resolution: 24),
                                         PixelateLayer(.circle, resolution: 24, size: 9, offset: 12))
            return UIImage(cgImage: result!)
            
        case .amazedFace:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.square, resolution: 48, offset: 12),
                                         PixelateLayer(.circle, resolution: 48, offset: 0),
                                         PixelateLayer(.diamond, resolution: 16, size: 15, offset: 0, alpha: 0.6),
                                         PixelateLayer(.diamond, resolution: 16, size: 15, offset: 8, alpha: 0.6))
            return UIImage(cgImage: result!)
            
        case .quadrelFool:
            
            let result = Pixelate.create(pixels: bitmap,
                                         layers: PixelateLayer(.square, resolution: 48),
                                         PixelateLayer(.diamond, resolution: 12, size: 8),
                                         PixelateLayer(.diamond, resolution: 12, size: 8, offset: 6))
            return UIImage(cgImage: result!)
            
        case .mix:
            let image1 = UIImage
                .circle(
                    color: UIColor.blue,
                    size: CGSize(width: 100, height: 100)
                )!.adjust()
                .offset(CGPoint(x: 25, y: 0))
                .margin(EdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
                .padding(EdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
                .normal(color: UIColor.white)
                .border(color: UIColor.red, lineWidth: 5, radius: 50)
                .image()!
                
                .adjust()
                .background(color: UIColor.darkGray)
                .image()
            
            let image2 = image
                .adjust()
                .outputSize(CGSize(width: 250, height: 250))
                .exclusion(color: UIColor(red: 0, green: 0, blue: 0.352941176, alpha: 1.0))
                .linearDodge(color: UIColor(red: 0.125490196, green: 0.058823529, blue: 0.192156863, alpha: 1.0))
                .hardMix(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
                .image()
            
            guard let image3 = image2!.adjust()
                .append(
                    image1!.adjust()
                        .outputSize(CGSize(width: 250, height: 250))
                        .opacity(0.5)
                )
                .image() else { return UIImage() }
            
            
            return image3 
        }
    }
}
