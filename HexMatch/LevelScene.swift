//
//  LevelScene.swift
//  HexMatch
//
//  Created by Josh McKee on 1/28/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import CoreData

class LevelScene: SKScene {

    override func didMoveToView(view: SKView) {
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.scene!.view?.presentScene(GameState.instance!.gameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.4))
    }

}