//
//  AboutHeaderView.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/11.
//  Copyright © 2018年 mugua. All rights reserved.
//

import UIKit

class AboutHeaderView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let img = UIImage(named: "road-949832_1280.jpg")
        
        let result = Pixelate.create(pixels: img!.cgImage!,
                                     layers: PixelateLayer(.circle, resolution: 24),
                                     PixelateLayer(.circle, resolution: 24, size: 9, offset: 12))
        image.image = UIImage(cgImage: result!)
        
        image.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 1).enable()
    }

}
