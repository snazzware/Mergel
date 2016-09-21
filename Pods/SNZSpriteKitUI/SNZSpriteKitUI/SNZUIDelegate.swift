//
//  SNZUIDelegate.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 11/13/15.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

open class SNZUIDelegate : UIResponder {
    open static let instance = SNZUIDelegate()
    
    open var focusStack = [UIResponder]()

    open func focus(_ target: UIResponder) {
        if (self.focusStack.index(of: target) != nil) {
            self.focusStack.remove(at: self.focusStack.index(of: target)!)
            self.focusStack.append(target)
        } else {
            self.focusStack.append(target)
        }
    }
    
    open func blur(_ target: UIResponder) {
        if (self.focusStack.index(of: target) != nil) {
            self.focusStack.remove(at: self.focusStack.index(of: target)!)
        }
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.focusStack.count>0) {
            let target = self.focusStack.last
        
            target?.touchesBegan(touches, with: event)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.focusStack.count>0) {
            let target = self.focusStack.last
        
            target?.touchesEnded(touches, with: event)
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.focusStack.count>0) {
            let target = self.focusStack.last
        
            target?.touchesMoved(touches, with: event)
        }
    }
    
    open func panGesture(_ sender: UIPanGestureRecognizer) {
        
    }

}

public extension SKNode {
    var ignoreTouches: Bool {
        get {
            let result = self.userData?.value(forKey: "SNZIgnoreTouches")
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
