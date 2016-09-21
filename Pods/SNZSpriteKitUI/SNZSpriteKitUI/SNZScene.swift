//
//  SNZScene.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 1/29/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

open class SNZScene : SKScene {

    open var widgets = [SNZWidget]()
    open var focusedWidget: SNZWidget?
    
    var panRecognizer:UIPanGestureRecognizer?
    
    open override func didMove(to view: SKView) {
        super.didMove(to: view)
        
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
    
    open override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        // Remove gesture recogniers from view
        if (self.panRecognizer != nil) {
            view.removeGestureRecognizer(self.panRecognizer!)
        }
    }
    
    open func panGesture(_ sender: UIPanGestureRecognizer) {
        if (self.focusedWidget != nil && self.focusedWidget!.wantsPanGestures) {
            self.focusedWidget!.panGesture(sender)
        }
    }
    
    open func addWidget(_ widget: SNZWidget) {
        self.widgets.append(widget)
        if (widget.parentNode == nil) {
            widget.parentNode = self
        }
    }
    
    open func renderWidgets() {
        for widget in self.widgets {
            widget.render()
        }
    }
    
    open func getWidgets(_ named: String) -> [SNZWidget] {
        return self.widgets.filter({
            $0.name == named
        })
    }
    
    open func updateWidgets() {
        for widget in self.widgets {
            widget.anchor()
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.widgetTouchesBegan(touches, withEvent: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        self.widgetTouchesMoved(touches, withEvent: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        self.widgetTouchesEnded(touches, withEvent: event)
    }
    
    open func widgetTouchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
        var handled = false
        
        for touch in touches {
            for touchedNode in self.nodes(at: touch.location(in: self)) {
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
    
    open func widgetTouchesMoved(_ touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
        return self.widgetTouchesBegan(touches, withEvent: event)
    }
    
    open func widgetTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) -> Bool {
        var handled = false
        
        if (self.focusedWidget != nil) {
            self.focusedWidget!.trigger("blur")
        
            for touch in touches {
                for touchedNode in self.nodes(at: touch.location(in: self)) {
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
