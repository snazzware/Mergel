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
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.updateGui()
    }
    
    func updateGui() {        
        self.removeAllChildren()
        self.widgets.removeAll()
        
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Create stats frame
        let statsFrame = SNZScrollableFrame()
        statsFrame.size = CGSize(width: self.frame.width - 40, height: self.frame.height - 200)
        statsFrame.position = CGPoint(x: 20, y: 100)
        statsFrame.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        statsFrame.strokeColor = UIColor.clear
        self.addWidget(statsFrame)
        
        // Create primary header
        let header = SNZSceneHeaderWidget()
        header.caption = "Scores and Statistics"
        self.addWidget(header)
        
        var verticalOffset:CGFloat = -20
        
        var statGroups = [String: [String: String]]()
        var statIcons = [String: String]()
        
        for (key, description) in GameStats.instance!.statNames {
            let toks = description.components(separatedBy: "/")
            if (toks.count >= 2) {
                if (statGroups[toks[0]] == nil) {
                    statGroups[toks[0]] = [String: String]()
                }
                
                statGroups[toks[0]]![key] = toks[1]
                
                if (toks.count >= 3) {
                    statIcons[key] = toks[2]
                }
            }
        }
        
        // Iterate over stat groups and render
        for (description, keys) in statGroups {
            
            // render header for stat group
            let label = SKLabelNode(fontNamed: "Avenir-Black")
            label.text = description
            label.fontColor = UIColor.white
            label.fontSize = 18
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: statsFrame.size.width / 2, y: verticalOffset)
            label.ignoreTouches = true
            statsFrame.content.addChild(label)
            
            // Advance to next row
            verticalOffset -= 24
            
            // Sort descending values
            let sortedKeys = keys.sorted(by: { (a: (String, String), b: (String, String)) -> Bool in
                return GameStats.instance!.getIntForKey(a.0, 0) > GameStats.instance!.getIntForKey(b.0, 0)
            })
            
            var rowNumber = 0
            
            // Render label and value for each
            for (key, caption) in sortedKeys {
                // Shade even-numbered rows
                if (rowNumber % 2 == 0) {
                    let backgroundRect = SKShapeNode(rect: CGRect(x: 4,y: verticalOffset-12,width: statsFrame.size.width-8,height: 24))
                    backgroundRect.fillColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.1)
                    backgroundRect.strokeColor = UIColor.clear
                    statsFrame.content.addChild(backgroundRect)
                }
                
                // Render label
                let label = SKLabelNode(fontNamed: "Avenir-Black")
                label.text = caption
                label.fontColor = UIColor.white
                label.fontSize = 14
                label.horizontalAlignmentMode = .left
                label.verticalAlignmentMode = .center
                label.position = CGPoint(x: 10, y: verticalOffset)
                label.ignoreTouches = true
                statsFrame.content.addChild(label)
                
                // Render value
                let value = SKLabelNode(fontNamed: "Avenir-Black")
                value.text = "\(HexMapHelper.instance.scoreFormatter.string(from: NSNumber(integerLiteral: GameStats.instance!.getIntForKey(key, 0)))!)"
                value.fontColor = UIColor.white
                value.fontSize = 14
                value.horizontalAlignmentMode = .right
                value.verticalAlignmentMode = .center
                value.position = CGPoint(x: statsFrame.size.width-10, y: verticalOffset)
                value.ignoreTouches = true
                statsFrame.content.addChild(value)
            
                // Advance to next row
                verticalOffset -= 24
                
                rowNumber += 1
            }
            
            // pad bottom of group
            verticalOffset -= 24
        }
        
        // Add the close button
        let closeButton = MergelButtonWidget(parentNode: self)
        closeButton.anchorPoint = CGPoint(x: 0,y: 0)
        closeButton.caption = "Back"
        closeButton.bind("tap",{
            self.close()
        });
        self.addWidget(closeButton)
        
        // Render the widgets
        self.renderWidgets()
    }
    
    func close() {
        self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.push(with: SKTransitionDirection.left, duration: 0.4))
    }
    
}
