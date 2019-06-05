//
//  HomePhotoCell.swift
//  PixelWorld
//
//  Created by mugua on 2018/10/11.
//  Copyright © 2018年 mugua. All rights reserved.
//

import UIKit
import ChameleonFramework
import Spring

class HomePhotoCell: UICollectionViewCell {

    @IBOutlet weak var bkView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoView: SpringImageView!
    
    private let formatter = DateFormatter()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 8
                layer.borderColor = UIColor.randomFlat.cgColor
                photoView.curve = "pop"
                photoView.animation = "spring"
                photoView.duration = 1.0
                photoView.scaleY = 2
                photoView.scaleX = 2
                photoView.animate()
            } else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bkView.backgroundColor = UIColor.randomFlat
    }

    func configure(withDataSource dataSource: HomePhotoCellDataSource)
    {
        descriptionLabel.text = "\(dataSource.title)\n\(dateToString(dataSource.createdTime))"
        photoView.image = UIImage(data: dataSource.imageValue)
        
    }
    
    private func dateToString(_ date: Date) -> String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
}


