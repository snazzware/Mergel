//
//  MobileHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/18/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class MobileHexPiece : HexPiece {

    var isAlive = true

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = super.createSprite()

        let eyeTexture = SKTexture(imageNamed: "Eyes")
        let eyeclosedTexture = SKTexture(imageNamed: "EyeClosed")
        let eyeLookLeftTexture = SKTexture(imageNamed: "EyeLookLeft")
        let eyeLookRightTexture = SKTexture(imageNamed: "EyeLookRight")
        
        let leftEye = SKSpriteNode(texture: eyeTexture)
        let rightEye = SKSpriteNode(texture: eyeTexture)
        
        leftEye.position = CGPointMake(-4,16)
        leftEye.zPosition = 10
        leftEye.name = "leftEye"
        
        rightEye.position = CGPointMake(10,12)
        rightEye.zPosition = 10
        rightEye.name = "rightEye"
        
        node.addChild(leftEye)
        node.addChild(rightEye)
        
        let blinkAction = SKAction.runBlock({
            var altTexture: SKTexture?
            
            switch (Int(arc4random_uniform(3))) {
                case 0: // blink
                    altTexture = eyeclosedTexture
                break;
                case 1: // look left
                    altTexture = eyeLookLeftTexture
                break;
                default: // look right
                    altTexture = eyeLookRightTexture
                break;
            }
            
            leftEye.runAction(SKAction.sequence([
                SKAction.setTexture(altTexture!),
                SKAction.waitForDuration(0.25),
                SKAction.setTexture(eyeTexture),
            ]))
            
            rightEye.runAction(SKAction.sequence([
                SKAction.setTexture(altTexture!),
                SKAction.waitForDuration(0.25),
                SKAction.setTexture(eyeTexture),
            ]))
            
        })
        let blinkSequence = SKAction.sequence([blinkAction,SKAction.waitForDuration(Double(arc4random_uniform(10)+3))])
        let blinkLoop = SKAction.repeatActionForever(blinkSequence)
        
        node.runAction(blinkLoop)
        
        return node
    }
    
    override func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        if (isAlive) {
            return false
        } else {
            return super.canMergeWithPiece(hexPiece)
        }
    }
    
    override func takeTurn() -> Bool {
        let shouldTakeTurn = super.takeTurn()
        
        if (shouldTakeTurn && self.hexCell != nil && self.isAlive) {
            let openCells = HexMapHelper.instance.hexMap!.openCellsForRadius(self.hexCell!, radius: 1)
            
            if (openCells.count == 0) {
                isAlive = false
                
                // Remove eyes, etc.
                self.sprite!.removeAllActions()
                self.sprite!.removeAllChildren()
            } else {
                let randomCell = openCells[Int(arc4random_uniform(UInt32(openCells.count)))]

                if (self.hexCell != nil) {
                    self.hexCell!.hexPiece = nil
                }
                
                randomCell.hexPiece = self
                
                self.sprite!.runAction(SKAction.moveTo(HexMapHelper.instance.hexMapToScreen(randomCell.x, randomCell.y), duration: 0.5))
            }
        }
        
        return shouldTakeTurn
    }
    
}
