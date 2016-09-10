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
        super.didMoveToView(view)
        
        self.updateGui()
    }
    
    func updateGui() {        
        self.removeAllChildren()
        self.widgets.removeAll()
        
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Create stats frame
        let statsFrame = SNZScrollableFrame()
        statsFrame.size = CGSizeMake(self.frame.width - 40, self.frame.height - 200)
        statsFrame.position = CGPointMake(20, 100)
        statsFrame.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.addWidget(statsFrame)
        
        // Create primary header
        let header = SNZSceneHeaderWidget()
        header.caption = "Scores and Statistics"
        self.addWidget(header)
        
        var verticalOffset:CGFloat = -20
        
        var statGroups = [String: [String: String]]()
        
        for (key, description) in GameStats.instance!.statNames {
            let toks = description.componentsSeparatedByString("/")
            if (toks.count >= 2) {
                if (statGroups[toks[0]] == nil) {
                    statGroups[toks[0]] = [String: String]()
                }
                
                statGroups[toks[0]]![key] = toks[1]
            }
        }
        
        for (description, keys) in statGroups {
            let label = SKLabelNode(fontNamed: "Avenir-Black")
            label.text = description
            label.fontColor = UIColor.whiteColor()
            label.fontSize = 18
            label.horizontalAlignmentMode = .Left
            label.verticalAlignmentMode = .Center
            label.position = CGPointMake(10, verticalOffset)
            label.ignoreTouches = true
            statsFrame.content.addChild(label)
            
            verticalOffset -= 30
            
            for (key, caption) in keys {
                let label = SKLabelNode(fontNamed: "Avenir-Black")
                label.text = caption
                label.fontColor = UIColor.whiteColor()
                label.fontSize = 14
                label.horizontalAlignmentMode = .Left
                label.verticalAlignmentMode = .Center
                label.position = CGPointMake(10, verticalOffset)
                label.ignoreTouches = true
                statsFrame.content.addChild(label)
                
                let value = SKLabelNode(fontNamed: "Avenir-Black")
                value.text = "\(GameStats.instance!.getIntForKey(key, 0))"
                value.fontColor = UIColor.whiteColor()
                value.fontSize = 14
                value.horizontalAlignmentMode = .Right
                value.verticalAlignmentMode = .Center
                value.position = CGPointMake(statsFrame.size.width-10, verticalOffset)
                value.ignoreTouches = true
                statsFrame.content.addChild(value)
            
                verticalOffset -= 30
            }
        }
        
        // Add the close button
        let closeButton = MergelButtonWidget(parentNode: self)
        closeButton.anchorPoint = CGPointMake(0,0)
        closeButton.caption = "Back"
        closeButton.bind("tap",{
            self.close()
        });
        self.addWidget(closeButton)
        
        // Render the widgets
        self.renderWidgets()
    }
    
    func close() {
        self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.4))
    }
    
}