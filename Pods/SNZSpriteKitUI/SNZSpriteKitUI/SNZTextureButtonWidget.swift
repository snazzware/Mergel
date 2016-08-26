//
//  SNZTextureButtonWidget.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/9/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

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

public class SNZTextureButtonWidget : SNZWidget {

    public var texture: SKTexture?
    public var selectedTexture: SKTexture?
    public var color: UIColor = UIColor.blackColor()
    public var strokeColor: UIColor = UIColor.blackColor()
    public var backgroundColor: UIColor = UIColor.clearColor()
    public var focusBackgroundColor: UIColor = UIColor.grayColor()
    public var focusColor: UIColor = UIColor.whiteColor()
    public var cornerRadius:CGFloat = 4
    public var autoSize: Bool = false
    public var textureScale:CGFloat = 1.0
    
    public var textureSprite: SKSpriteNode?
    
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
    
    override public init() {
        super.init()
        
        self.size = CGSizeMake(64, 64)
    }
    
    public override func render() {
        
        // Center label
        let buttonRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let buttonSprite = SKShapeNode(rect: buttonRect, cornerRadius: self.cornerRadius)
        buttonSprite.fillColor = self.backgroundColor
        buttonSprite.strokeColor = self.strokeColor
        buttonSprite.lineWidth = 0
        buttonSprite.position = self.position
        buttonSprite.hidden = self.hidden
    
        self.textureSprite = SKSpriteNode(texture: self.texture)
        self.textureSprite!.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        self.textureSprite!.ignoreTouches = true
        self.textureSprite!.size = CGSizeMake(
            self.size.width - SNZSpriteKitUITheme.instance.uiInnerMargins.left - SNZSpriteKitUITheme.instance.uiInnerMargins.right,
            self.size.height - SNZSpriteKitUITheme.instance.uiInnerMargins.top - SNZSpriteKitUITheme.instance.uiInnerMargins.bottom
        )
        self.textureSprite!.setScale(self.textureScale)
    
        buttonSprite.addChild(self.textureSprite!)
        
        self.sprite = buttonSprite
        
        self.bind("focus",{
            (self.sprite as! SKShapeNode).fillColor = self.focusBackgroundColor
        });
        
        self.bind("blur",{
            (self.sprite as! SKShapeNode).fillColor = self.backgroundColor
        });
        
        super.render()
    }

}