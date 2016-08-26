//
//  SNZUIDelegate.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 11/13/15.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

public class SNZUIDelegate : UIResponder {
    public static let instance = SNZUIDelegate()
    
    public var focusStack = [UIResponder]()

    public func focus(target: UIResponder) {
        if (self.focusStack.indexOf(target) != nil) {
            self.focusStack.removeAtIndex(self.focusStack.indexOf(target)!)
            self.focusStack.append(target)
        } else {
            self.focusStack.append(target)
        }
    }
    
    public func blur(target: UIResponder) {
        if (self.focusStack.indexOf(target) != nil) {
            self.focusStack.removeAtIndex(self.focusStack.indexOf(target)!)
        }
    }

    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.focusStack.count>0) {
            let target = self.focusStack.last
        
            target?.touchesBegan(touches, withEvent: event)
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.focusStack.count>0) {
            let target = self.focusStack.last
        
            target?.touchesEnded(touches, withEvent: event)
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.focusStack.count>0) {
            let target = self.focusStack.last
        
            target?.touchesMoved(touches, withEvent: event)
        }
    }
    
    public func panGesture(sender: UIPanGestureRecognizer) {
        
    }

}

public extension SKNode {
    var ignoreTouches: Bool {
        get {
            let result = self.userData?.valueForKey("SNZIgnoreTouches")
            if (result != nil) {
                return result as! Bool
            } else {
                return false
            }
        }
        set {
            if (self.userData == nil) {
                self.userData = NSMutableDictionary()
            }
            self.userData?.setValue(newValue, forKey: "SNZIgnoreTouches")
        }
    }
}