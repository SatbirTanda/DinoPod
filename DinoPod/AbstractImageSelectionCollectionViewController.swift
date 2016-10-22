//
//  AbstractSelectionImageCollectionViewController.swift
//  DinoPod
//
//  Created by Satbir Tanda on 8/3/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AbstractImageSelectionCollectionViewController: UICollectionViewController {

    var imageNames : [String] {
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return imageNames.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image Cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        // Configure the cell

        let imageName = imageNames[indexPath.row]
        cell.imageName = imageName
        if let image = UIImage(named: imageName) {
            cell.imageView.image = image
        }
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor.lightGrayColor()
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateLayout
    
    private struct SizeConstants {
        static let Width: CGFloat = 75
        static let Height: CGFloat = 75
    }
    
    private struct EdgeInsets {
        static let Top: CGFloat = 50.0
        static let Left: CGFloat = 20.0
        static let Bottom: CGFloat = 50.0
        static let Right: CGFloat = 20.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: SizeConstants.Width, height: SizeConstants.Height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: EdgeInsets.Top, left: EdgeInsets.Left, bottom: EdgeInsets.Bottom, right: EdgeInsets.Right)
        return sectionInsets
    }
    
}
