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
        
        imageView.clipsToBounds = true
        
    }

}
