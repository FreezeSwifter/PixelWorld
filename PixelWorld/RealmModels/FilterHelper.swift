//
//  FilterHelper.swift
//  PixelWorld
//
//  Created by mugua on 2019/6/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import FlexibleImage

enum FilterHelper: Int, CustomStringConvertible {
    
    case buffing = 0
    case liquidation
    case rhombus
    case fissured
    case Oil
    case telescopic
    case electronization
    case gasify
    case wood
    case mix
    
    var description: String {
        switch self {
        case .buffing:
            return "Buffing"
        case .liquidation:
            return "Liquidation"
        case .rhombus:
            return "Rhombus"
        case .fissured:
            return "Fissured"
        case .Oil:
            return "Oil"
        case .telescopic:
            return "Telescopic"
        case .electronization:
            return "Electronization"
        case .gasify:
            return "Gasify"
        case .wood:
            return "Wood"
        case .mix:
            return "Hard Mix"
        }
    }
    
    func getFilter(image: UIImage) -> UIImage {
        switch self {
        case .buffing:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.square, resolution: 48),
                                       PixelateLayer(.diamond, resolution: 12, size: 8),
                                       PixelateLayer(.diamond, resolution: 12, size: 8, offset: 6))
            return UIImage(cgImage: temp!)
        case .liquidation:
            let temp = Pixelate.create(pixels:  image.cgImage!,
                                       layers: PixelateLayer(.square, resolution: 32),
                                       PixelateLayer(.circle, resolution: 32, offset: 15),
                                       PixelateLayer(.circle, resolution: 32, size: 26, offset: 13),
                                       PixelateLayer(.circle, resolution: 32, size: 18, offset: 10),
                                       PixelateLayer(.circle, resolution: 32, size: 12, offset: 8))
            return UIImage(cgImage: temp!)
            
        case .rhombus:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.square, resolution: 48),
                                       PixelateLayer(.diamond, resolution: 48, offset: 12, alpha: 0.5),
                                       PixelateLayer(.diamond, resolution: 48, offset: 36, alpha: 0.5),
                                       PixelateLayer(.diamond, resolution: 16, size: 8, offset: 4))
            return UIImage(cgImage: temp!)
            
        case .fissured:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.circle, resolution: 32, size: 6, offset: 8),
                                       PixelateLayer(.circle, resolution: 32, size: 9, offset: 8),
                                       PixelateLayer(.circle, resolution: 32, size: 12, offset: 24),
                                       PixelateLayer(.circle, resolution: 32, size: 9, offset: 0))
            return UIImage(cgImage: temp!)
            
        case .Oil:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.diamond, resolution: 24, size: 25),
                                       PixelateLayer(.diamond, resolution: 24, offset: 12),
                                       PixelateLayer(.square, resolution: 24, alpha: 0.6))
            return UIImage(cgImage: temp!)
            
        case .telescopic:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.square, resolution: 32),
                                       PixelateLayer(.circle, resolution: 32, offset: 16),
                                       PixelateLayer(.circle, resolution: 32, offset: 0, alpha: 0.5),
                                       PixelateLayer(.circle, resolution: 16, size: 9, offset: 0, alpha: 0.5))
            return UIImage(cgImage: temp!)
            
        case .electronization:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.circle, resolution: 24),
                                       PixelateLayer(.circle, resolution: 24, size: 9, offset: 12))
            
            return UIImage(cgImage: temp!)
            
        case .gasify:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.square, resolution: 48, offset: 12),
                                       PixelateLayer(.circle, resolution: 48, offset: 0),
                                       PixelateLayer(.diamond, resolution: 16, size: 15, offset: 0, alpha: 0.6),
                                       PixelateLayer(.diamond, resolution: 16, size: 15, offset: 8, alpha: 0.6))
            
            return UIImage(cgImage: temp!)
            
        case .wood:
            let temp = Pixelate.create(pixels: image.cgImage!,
                                       layers: PixelateLayer(.square, resolution: 48),
                                       PixelateLayer(.diamond, resolution: 12, size: 8),
                                       PixelateLayer(.diamond, resolution: 12, size: 8, offset: 6))
            
            return UIImage(cgImage: temp!)
            
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
