//
//  EnemyHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/27/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyHexPiece : MobileHexPiece {

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture(imageNamed: "EnemyVanillaBean"))
    
        node.name = "hexPiece"
        
        switch (self.value) {
            case 1:
                node.texture = SKTexture(imageNamed: "EnemyVanillaBeanSuper")
            break;
            case 2:
                node.texture = SKTexture(imageNamed: "CollectibleVanillaBean")
            break;
            default:
            break;
        }
        
        self.addAnimation(node)
        
        return node
    }
    
    override var description: String {
        return "EnemyHexPiece isAlive=\(self.isAlive) isCollectible=\(self.isCollectible) value=\(self.value)"
    }
    
    override func addAnimation(node: SKSpriteNode) {
        if (self.isAlive) {
            let eyeLeftTexture = SKTexture(imageNamed: "EnemyEyeLeft")
            let eyeRightTexture = SKTexture(imageNamed: "EnemyEyeRight")
            let mouthTexture = SKTexture(imageNamed: "EnemyMouthFrown")
            
            let leftEye = SKSpriteNode(texture: eyeLeftTexture)
            let rightEye = SKSpriteNode(texture: eyeRightTexture)
            let mouth = SKSpriteNode(texture: mouthTexture)
            
            leftEye.position = CGPointMake(-8,12)
            leftEye.zPosition = 10
            leftEye.name = "leftEye"
            
            rightEye.position = CGPointMake(8,12)
            rightEye.zPosition = 10
            rightEye.name = "rightEye"
            
            mouth.position = CGPointMake(0,0)
            mouth.zPosition = 10
            mouth.name = "rightEye"
            
            node.addChild(leftEye)
            node.addChild(rightEye)
            node.addChild(mouth)
        }
        if (self.isCollectible) {
            let scaleUpAction = SKAction.scaleTo(1.1, duration: 0.5)
            let scaleDownAction = SKAction.scaleTo(0.9, duration: 0.5)
            let rotateRightAction = SKAction.rotateByAngle(0.5, duration: 0.5)
            let rotateLeftAction = SKAction.rotateByAngle(-0.5, duration: 0.5)
            
            let collectibleGroup = SKAction.group([
                SKAction.sequence([scaleUpAction,scaleDownAction]),
                SKAction.sequence([rotateRightAction,rotateLeftAction])
            ])
            
            node.runAction(SKAction.repeatActionForever(collectibleGroup))
        }
    }
    
    override func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (hexPiece is EnemyHexPiece) {
            result = (!self.isCollectible && !self.isAlive && !(hexPiece as! EnemyHexPiece).isAlive && (self.value == hexPiece.value))
        }
        
        print("\(self) canMergeWithPiece \(hexPiece) equals \(result)")
        
        return result
    }
    
    override func wasPlacedWithMerge(mergeValue: Int = -1) -> HexPiece {
        self.originalValue = self.value
        self.value = mergeValue+1
        
        if (self.value == 2) {
            self.isCollectible = true
        }
        
        switch (self.value) {
            case 1:
                self.sprite!.texture = SKTexture(imageNamed: "EnemyVanillaBeanSuper")
            break;
            case 2:
                self.sprite!.texture = SKTexture(imageNamed: "CollectibleVanillaBean")
            break;
            default:
            break;
        }
        
        self.addAnimation(self.sprite!)
        
        self.skipTurnCounter = self.skipTurnsOnPlace
        
        return self
    }
    
    override func wasCollected() {
        let collectedPoints = 50000
        
        GameState.instance!.gameScene.awardPoints(collectedPoints)
        GameState.instance!.gameScene.scrollPoints(collectedPoints, position: self.sprite!.position)
        
        super.wasCollected()
    }

}