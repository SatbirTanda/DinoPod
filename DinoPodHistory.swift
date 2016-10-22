//
//  DinoPodHistory.swift
//  DinoPod
//
//  Created by Satbir Tanda on 8/7/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import Foundation
import UIKit

class DinoPodHistory {
    
    private struct Keys {
        static let DinoPodColor = "DinoPod Color"
        static let ScrollWheelImage = "Scroll Wheel Image"
        static let MenuButtonImage = "Menu Button Image"
        static let ForwardButtonImage = "Forward Button Image"
        static let PlayPauseButtonImage = "Play Pause Button Image"
        static let RewindButtonImage = "Rewind Button Image"
        static let Repeat = "Repeat"
        static let Shuffle = "Shuffle"
    }
    
    class func setDinoPodColor(color: UIColor?) {
        NSUserDefaults.standardUserDefaults().setColor(color, key: Keys.DinoPodColor)
    }
    
    class func getDinoPodColor() -> UIColor? {
        return NSUserDefaults.standardUserDefaults().colorForKey(Keys.DinoPodColor)
    }
    
    class func setScrollWheelImage(name: String) {
        NSUserDefaults.standardUserDefaults().setImage(name, key: Keys.ScrollWheelImage)
    }
    
    class func getScrollWheelImage() -> UIImage? {
        return NSUserDefaults.standardUserDefaults().imageForKey(Keys.ScrollWheelImage)
    }
    
    class func setMenuButtonImage(name: String) {
        NSUserDefaults.standardUserDefaults().setImage(name, key: Keys.MenuButtonImage)
    }
    
    class func getMenuButtonImage() -> UIImage? {
        return NSUserDefaults.standardUserDefaults().imageForKey(Keys.MenuButtonImage)

    }
    
    class func setForwardButtonImage(name: String) {
        NSUserDefaults.standardUserDefaults().setImage(name, key: Keys.ForwardButtonImage)
    }
    
    class func getForwardButtonImage() -> UIImage? {
        return NSUserDefaults.standardUserDefaults().imageForKey(Keys.ForwardButtonImage)

    }
    
    class func setPlayPauseButtonImage(name: String) {
        NSUserDefaults.standardUserDefaults().setImage(name, key: Keys.PlayPauseButtonImage)
    }
    
    class func getPlayPauseButtonImage() -> UIImage? {
        return NSUserDefaults.standardUserDefaults().imageForKey(Keys.PlayPauseButtonImage)

    }
    
    class func setRewindButtonImage(name: String) {
        NSUserDefaults.standardUserDefaults().setImage(name, key: Keys.RewindButtonImage)
    }
    
    class func getRewindButtonImage() -> UIImage? {
        return NSUserDefaults.standardUserDefaults().imageForKey(Keys.RewindButtonImage)

    }
    
    class func setRepeat(bool: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(bool, forKey: Keys.Repeat)
    }
    
    class func getRepeat()  -> Bool {
        let option = NSUserDefaults.standardUserDefaults().boolForKey(Keys.Repeat)
        return option
    }
    
    class func setShuffle(bool: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(bool, forKey: Keys.Shuffle)
    }
    
    class func getShuffle() -> Bool {
        let option = NSUserDefaults.standardUserDefaults().boolForKey(Keys.Shuffle)
        return option
    }
    
}

private extension NSUserDefaults {
    func setColor(color: UIColor?, key: String) {
        if color != nil {
            let colorData = NSKeyedArchiver.archivedDataWithRootObject(color!)
            self.setObject(colorData, forKey: key)
        }
    }
    
    func colorForKey(key: String) -> UIColor? {
        if let colorData = NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSData {
            if let color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor {
                 return color
            }
        }
        return nil
    }
    
    func setImage(name: String, key: String) {
        self.setObject(name, forKey: key)
    }
    
    func imageForKey(key: String) -> UIImage? {
        if let imageName = NSUserDefaults.standardUserDefaults().objectForKey(key) as? String {
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        return nil
    }
}