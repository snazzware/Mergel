//
//  SNZCheckButtonWidget.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/3/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

public class SNZCheckButtonWidget : SNZButtonWidget {

    var _isChecked = false
    public var isChecked:Bool {
        get {
            return self._isChecked
        }
        set {
            self._isChecked = newValue
            
            self.checkboxSprite?.texture = self.isChecked ? self.checkedTexture : self.uncheckedTexture
        }
    }
    public var checkboxSprite: SKSpriteNode?
    
    public var checkedTexture: SKTexture?
    public var uncheckedTexture: SKTexture?
    
    public override init() {
        super.init()
        
        self.size = CGSizeMake(248, 48)
        
        //self.checkedTexture = SKTextureAtlas.textureNamed(<#T##SKTextureAtlas#>)
        
        self.checkedTexture = SNZSpriteKitUITheme.instance.textures.textureNamed("checkboxChecked")
        self.uncheckedTexture = SNZSpriteKitUITheme.instance.textures.textureNamed("checkboxUnchecked")
    }
    
    override public func render() {
        super.render()
        
        self.labelSprite!.horizontalAlignmentMode = .Left
        self.labelSprite!.position.x = 60
        
        self.checkboxSprite = SKSpriteNode(texture: self.isChecked ? self.checkedTexture : self.uncheckedTexture)
        self.checkboxSprite!.position = CGPointMake(26,23)
        self.checkboxSprite!.size = CGSizeMake(32,32)
        self.checkboxSprite!.ignoreTouches = true
        self.sprite!.addChild(self.checkboxSprite!)
        
        self.bind("tap",{
            self.isChecked = !self.isChecked
        })
    }

}