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
            let eyeTexture = SKTexture(imageNamed: "Eyes")
            let eyeclosedTexture = SKTexture(imageNamed: "EyeClosed")
            let eyeLeftTexture = SKTexture(imageNamed: "EyeLookLeft")
            let eyeRightTexture = SKTexture(imageNamed: "EyeLookRight")
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
            
            let blinkAction = SKAction.runBlock({
                var altTextureLeft: SKTexture?
                var altTextureRight: SKTexture?
                
                switch (Int(arc4random_uniform(3))) {
                    case 0: // blink
                        altTextureLeft = eyeclosedTexture
                        altTextureRight = eyeclosedTexture
                    break;
                    case 1: // look left
                        altTextureLeft = eyeRightTexture
                        altTextureRight = eyeLeftTexture
                    break;
                    default: // look right
                        altTextureLeft = eyeRightTexture
                        altTextureRight = eyeLeftTexture
                    break;
                }
                
                leftEye.runAction(SKAction.sequence([
                    SKAction.setTexture(altTextureLeft!),
                    SKAction.waitForDuration(0.25),
                    SKAction.setTexture(eyeLeftTexture),
                ]))
                
                rightEye.runAction(SKAction.sequence([
                    SKAction.setTexture(altTextureRight!),
                    SKAction.waitForDuration(0.25),
                    SKAction.setTexture(eyeRightTexture),
                ]))
                
            })
            let blinkSequence = SKAction.sequence([blinkAction,SKAction.waitForDuration(Double(arc4random_uniform(3)+3))])
            let blinkLoop = SKAction.repeatActionForever(blinkSequence)
            
            node.runAction(blinkLoop)
        }
        if (self.isCollectible) {
            let scaleUpAction = SKAction.scaleTo(1.1, duration: 0.5)
            let scaleDownAction = SKAction.scaleTo(0.9, duration: 0.5)
            let rotateRightAction = SKAction.rotateByAngle(0.5, duration: 0.25)
            let rotateLeftAction = SKAction.rotateByAngle(-0.5, duration: 0.25)
            
            let collectibleGroup = SKAction.group([
                SKAction.sequence([scaleUpAction,scaleDownAction]),
                SKAction.sequence([rotateRightAction,rotateLeftAction,rotateLeftAction,rotateRightAction])
            ])
            
            node.runAction(SKAction.repeatActionForever(collectibleGroup))
        }
    }
    
    override func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (hexPiece is EnemyHexPiece) {
            result = (!self.isCollectible && !self.isAlive && !(hexPiece as! EnemyHexPiece).isAlive && (self.value == hexPiece.value))
        }
        
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
        
        self.playMergeSound()
        
        return self
    }
    
    override func getStatsKey() -> String {
        return "piece_vanillabean_\(self.value)"
    }
    
    override func animateMoveTo(position: CGPoint) {
        let walkA = SKTexture(imageNamed: "EnemyVanillaBean_WalkA")
        let walkB = SKTexture(imageNamed: "EnemyVanillaBean_WalkB")
        let originalTexture = self.sprite!.texture!
    
        self.sprite!.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.rotateByAngle(0.1, duration: 0),
            SKAction.setTexture(walkA),
            SKAction.waitForDuration(0.1),
            SKAction.rotateByAngle(-0.1, duration: 0),
            SKAction.setTexture(originalTexture),
            SKAction.waitForDuration(0.1),
            SKAction.rotateByAngle(-0.1, duration: 0),
            SKAction.setTexture(walkB),
            SKAction.waitForDuration(0.1),
            SKAction.rotateByAngle(0.1, duration: 0),
            SKAction.setTexture(originalTexture)
        ])), withKey: "walking")
        
    
        self.sprite!.runAction(
            SKAction.sequence([
                SKAction.moveTo(position, duration: 0.5),
                SKAction.runBlock({
                    self.sprite!.texture = originalTexture
                    self.sprite!.removeActionForKey("walking")
                    self.sprite!.zRotation = 0
                })
            ])
        )
    }
    
    override func playCollectionSound() {
        self.sprite!.runAction(SoundHelper.instance.collect)
    }
    
    override func playPlacementSound() {
        self.sprite!.runAction(SoundHelper.instance.placeEnemy)
    }
    
    override func playMergeSound() {
        self.sprite!.runAction(SoundHelper.instance.mergePieces)
    }
    
    override func wasCollected() {
        let collectedPoints = 50000
        
        SceneHelper.instance.gameScene.awardPoints(collectedPoints)
        SceneHelper.instance.gameScene.scrollPoints(collectedPoints, position: self.sprite!.position)
        
        super.wasCollected()
    }

}