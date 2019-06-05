//
//  HomeHeaderView.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/11.
//  Copyright © 2018年 mugua. All rights reserved.
//

import UIKit
import Spring

class HomeHeaderView: UIView {


    @IBOutlet weak var button: SpringButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let img = UIImage(named: "lost-places-1549096_1280.jpg")
        
        let result = Pixelate.create(pixels: img!.cgImage!,
                        layers: PixelateLayer(.square, resolution: 48),
                        PixelateLayer(.diamond, resolution: 12, size: 8),
                        PixelateLayer(.diamond, resolution: 12, size: 8, offset: 6))
        imageView.image = UIImage(cgImage: result!)
        
        imageView.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 1).enable()
        
        
    }

}
