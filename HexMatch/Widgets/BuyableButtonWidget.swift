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

class BuyableButtonWidget : MergelButtonWidget {

    var points: Int = 0
    var buyableSprite: SKSpriteNode?
    
    override init() {
        super.init()
        
        self.size = CGSize(width: 250, height: 48)
    }
    
    override func render() {
        super.render()
        
        let pointsLabel = SKLabelNode(fontNamed: "Avenir-Black")
        pointsLabel.text = HexMapHelper.instance.scoreFormatter.string(from: NSNumber(integerLiteral: self.points))! + " pts"
        pointsLabel.fontColor = self.color
        pointsLabel.fontSize = 12
        pointsLabel.horizontalAlignmentMode = .right
        pointsLabel.verticalAlignmentMode = .center
        pointsLabel.position = CGPoint(x: self.size.width - 10, y: (self.size.height) / 2)
        pointsLabel.ignoreTouches = true
        
        self.sprite!.addChild(pointsLabel)
        
        self.labelSprite!.horizontalAlignmentMode = .left
        self.labelSprite!.position.x = 60
        
        self.buyableSprite!.position = CGPoint(x: 30,y: 20)
        
        self.sprite!.addChild(self.buyableSprite!)
        
        if (self.points > GameState.instance!.bankPoints) {
            pointsLabel.fontColor = UIColor.lightGray
            self.labelSprite!.fontColor = UIColor.lightGray
            self.buyableSprite!.alpha = 0.5
            
            self.events.removeValue(forKey: "focus")
            self.events.removeValue(forKey: "blur")
            self.events.removeValue(forKey: "tap")
        }
    }

}
