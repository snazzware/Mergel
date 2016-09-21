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

open class SNZButtonWidget : SNZWidget {

    open var caption: String = "Untitled"
    open var color: UIColor = UIColor.black
    open var strokeColor: UIColor = UIColor.black
    open var backgroundColor: UIColor = UIColor.white
    open var focusBackgroundColor: UIColor = UIColor.gray
    open var focusColor: UIColor = UIColor.white
    open var cornerRadius:CGFloat = 4
    open var labelSprite: SKLabelNode?
    open var autoSize: Bool = false
    
    fileprivate var _hidden = false
    open var hidden: Bool {
        get {
            return _hidden
        }
        set {
            self._hidden = newValue
            
            self.sprite?.isHidden = self._hidden
        }
    }
    
    public override init() {
        super.init()
        
        self.size = CGSize(width: 200, height: 48)
    }
    
    open override func render() {
        
        self.labelSprite = SKLabelNode(fontNamed: "Avenir-Black")
        self.labelSprite!.text = self.caption
        self.labelSprite!.fontColor = self.color
        self.labelSprite!.fontSize = 20
        self.labelSprite!.horizontalAlignmentMode = .center
        self.labelSprite!.verticalAlignmentMode = .center

        self.labelSprite!.ignoreTouches = true
        
        if (self.autoSize) {
            self.size.width = self.labelSprite!.frame.width + 20
        }

        // Center label
        self.labelSprite!.position = CGPoint(x: ((self.size.width) / 2), y: ((self.size.height) / 2))
        
        let buttonRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let buttonSprite = SKShapeNode(rect: buttonRect, cornerRadius: self.cornerRadius)
        buttonSprite.fillColor = self.backgroundColor
        buttonSprite.strokeColor = self.strokeColor
        buttonSprite.lineWidth = 0
        buttonSprite.position = self.position
        buttonSprite.isHidden = self.hidden
    
        buttonSprite.addChild(self.labelSprite!)
        
        self.sprite = buttonSprite
        
        self.bind("focus",{
            (self.sprite as! SKShapeNode).fillColor = self.focusBackgroundColor
            self.labelSprite?.fontColor = self.focusColor
        });
        
        self.bind("blur",{
            (self.sprite as! SKShapeNode).fillColor = self.backgroundColor
            self.labelSprite?.fontColor = self.color
        });
        
        super.render()
    }
    
    open override func sizeDidChange() {
        if (self.sprite != nil) {
            (self.sprite as! SKShapeNode).path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), cornerWidth: self.cornerRadius, cornerHeight: self.cornerRadius, transform: nil)
            self.labelSprite!.position = CGPoint(x: ((self.size.width) / 2), y: ((self.size.height) / 2))
        }
    }

}
