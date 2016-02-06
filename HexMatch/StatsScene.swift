//
//  StatsScene.swift
//  HexMatch
//
//  Created by Josh McKee on 2/4/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import SNZSpriteKitUI

class StatsScene: SNZScene {
   
    override func didMoveToView(view: SKView) {        
        self.updateGui()
    }
    
    func updateGui() {        
        self.removeAllChildren()
        self.widgets.removeAll()
    
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Statistics
        let caption = SKLabelNode(fontNamed: "Avenir-Black")
        caption.text = "Statistics"
        caption.fontColor = UIColor.whiteColor()
        caption.fontSize = 24
        caption.horizontalAlignmentMode = .Center
        caption.verticalAlignmentMode = .Center
        caption.position = CGPointMake(self.size.width / 2, self.size.height - 20)
        caption.ignoreTouches = true
        self.addChild(caption)
        
        var verticalOffset = self.frame.height - 100
        
        for (key, description) in GameStats.instance!.statNames {
            let label = SKLabelNode(fontNamed: "Avenir-Black")
            label.text = description
            label.fontColor = UIColor.whiteColor()
            label.fontSize = 18
            label.horizontalAlignmentMode = .Left
            label.verticalAlignmentMode = .Center
            label.position = CGPointMake(10, verticalOffset)
            label.ignoreTouches = true
            self.addChild(label)
            
            let value = SKLabelNode(fontNamed: "Avenir-Black")
            value.text = "\(GameStats.instance!.getIntForKey(key, 0))"
            value.fontColor = UIColor.whiteColor()
            value.fontSize = 18
            value.horizontalAlignmentMode = .Right
            value.verticalAlignmentMode = .Center
            value.position = CGPointMake(self.frame.width-10, verticalOffset)
            value.ignoreTouches = true
            self.addChild(value)
            
            verticalOffset -= 30
        }
        
        // Add the close button
        let closeButton = SNZButtonWidget(parentNode: self)
        closeButton.anchorPoint = CGPointMake(0,0)
        closeButton.caption = "Close"
        closeButton.bind("tap",{
            self.close()
        });
        self.addWidget(closeButton)
        
        // Render the widgets
        self.initWidgets()
    }
    
    func close() {
        self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.4))
    }
    
}