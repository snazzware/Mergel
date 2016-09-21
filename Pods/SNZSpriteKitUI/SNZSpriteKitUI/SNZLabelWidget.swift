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

open class SNZLabelWidget : SNZWidget {

    open var caption: String = "Untitled"
    open var color: UIColor = SNZSpriteKitUITheme.instance.labelColor
    open var backgroundColor: UIColor = SNZSpriteKitUITheme.instance.labelBackground
    
    open var labelSprite: SKLabelNode?
    
    override public init() {
        super.init()
        
        self.size = CGSize(width: 200, height: 48)
    }
    
    override open func render() {
        self.labelSprite = SKLabelNode(fontNamed: "Avenir-Black")
        self.labelSprite!.text = self.caption
        self.labelSprite!.fontColor = self.color
        self.labelSprite!.fontSize = 20
        self.labelSprite!.horizontalAlignmentMode = .left
        self.labelSprite!.verticalAlignmentMode = .bottom
        self.labelSprite!.position = CGPoint(x: SNZSpriteKitUITheme.instance.uiInnerMargins.left, y: SNZSpriteKitUITheme.instance.uiInnerMargins.bottom)
        self.labelSprite!.ignoreTouches = true
        
        // Automatically resize
        self.size.width = self.labelSprite!.frame.size.width + SNZSpriteKitUITheme.instance.uiInnerMargins.horizontal
        self.size.height = self.labelSprite!.frame.size.height + SNZSpriteKitUITheme.instance.uiInnerMargins.vertical
        
        let frameRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
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
