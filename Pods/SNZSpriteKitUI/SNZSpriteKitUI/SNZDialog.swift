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

typealias Proc = () -> ()

class SNZDialog : SNZWidget {

    var widgets = [SNZWidget]()
    var focusedWidget: SNZWidget?
    
    func addWidget(_ widget: SNZWidget) {
        self.widgets.append(widget)
    }
    
    func initWidgets() {
        let context = self
        
        let closeButton = SNZButtonWidget(parentNode: self.sprite!)
        closeButton.caption = "X"
        closeButton.bind("tap",{
            print("tap on close button")
            print("context is \(context)")
            context.close()
        });
        closeButton.size = CGSize(width: 64,height: 64)
        closeButton.position = CGPoint(x: self.size.width-32, y: self.size.height-32)
        self.addWidget(closeButton)
    }
    
    override func render() {
        self.sprite = SKSpriteNode(color: UIColor.darkGray, size:self.size)
        
        self.sprite?.position = self.position
        self.sprite?.zPosition = 9999
        
        self.initWidgets()
        
        super.render()
    }
    
    func open() {
        SNZUIDelegate.instance.focus(self)
        
        self.render();
        
        for widget in self.widgets {
            widget.render()
        }
        
        self.trigger("open")
    }
    
    func close() {
        SNZUIDelegate.instance.blur(self)
    
        self.hide();
    
        self.trigger("close")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var handled = false
        
        for touch in touches {
            let location = touch.location(in: self.sprite!)
            var touchedNode = self.sprite!.atPoint(location)
            
            // determine actual sprite we should consider touched
            while (touchedNode.ignoreTouches && touchedNode.parent != nil) {
                touchedNode = touchedNode.parent!
            }
            
            // see if the sprite belongs to any of our widgets
            for widget in self.widgets {
                if (widget.sprite != nil && widget.sprite == touchedNode) {
                    if (self.focusedWidget != nil) {
                        if (self.focusedWidget!.sprite != touchedNode) {
                            self.focusedWidget!.trigger("blur")
                            widget.trigger("focus")
                            self.focusedWidget = widget
                        }
                        
                        handled = true
                    } else {
                        widget.trigger("focus")
                        self.focusedWidget = widget
                        
                        handled = true
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
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {        
        if (self.focusedWidget != nil) {
            self.focusedWidget!.trigger("blur")
        
            for touch in touches {
                let location = touch.location(in: self.sprite!)
                var touchedNode = self.sprite!.atPoint(location)
                
                // determine actual sprite we should consider touched
                while (touchedNode.ignoreTouches && touchedNode.parent != nil) {
                    touchedNode = touchedNode.parent!
                }
                
                // is the sprite the same one we started touching in touchesBegan?
                if (self.focusedWidget!.sprite == touchedNode) {
                    self.focusedWidget!.trigger("tap")
                }
            }
            
            self.focusedWidget = nil
        }
    }
}
