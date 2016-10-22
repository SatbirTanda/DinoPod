//
//  ColorCollectionViewCell.swift
//  DinoPod
//
//  Created by Satbir Tanda on 8/2/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
    
    var color: UIColor = UIColor.clearColor() {
        didSet {
           colorView.backgroundColor = color
        }
    }
    
}

