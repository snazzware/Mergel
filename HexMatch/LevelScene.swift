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
    
    override func didMoveToView(view: SKView) {        
        self.updateGui()
    }
    
    func updateGui() {
        self.removeAllChildren()
        self.widgets.removeAll()
    
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        var verticalOffset:CGFloat = self.frame.height - 100
        
        for unlockedLevel in (GameState.instance!.unlockedLevels) {
            print("\(verticalOffset)")
            let levelButton = SNZButtonWidget(parentNode: self)
            levelButton.position = CGPointMake(10,verticalOffset)
            levelButton.caption = LevelHelper.instance.getLevelHelperModeCaption(unlockedLevel)
            levelButton.bind("tap",{
                LevelHelper.instance.mode = unlockedLevel
                GameStateMachine.instance!.enterState(GameSceneRestartState.self)
                self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.4))
            });
            self.addWidget(levelButton)
            
            verticalOffset -= 120
        }
        
        let closeButton = SNZButtonWidget(parentNode: self)
        closeButton.position = CGPointMake(10,100)
        closeButton.caption = "close"
        closeButton.bind("tap",{
            self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.4))
        });
        self.addWidget(closeButton)
        
        self.initWidgets()
    }
    
}