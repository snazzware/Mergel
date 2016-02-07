//
//  BuyableButtonWidget.swift
//  HexMatch
//
//  Created by Josh McKee on 1/30/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import SNZSpriteKitUI

class BuyableButtonWidget : SNZButtonWidget {

    var points: Int = 0
    var buyableSprite: SKSpriteNode?
    
    override init() {
        super.init()
        
        self.size = CGSizeMake(230, 48)
    }
    
    override func render() {
        super.render()
        
        let pointsLabel = SKLabelNode(fontNamed: "Avenir-Black")
        pointsLabel.text = "\(self.points) pts"
        pointsLabel.fontColor = self.color
        pointsLabel.fontSize = 12
        pointsLabel.horizontalAlignmentMode = .Right
        pointsLabel.verticalAlignmentMode = .Center
        pointsLabel.position = CGPointMake(self.size.width - 10, (self.size.height) / 2)
        pointsLabel.ignoreTouches = true
        
        self.sprite!.addChild(pointsLabel)
        
        self.labelSprite!.horizontalAlignmentMode = .Left
        self.labelSprite!.position.x = 60
        
        self.buyableSprite!.position = CGPointMake(30,20)
        
        self.sprite!.addChild(self.buyableSprite!)
        
        if (self.points > GameState.instance!.bankPoints) {
            pointsLabel.fontColor = UIColor.lightGrayColor()
            self.labelSprite!.fontColor = UIColor.lightGrayColor()
            self.buyableSprite!.alpha = 0.5
            
            self.events.removeValueForKey("focus")
            self.events.removeValueForKey("blur")
            self.events.removeValueForKey("tap")
        }
    }

}