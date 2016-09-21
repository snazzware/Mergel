//
//  SplashScene.swift
//  Mergel
//
//  Created by Josh McKee on 9/12/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import SNZSpriteKitUI

class SplashScene: SNZScene {
    
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
        
        // Get an enemy sprite
        let enemyPiece = EnemyHexPiece()
        let enemySprite = enemyPiece.createSprite()
        
        enemySprite.position.x += 90
        enemySprite.position.y += 8
        enemySprite.zRotation = 0.4
        enemySprite.zPosition = 999
        
        // Mergel node
        let mergelNode = SKSpriteNode(texture: SKTexture(imageNamed: "Mergel"))
        mergelNode.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        mergelNode.setScale(0)
        mergelNode.addChild(enemySprite)
        self.addChild(mergelNode)
        
        // Scale/bounce and transition to game scene
        mergelNode.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 0.8, duration: 0.2),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 0.9, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.run({
                // Switch to game scene
                self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.moveIn(with: SKTransitionDirection.down, duration: 0.4))
            })
            
        ]))
    }
    
}
