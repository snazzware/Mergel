//
//  SNZDialog.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 11/13/15.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public typealias SNZEventHandler = () -> ()

public class SNZWidget : UIResponder {
    // Dictionary of events
    public var events = [String: [String: SNZEventHandler]]()
    
    public var parentNode: SKNode?
    public var sprite: SKNode?
    
    private var _touchableSprite: SKNode?
    public var touchableSprite: SKNode? {
        get {
            return self._touchableSprite == nil ? self.sprite : self._touchableSprite
        }
        set {
            self._touchableSprite = newValue
        }
    }
    
    public var name: String = "Untitled"
    
    public var wantsPanGestures = false
    
    private var _size: CGSize = CGSizeMake(500,200)
    public var size: CGSize {
        get {
            return self._size
        }
        set {
            self._size = newValue
            self.sizeDidChange()
        }
    }
    
    private var _position: CGPoint = CGPointMake(100,100)
    public var position: CGPoint {
        get {
            return self._position
        }
        set {
            self._position = newValue
            self.sprite?.position = self._position
        }
    }
    
    private var _anchorPoint: CGPoint?
    public var anchorPoint:CGPoint? {
        get {
            return self._anchorPoint
        }
        set {
            self._anchorPoint = newValue
            
            self.anchor()
        }
    }
    
    public convenience init(parentNode: SKNode) {        
        self.init()
        
        self.parentNode = parentNode
    }
    
    override public init() {
        super.init()
    }
    
    /**
        Bind a handler to a named event
    */
    public func bind(event: String, _ handler: SNZEventHandler) {
        self.bind(event, handler, forKey: NSUUID().UUIDString)
    }
    
    /**
        Bind a handler to a named event with a given key
    */
    public func bind(event: String, _ handler: SNZEventHandler, forKey: String) {
        if (self.events[event] == nil) {
            self.events[event] = [String: SNZEventHandler]()
        }
        self.events[event]![forKey] = handler
    }
    
    /**
        Unbinds a handler from a named event for a given key, or all handlers for the named event if no key is specified.
    */
    public func unbind(event: String, _ key: String? = nil) {
        if (key == nil) {
            self.events[event]?.removeAll()
        } else {
            self.events[event]?.removeValueForKey(key!)
        }
    }
    
    /**
        Trigger handler(s) for a named event.
    */
    public func trigger(event: String) {
        if (self.events[event] != nil) {
            for (_, handler) in self.events[event]! {
                handler()
            }
        }
    }
    
    public func sizeDidChange() {
        
    }
    
    public func render() {
        if (self.sprite != nil) {
            self.parentNode?.addChild(self.sprite!)
        }
        
        self.anchor()
    }
    
    public func hide() {
        if (self.sprite != nil) {
            self.sprite!.removeFromParent();
        }
    }
    
    /**
        Calculates position for the widget's sprite, based on anchorPoint, relative to parent container and respecting current theme margins
    */
    public func anchor() {
        if (self._anchorPoint == nil || self.parentNode == nil || self.sprite == nil || self.sprite!.scene == nil || self.sprite!.scene!.view == nil) {
            return
        }
        
        var width = self.parentNode!.frame.width
        var height = self.parentNode!.frame.height
        
        if (width == 0 || height == 0) {
            width = (self.sprite!.scene?.view?.frame.width)!
            height = (self.sprite!.scene?.view?.frame.height)!
        }
        
        var x = self.position.x
        var y = self.position.y
        
        // Determine horizontal position
        if (self._anchorPoint!.x == 1) { // right-align
            x = (width * self._anchorPoint!.x) - self.size.width - SNZSpriteKitUITheme.instance.uiOuterMargins.right
        } else
        if (self._anchorPoint!.x == 0) { // left-align
            x = 0 + SNZSpriteKitUITheme.instance.uiOuterMargins.left
        } else { // center on width times anchoring
            x = (width * self._anchorPoint!.x) - (self.size.width/2)
        }
        
        // Determine vertical position
        if (self._anchorPoint!.y == 1) { // top-align
            y = (height * self._anchorPoint!.y) - self.size.height - SNZSpriteKitUITheme.instance.uiOuterMargins.top
        } else
        if (self._anchorPoint!.y == 0) { // bottom-align
            y = 0 + SNZSpriteKitUITheme.instance.uiOuterMargins.bottom
        } else { // center on height times anchoring
            y = (height * self._anchorPoint!.y) - (self.size.height/2)
        }
        
        self.position = CGPointMake(x,y)
    }
    
    public func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!)
        
        print(translation)
        
        //sender.setTranslation(CGPointZero, inView: sender.view!)
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }

}