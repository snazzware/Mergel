//
//  EnemyHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/27/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class EnemyHexPiece : MobileHexPiece {

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture(imageNamed: "EnemyVanillaBean"))
    
        node.name = "hexPiece"
        
        switch (self.value) {
            case 1001:
                node.texture = SKTexture(imageNamed: "EnemyVanillaBeanSuper")
            break;
            case 1002:
                node.texture = SKTexture(imageNamed: "CollectibleVanillaBean")
            break;
            default:
            break;
        }
        
        self.addAnimation(node)
        
        return node
    }
    
    override func getStatsKey() -> String {
        print("piece_vanillabean_\(self.value)")
        return "piece_vanillabean_\(self.value)"
    }
    
    override func getPieceDescription() -> String {
        return "Vanilla Gel"
    }
    
    override func createMergedSprite() -> SKSpriteNode? {
        return nil
    }
    
    override var description: String {
        return "EnemyHexPiece isAlive=\(self.isAlive) isCollectible=\(self.isCollectible) value=\(self.value)"
    }
    
    override func addAnimation(_ node: SKSpriteNode) {
        if (self.isAlive) {
            let eyeclosedTexture = SKTexture(imageNamed: "EyeClosed")
            let eyeLeftTexture = SKTexture(imageNamed: "EyeLookLeft")
            let eyeRightTexture = SKTexture(imageNamed: "EyeLookRight")
            let mouthTexture = SKTexture(imageNamed: "EnemyMouthFrown")
            
            let leftEye = SKSpriteNode(texture: eyeLeftTexture)
            let rightEye = SKSpriteNode(texture: eyeRightTexture)
            let mouth = SKSpriteNode(texture: mouthTexture)
            
            leftEye.position = CGPoint(x: -8,y: 12)
            leftEye.zPosition = 10
            leftEye.name = "leftEye"
            
            rightEye.position = CGPoint(x: 8,y: 12)
            rightEye.zPosition = 10
            rightEye.name = "rightEye"
            
            mouth.position = CGPoint(x: 0,y: 0)
            mouth.zPosition = 10
            mouth.name = "mouth"
            
            node.addChild(leftEye)
            node.addChild(rightEye)
            node.addChild(mouth)
            
            let blinkAction = SKAction.run({
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
                
                leftEye.run(SKAction.sequence([
                    SKAction.setTexture(altTextureLeft!),
                    SKAction.wait(forDuration: 0.25),
                    SKAction.setTexture(eyeLeftTexture),
                ]))
                
                rightEye.run(SKAction.sequence([
                    SKAction.setTexture(altTextureRight!),
                    SKAction.wait(forDuration: 0.25),
                    SKAction.setTexture(eyeRightTexture),
                ]))
                
            })
            let blinkSequence = SKAction.sequence([blinkAction,SKAction.wait(forDuration: Double(arc4random_uniform(3)+3))])
            let blinkLoop = SKAction.repeatForever(blinkSequence)
            
            node.run(blinkLoop)
        } else {
            if (self.value == 1000) {
                let eyeDeadTexture = SKTexture(imageNamed: "EyeDead")
                let mouthTexture = SKTexture(imageNamed: "EnemyMouthDead")
                
                let leftEye = SKSpriteNode(texture: eyeDeadTexture)
                let rightEye = SKSpriteNode(texture: eyeDeadTexture)
                let mouth = SKSpriteNode(texture: mouthTexture)
                
                leftEye.position = CGPoint(x: -8,y: 8)
                leftEye.zPosition = 10
                leftEye.setScale(0.8)
                leftEye.name = "leftEye"
                
                rightEye.position = CGPoint(x: 8,y: 8)
                rightEye.zPosition = 10
                rightEye.setScale(0.8)
                rightEye.name = "rightEye"
                
                mouth.position = CGPoint(x: 0,y: 0)
                mouth.zPosition = 9
                mouth.name = "mouth"
                
                node.addChild(leftEye)
                node.addChild(rightEye)
                node.addChild(mouth)

            }
        }
        
        if (self.isCollectible) {
            let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.5)
            let scaleDownAction = SKAction.scale(to: 0.9, duration: 0.5)
            let rotateRightAction = SKAction.rotate(byAngle: 0.5, duration: 0.25)
            let rotateLeftAction = SKAction.rotate(byAngle: -0.5, duration: 0.25)
            
            let collectibleGroup = SKAction.group([
                SKAction.sequence([scaleUpAction,scaleDownAction]),
                SKAction.sequence([rotateRightAction,rotateLeftAction,rotateLeftAction,rotateRightAction])
            ])
            
            node.run(SKAction.repeatForever(collectibleGroup))
        }
    }
    
    override func canMergeWithPiece(_ hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (hexPiece is EnemyHexPiece) {
            result = (!self.isCollectible && !self.isAlive && !(hexPiece as! EnemyHexPiece).isAlive && (self.value == hexPiece.value))
        }
        if (hexPiece is WildcardHexPiece) {
            result = (!self.isCollectible && !self.isAlive)
        }

        return result
    }
    
    override func wasPlacedWithMerge(_ mergeValue: Int = -1, mergingPieces: [HexPiece]) -> HexPiece {
        self.originalValue = self.value
        self.value = mergeValue+1
        
        if (self.value == 1002) {
            self.isCollectible = true
        }
        
        var newTexture = self.sprite!.texture
        
        switch (self.value) {
            case 1001:
                newTexture = SKTexture(imageNamed: "EnemyVanillaBeanSuper")
            break;
            case 1002:
                newTexture = SKTexture(imageNamed: "CollectibleVanillaBean")
            break;
            default:
            break;
        }
        
        self.removeAnimation()
        
        self.sprite!.run(SKAction.sequence([
            SKAction.scale(to: 0.01, duration: 0.1),
            SKAction.setTexture(newTexture!),
            SKAction.scale(to: 1.0, duration: 0.15)
        ]))
        
        self.addAnimation(self.sprite!)
        
        self.skipTurnCounter = self.skipTurnsOnPlace
        
        self.playMergeSound()
        
        return self
    }
    
    override func animateMoveTo(_ position: CGPoint) {
        let walkA = SKTexture(imageNamed: "EnemyVanillaBean_WalkA")
        let walkB = SKTexture(imageNamed: "EnemyVanillaBean_WalkB")
        let originalTexture = self.sprite!.texture!
    
        self.sprite!.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0),
            SKAction.setTexture(walkA),
            SKAction.wait(forDuration: 0.1),
            SKAction.rotate(byAngle: -0.1, duration: 0),
            SKAction.setTexture(originalTexture),
            SKAction.wait(forDuration: 0.1),
            SKAction.rotate(byAngle: -0.1, duration: 0),
            SKAction.setTexture(walkB),
            SKAction.wait(forDuration: 0.1),
            SKAction.rotate(byAngle: 0.1, duration: 0),
            SKAction.setTexture(originalTexture)
        ])), withKey: "walking")
        
    
        self.sprite!.run(
            SKAction.sequence([
                SKAction.move(to: position, duration: 0.5),
                SKAction.run({
                    self.sprite!.texture = originalTexture
                    self.sprite!.removeAction(forKey: "walking")
                    self.sprite!.zRotation = 0
                })
            ])
        )
    }
    
    override func playCollectionSound() {
        self.sprite!.run(SoundHelper.instance.collect)
    }
    
    override func playPlacementSound() {
        self.sprite!.run(SoundHelper.instance.placeEnemy)
    }
    
    override func playMergeSound() {
        self.sprite!.run(SoundHelper.instance.mergePieces)
    }
    
    /**
     - Returns: Points to be awarded when piece is collected
     */
    override func getCollectedValue() -> Int {
        return 50000
    }

    override func wasCollected() {
        super.wasCollected()
        
        let achievement = GKAchievement(identifier: "com.snazzware.mergel.Gel")
        
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = true
        
        GameKitHelper.sharedInstance.reportAchievements([achievement])
    }
    
}
