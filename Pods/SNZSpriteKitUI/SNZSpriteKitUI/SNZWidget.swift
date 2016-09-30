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

open class SNZWidget : SNZEventReceiver {

    open var parentNode: SKNode?
    open var sprite: SKNode?
    
    fileprivate var _touchableSprite: SKNode?
    open var touchableSprite: SKNode? {
        get {
            return self._touchableSprite == nil ? self.sprite : self._touchableSprite
        }
        set {
            self._touchableSprite = newValue
        }
    }
    
    open var name: String = "Untitled"
    
    open var wantsPanGestures = false
    
    fileprivate var _size: CGSize = CGSize(width: 500,height: 200)
    open var size: CGSize {
        get {
            return self._size
        }
        set {
            self._size = newValue
            self.sizeDidChange()
        }
    }
    
    fileprivate var _position: CGPoint = CGPoint(x: 100,y: 100)
    open var position: CGPoint {
        get {
            return self._position
        }
        set {
            self._position = newValue
            self.sprite?.position = self._position
        }
    }
    
    fileprivate var _anchorPoint: CGPoint?
    open var anchorPoint:CGPoint? {
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
    
    open func sizeDidChange() {
        
    }
    
    open func render() {
        if (self.sprite != nil) {
            self.parentNode?.addChild(self.sprite!)
        }
        
        self.anchor()
    }
    
    open func hide() {
        if (self.sprite != nil) {
            self.sprite!.removeFromParent();
        }
    }
    
    /**
        Calculates position for the widget's sprite, based on anchorPoint, relative to parent container and respecting current theme margins
    */
    open func anchor() {
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
        
        self.position = CGPoint(x: x,y: y)
    }
    
    open func panGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        
        print(translation)
        
        //sender.setTranslation(CGPointZero, inView: sender.view!)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}
