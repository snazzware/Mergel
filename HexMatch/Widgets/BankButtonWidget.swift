//
//  BankButtonWidget.swift
//  HexMatch
//
//  Created by Josh McKee on 2/9/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import SNZSpriteKitUI

class BankButtonWidget : MergelButtonWidget {

    var points: Int = 0
    var buyableSprite: SKSpriteNode?
    
    override init() {
        super.init()
        
        self.size = CGSize(width: 230, height: 48)
    }
    
    override func render() {
        super.render()
        
        // position & add icon
        let bankIcon = SKSpriteNode(texture: SKTexture(imageNamed: "savings1"))
        bankIcon.setScale(0.5)
        bankIcon.position = CGPoint(x: self.size.width - 24,y: self.size.height - 40)
        bankIcon.ignoreTouches = true
        self.sprite!.addChild(bankIcon)
        
        // position & add caption
        let bankSpendCaption = SKLabelNode(text: "Tap to spend")
        bankSpendCaption.fontColor = UIColor(red: 0xf7/255, green: 0xef/255, blue: 0xed/255, alpha: 0.8)
        bankSpendCaption.fontSize = 12
        bankSpendCaption.zPosition = 20
        bankSpendCaption.fontName = "Avenir-Black"
        bankSpendCaption.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bankSpendCaption.position = CGPoint(x: SNZSpriteKitUITheme.instance.uiInnerMargins.left, y: SNZSpriteKitUITheme.instance.uiInnerMargins.bottom)
        bankSpendCaption.ignoreTouches = true
        self.sprite!.addChild(bankSpendCaption)
    }

}
