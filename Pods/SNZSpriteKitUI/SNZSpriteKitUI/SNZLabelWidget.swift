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

public class SNZLabelWidget : SNZWidget {

    public var caption: String = "Untitled"
    public var color: UIColor = SNZSpriteKitUITheme.instance.labelColor
    public var backgroundColor: UIColor = SNZSpriteKitUITheme.instance.labelBackground
    
    public var labelSprite: SKLabelNode?
    
    override public init() {
        super.init()
        
        self.size = CGSizeMake(200, 48)
    }
    
    override public func render() {
        self.labelSprite = SKLabelNode(fontNamed: "Avenir-Black")
        self.labelSprite!.text = self.caption
        self.labelSprite!.fontColor = self.color
        self.labelSprite!.fontSize = 20
        self.labelSprite!.horizontalAlignmentMode = .Left
        self.labelSprite!.verticalAlignmentMode = .Bottom
        self.labelSprite!.position = CGPointMake(SNZSpriteKitUITheme.instance.uiInnerMargins.left, SNZSpriteKitUITheme.instance.uiInnerMargins.bottom)
        self.labelSprite!.ignoreTouches = true
        
        // Automatically resize
        self.size.width = self.labelSprite!.frame.size.width + SNZSpriteKitUITheme.instance.uiInnerMargins.horizontal
        self.size.height = self.labelSprite!.frame.size.height + SNZSpriteKitUITheme.instance.uiInnerMargins.vertical
        
        let frameRect = CGRectMake(0, 0, self.size.width, self.size.height)
        
        let frameSprite = SKShapeNode(rect: frameRect)
        frameSprite.fillColor = self.backgroundColor
        frameSprite.position = self.position
        frameSprite.lineWidth = 0
        frameSprite.ignoreTouches = true
    
        frameSprite.addChild(self.labelSprite!)
        
        self.sprite = frameSprite
        
        super.render()
    }    

}