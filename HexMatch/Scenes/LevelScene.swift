//
//  LevelScene.swift
//  HexMatch
//
//  Created by Josh McKee on 1/28/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import SNZSpriteKitUI

class LevelScene: SNZScene {
    
    var checkboxMobilePieces: SNZCheckButtonWidget?
    var checkboxEnemyPieces: SNZCheckButtonWidget?
    var checkboxSoundEffects: SNZCheckButtonWidget?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.updateGui()
    }
    
    func updateGui() {
        self.removeAllChildren()
        self.widgets.removeAll()
    
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
    
        // Create primary header
        let header = SNZSceneHeaderWidget()
        header.caption = "Menu"
        self.addWidget(header)
        
        // Add copyright
        let copyrightLabel = SKLabelNode(fontNamed: "Avenir-Black")
        copyrightLabel.text = "Mergel ©2016 Josh M. McKee"
        copyrightLabel.fontColor = UIColor.white
        copyrightLabel.fontSize = 12
        copyrightLabel.horizontalAlignmentMode = .center
        copyrightLabel.verticalAlignmentMode = .center
        copyrightLabel.position = CGPoint(x: self.size.width / 2, y: 8)
        copyrightLabel.ignoreTouches = true
        self.addChild(copyrightLabel)
        
        var verticalOffset:CGFloat = self.frame.height - 60
        
        // Create and position option buttons
        
        let horizontalOffset:CGFloat = self.frame.width < 500 ? 20 : 300
        verticalOffset = self.frame.width < 500 ? verticalOffset - 60 : self.frame.height - 120
        
        self.checkboxSoundEffects = MergelCheckButtonWidget(parentNode: self)
        self.checkboxSoundEffects!.isChecked = GameState.instance!.getIntForKey("enable_sound_effects", 1) == 1
        self.checkboxSoundEffects!.caption = "Sound Effects"
        self.checkboxSoundEffects!.position = CGPoint(x: horizontalOffset,y: verticalOffset)
        self.addWidget(self.checkboxSoundEffects!)
        
        /*self.checkboxMobilePieces = MergelCheckButtonWidget(parentNode: self)
        self.checkboxMobilePieces!.isChecked = GameState.instance!.getIntForKey("include_mobile_pieces", 1) == 1
        self.checkboxMobilePieces!.caption = "Moving Shapes"
        self.checkboxMobilePieces!.position = CGPointMake(horizontalOffset,verticalOffset)
        self.addWidget(self.checkboxMobilePieces!)*/
        
        verticalOffset -= 120
        
        /*self.checkboxEnemyPieces = MergelCheckButtonWidget(parentNode: self)
        self.checkboxEnemyPieces!.isChecked = GameState.instance!.getIntForKey("include_enemy_pieces", 1) == 1
        self.checkboxEnemyPieces!.caption = "Vanilla Gel"
        self.checkboxEnemyPieces!.position = CGPointMake(horizontalOffset,verticalOffset)
        self.addWidget(self.checkboxEnemyPieces!)*/
        
        // Add the New Game button
        let newGameButton = MergelButtonWidget(parentNode: self)
        newGameButton.position = CGPoint(x: horizontalOffset,y: verticalOffset)
        newGameButton.caption = "New Game"
        newGameButton.bind("tap",{
            self.view?.presentScene(SceneHelper.instance.newGameScene, transition: SKTransition.push(with: SKTransitionDirection.up, duration: 0.4))
        });
        self.addWidget(newGameButton)
        
        verticalOffset -= 60
        
        // Add the Help button
        let helpButton = MergelButtonWidget(parentNode: self)
        helpButton.position = CGPoint(x: horizontalOffset,y: verticalOffset)
        helpButton.caption = "How to Play"
        helpButton.bind("tap",{
            UIApplication.shared.openURL(URL(string:"https://github.com/snazzware/Mergel/blob/master/HELP.md")!)
        });
        self.addWidget(helpButton)
        
        verticalOffset -= 60
        
        // Add the About button
        let aboutButton = MergelButtonWidget(parentNode: self)
        aboutButton.position = CGPoint(x: horizontalOffset,y: verticalOffset)
        aboutButton.caption = "About Mergel"
        aboutButton.bind("tap",{
            UIApplication.shared.openURL(URL(string:"https://github.com/snazzware/Mergel/blob/master/ABOUT.md")!)
        });
        self.addWidget(aboutButton)
        
        verticalOffset -= 60
        
        // Add the Issues button
        let issuesButton = MergelButtonWidget(parentNode: self)
        issuesButton.position = CGPoint(x: horizontalOffset,y: verticalOffset)
        issuesButton.caption = "Bugs & Requests"
        issuesButton.bind("tap",{
            UIApplication.shared.openURL(URL(string:"https://github.com/snazzware/Mergel/issues")!)
        });
        self.addWidget(issuesButton)
        
        // Add the close button
        let closeButton = MergelButtonWidget(parentNode: self)
        closeButton.anchorPoint = CGPoint(x: 0,y: 0)
        closeButton.caption = "Back"
        closeButton.bind("tap",{
            self.captureSettings()
            self.close()
        });
        self.addWidget(closeButton)
        
        // Render the widgets
        self.renderWidgets()
    }
    
    func captureSettings() {
        //GameState.instance!.setIntForKey("include_mobile_pieces", self.checkboxMobilePieces!.isChecked ? 1 : 0 )
        //GameState.instance!.setIntForKey("include_enemy_pieces", self.checkboxEnemyPieces!.isChecked ? 1 : 0 )
        GameState.instance!.setIntForKey("enable_sound_effects", self.checkboxSoundEffects!.isChecked ? 1 : 0 )
        
        if (GameState.instance!.getIntForKey("enable_sound_effects", 1) == 1) {
            SoundHelper.instance.enableSoundEffects()
        } else {
            SoundHelper.instance.disableSoundEffects()
        }
    }
    
    func close() {
        self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.push(with: SKTransitionDirection.down, duration: 0.4))
    }
    
}
