//
//  SNZScene.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 1/29/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

public class SNZScene : SKScene {

    public var widgets = [SNZWidget]()
    public var focusedWidget: SNZWidget?
    
    var panRecognizer:UIPanGestureRecognizer?
    
    public override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // Create pan gesture recognizer
        if (self.panRecognizer == nil) {
            self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SNZScene.panGesture(_:)))
            
            // Don't cancel touches in view, so we can still get touchesMoved events
            self.panRecognizer!.cancelsTouchesInView = false
        }
        
        // Add gesture recognizers to view
        if (self.panRecognizer != nil) {
            view.addGestureRecognizer(self.panRecognizer!)
        }
    }
    
    public override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        
        // Remove gesture recogniers from view
        if (self.panRecognizer != nil) {
            view.removeGestureRecognizer(self.panRecognizer!)
        }
    }
    
    public func panGesture(sender: UIPanGestureRecognizer) {
        if (self.focusedWidget != nil && self.focusedWidget!.wantsPanGestures) {
            self.focusedWidget!.panGesture(sender)
        }
    }
    
    public func addWidget(widget: SNZWidget) {
        self.widgets.append(widget)
        if (widget.parentNode == nil) {
            widget.parentNode = self
        }
    }
    
    public func renderWidgets() {
        for widget in self.widgets {
            widget.render()
        }
    }
    
    public func getWidgets(named: String) -> [SNZWidget] {
        return self.widgets.filter({
            $0.name == named
        })
    }
    
    public func updateWidgets() {
        for widget in self.widgets {
            widget.anchor()
        }
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.widgetTouchesBegan(touches, withEvent: event)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        self.widgetTouchesMoved(touches, withEvent: event)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    
        self.widgetTouchesEnded(touches, withEvent: event)
    }
    
    public func widgetTouchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
        var handled = false
        
        for touch in touches {
            for touchedNode in self.nodesAtPoint(touch.locationInNode(self)) {
                var deeperTouch = touchedNode
            
                // determine actual sprite we should consider touched
                while (deeperTouch.ignoreTouches && deeperTouch.parent != nil) {
                    deeperTouch = deeperTouch.parent!
                }
                
                // see if the sprite belongs to any of our widgets
                for widget in self.widgets {
                    if (widget.touchableSprite != nil && widget.touchableSprite == deeperTouch) {
                        if (self.focusedWidget != nil) {
                            if (self.focusedWidget!.touchableSprite != deeperTouch) {
                                self.focusedWidget!.trigger("blur")
                                widget.trigger("focus")
                                self.focusedWidget = widget
                            }
                        } else {
                            widget.trigger("focus")
                            self.focusedWidget = widget
                        }
                        
                        handled = true
                        break
                    }
                }
            }
        }
        
        if (!handled) {
            if (self.focusedWidget != nil) {
                self.focusedWidget!.trigger("blur")
                self.focusedWidget = nil
            }
        }
        
        return handled
    }
    
    public func widgetTouchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
        return self.widgetTouchesBegan(touches, withEvent: event)
    }
    
    public func widgetTouchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
        var handled = false
        
        if (self.focusedWidget != nil) {
            self.focusedWidget!.trigger("blur")
        
            for touch in touches {
                for touchedNode in self.nodesAtPoint(touch.locationInNode(self)) {
                    var deeperTouch = touchedNode
                
                    // determine actual sprite we should consider touched
                    while (deeperTouch.ignoreTouches && deeperTouch.parent != nil) {
                        deeperTouch = deeperTouch.parent!
                    }
                    
                    // is the sprite the same one we started touching in touchesBegan?
                    if (self.focusedWidget!.sprite == deeperTouch) {
                        self.focusedWidget!.trigger("tap")
                        
                        handled = true
                        break
                    }
                }
            }
            
            self.focusedWidget = nil
        }
        
        return handled
    }
    
    
}