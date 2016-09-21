//
//  SNZCheckButtonWidget.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/3/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

open class SNZCheckButtonWidget : SNZButtonWidget {

    var _isChecked = false
    open var isChecked:Bool {
        get {
            return self._isChecked
        }
        set {
            self._isChecked = newValue
            
            self.checkboxSprite?.texture = self.isChecked ? self.checkedTexture : self.uncheckedTexture
        }
    }
    open var checkboxSprite: SKSpriteNode?
    
    open var checkedTexture: SKTexture?
    open var uncheckedTexture: SKTexture?
    
    public override init() {
        super.init()
        
        self.size = CGSize(width: 248, height: 48)
        
        //self.checkedTexture = SKTextureAtlas.textureNamed(<#T##SKTextureAtlas#>)
        
        self.checkedTexture = SNZSpriteKitUITheme.instance.textures.textureNamed("checkboxChecked")
        self.uncheckedTexture = SNZSpriteKitUITheme.instance.textures.textureNamed("checkboxUnchecked")
    }
    
    override open func render() {
        super.render()
        
        self.labelSprite!.horizontalAlignmentMode = .left
        self.labelSprite!.position.x = 60
        
        self.checkboxSprite = SKSpriteNode(texture: self.isChecked ? self.checkedTexture : self.uncheckedTexture)
        self.checkboxSprite!.position = CGPoint(x: 26,y: 23)
        self.checkboxSprite!.size = CGSize(width: 32,height: 32)
        self.checkboxSprite!.ignoreTouches = true
        self.sprite!.addChild(self.checkboxSprite!)
        
        self.bind("tap",{
            self.isChecked = !self.isChecked
        })
    }

}
