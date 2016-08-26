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

public class SNZButtonWidget : SNZWidget {

    public var caption: String = "Untitled"
    public var color: UIColor = UIColor.blackColor()
    public var strokeColor: UIColor = UIColor.blackColor()
    public var backgroundColor: UIColor = UIColor.whiteColor()
    public var focusBackgroundColor: UIColor = UIColor.grayColor()
    public var focusColor: UIColor = UIColor.whiteColor()
    public var cornerRadius:CGFloat = 4
    public var labelSprite: SKLabelNode?
    public var autoSize: Bool = false
    
    private var _hidden = false
    public var hidden: Bool {
        get {
            return _hidden
        }
        set {
            self._hidden = newValue
            
            self.sprite?.hidden = self._hidden
        }
    }
    
    public override init() {
        super.init()
        
        self.size = CGSizeMake(200, 48)
    }
    
    public override func render() {
        
        self.labelSprite = SKLabelNode(fontNamed: "Avenir-Black")
        self.labelSprite!.text = self.caption
        self.labelSprite!.fontColor = self.color
        self.labelSprite!.fontSize = 20
        self.labelSprite!.horizontalAlignmentMode = .Center
        self.labelSprite!.verticalAlignmentMode = .Center

        self.labelSprite!.ignoreTouches = true
        
        if (self.autoSize) {
            self.size.width = self.labelSprite!.frame.width + 20
        }

        // Center label
        self.labelSprite!.position = CGPointMake(((self.size.width) / 2), ((self.size.height) / 2))
        
        let buttonRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let buttonSprite = SKShapeNode(rect: buttonRect, cornerRadius: self.cornerRadius)
        buttonSprite.fillColor = self.backgroundColor
        buttonSprite.strokeColor = self.strokeColor
        buttonSprite.lineWidth = 0
        buttonSprite.position = self.position
        buttonSprite.hidden = self.hidden
    
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
    
    public override func sizeDidChange() {
        if (self.sprite != nil) {
            (self.sprite as! SKShapeNode).path = CGPathCreateWithRoundedRect(CGRectMake(0, 0, self.size.width, self.size.height), self.cornerRadius, self.cornerRadius, nil)
            self.labelSprite!.position = CGPointMake(((self.size.width) / 2), ((self.size.height) / 2))
        }
    }

}