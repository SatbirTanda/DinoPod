//
//  ScrollWheelGestureRecognizer.swift
//  DinoPod
//
//  Created by Satbir Tanda on 7/3/15.
//  Copyright (c) 2015 Satbir Tanda. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class ScrollWheelGestureRecognizer: UIGestureRecognizer {
    
    var rotation: CGFloat = 0
    var distance: CGFloat = 0
    private var relativeTouchPoint = CGPointMake(0, 0)
    private let MINIMUM_SECTOR_DISTANCE: CGFloat = 25
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        if event.touchesForGestureRecognizer(self)?.count > 1 {
            state = UIGestureRecognizerState.Failed
        } else {
            if let scrollWheel = view {
                //println("Began:")
                //println("scrollWheel bounds: \(scrollWheel.bounds)")
                if let touch = touches.first  {
                    if touch.locationInView(scrollWheel).x > 0 && touch.locationInView(scrollWheel).y > 0 {
                        //println("touch location in scrollWheel \(touch.locationInView(scrollWheel))")
                        relativeTouchPoint = touch.locationInView(scrollWheel)
                    } else {
                        state = .Failed
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        if state == .Possible {
            state = .Began
        } else {
            state = .Changed
        }
        
        if let scrollWheel = view {
            //println("Changed:")
            //println("scrollWheel bounds: \(scrollWheel.bounds)")
            if let touch = touches.first {
                //println("touch location in scrollWheel \(touch.locationInView(scrollWheel))")
                    distance = 0
                if touch.locationInView(scrollWheel).x > 0 && touch.locationInView(scrollWheel).y > 0 {
                    let center = CGPointMake(CGRectGetMidX(scrollWheel.bounds), CGRectGetMidY(scrollWheel.bounds))
                    let curruentTouchPoint = touch.locationInView(scrollWheel)
                    let previousTouchPoint = touch.previousLocationInView(scrollWheel)
                    
                    let angleInRadians = atan2(curruentTouchPoint.y - center.y, curruentTouchPoint.x - center.x) -
                        atan2(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x)
                    
                    let relativeDistance = sqrt(pow((relativeTouchPoint.x - curruentTouchPoint.x), 2) +
                                                pow((relativeTouchPoint.y - curruentTouchPoint.y), 2))
                    let absDistance = abs(relativeDistance)
                    
                    if absDistance >= MINIMUM_SECTOR_DISTANCE {
                        relativeTouchPoint = curruentTouchPoint
                        distance = absDistance
                        if Int(angleInRadians) == 0 {
                            rotation = angleInRadians
                        }
                    }
                } else {
                    state = .Cancelled
                }
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        if state == .Changed {
            state = .Ended
        } else {
            state = .Failed
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        state = .Failed
    }

}
