//
//  ImageCollectionViewCell.swift
//  DinoPod
//
//  Created by Satbir Tanda on 8/2/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .ScaleAspectFit
        }
    }
    
    var imageName: String = ""
}
