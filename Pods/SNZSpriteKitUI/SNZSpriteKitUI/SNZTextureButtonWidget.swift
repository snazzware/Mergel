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

open class SNZTextureButtonWidget : SNZWidget {

    open var texture: SKTexture?
    open var selectedTexture: SKTexture?
    open var color: UIColor = UIColor.black
    open var strokeColor: UIColor = UIColor.black
    open var backgroundColor: UIColor = UIColor.clear
    open var focusBackgroundColor: UIColor = UIColor.gray
    open var focusColor: UIColor = UIColor.white
    open var cornerRadius:CGFloat = 4
    open var autoSize: Bool = false
    open var textureScale:CGFloat = 1.0
    
    open var textureSprite: SKSpriteNode?
    
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
    
    override public init() {
        super.init()
        
        self.size = CGSize(width: 64, height: 64)
    }
    
    open override func render() {
        
        // Center label
        let buttonRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let buttonSprite = SKShapeNode(rect: buttonRect, cornerRadius: self.cornerRadius)
        buttonSprite.fillColor = self.backgroundColor
        buttonSprite.strokeColor = self.strokeColor
        buttonSprite.lineWidth = 0
        buttonSprite.position = self.position
        buttonSprite.isHidden = self.hidden
    
        self.textureSprite = SKSpriteNode(texture: self.texture)
        self.textureSprite!.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.textureSprite!.ignoreTouches = true
        self.textureSprite!.size = CGSize(
            width: self.size.width - SNZSpriteKitUITheme.instance.uiInnerMargins.left - SNZSpriteKitUITheme.instance.uiInnerMargins.right,
            height: self.size.height - SNZSpriteKitUITheme.instance.uiInnerMargins.top - SNZSpriteKitUITheme.instance.uiInnerMargins.bottom
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
