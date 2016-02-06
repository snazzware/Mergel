//
//  MobileHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/18/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class MobileHexPiece : HexPiece {

    // If this piece is "alive" or not. Alive pieces will attempt to move on their turn, dead won't.
    var isAlive = true
    
    // Whether or not this piece was alive the last time it took a turn
    var wasAlive = true
    
    // Cell that this piece was in prior to it's last turn, if any
    var wasInCell: HexCell?

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = super.createSprite()

        self.addAnimation(node)
        
        return node
    }
    
    /**
        Adds decorations and sets up general animations for sprite
    */
    func addAnimation(node: SKSpriteNode) {
        if (self.isAlive) {
            let eyeTexture = SKTexture(imageNamed: "Eyes")
            let eyeclosedTexture = SKTexture(imageNamed: "EyeClosed")
            let eyeLookLeftTexture = SKTexture(imageNamed: "EyeLookLeft")
            let eyeLookRightTexture = SKTexture(imageNamed: "EyeLookRight")
            
            let leftEye = SKSpriteNode(texture: eyeTexture)
            let rightEye = SKSpriteNode(texture: eyeTexture)
            
            // Position eyes
            leftEye.position = CGPointMake(-4,16)
            leftEye.zPosition = 10
            leftEye.name = "leftEye"
            
            rightEye.position = CGPointMake(10,12)
            rightEye.zPosition = 10
            rightEye.name = "rightEye"
            
            // Add eyes to sprite
            node.addChild(leftEye)
            node.addChild(rightEye)
            
            // Define eye animation
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
            
            // Repeat blink action forever with a random delay of 3 to 6 seconds between blinks
            let blinkSequence = SKAction.sequence([blinkAction,SKAction.waitForDuration(Double(arc4random_uniform(3)+3))])
            let blinkLoop = SKAction.repeatActionForever(blinkSequence)
            
            node.runAction(blinkLoop)
        }
    }
    
    /**
        Determines if this peice can merge with a given HexPiece
    
        - Returns: True if this piece can merge with hexPiece
    */
    override func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (!isAlive) {
            result = super.canMergeWithPiece(hexPiece)
        }
        
        return result
    }
    
    /**
        Try to move to another cell, and "die" if unable.
    
        - Returns: True if we did take a turn
    */
    override func takeTurn() -> Bool {
        let shouldTakeTurn = super.takeTurn()
        
        self.wasAlive = self.isAlive
        self.wasInCell = self.hexCell
        
        if (shouldTakeTurn && self.hexCell != nil && self.isAlive) {
            let openCells = HexMapHelper.instance.hexMap!.openCellsForRadius(self.hexCell!, radius: 1)
            
            if (openCells.count == 0) {
                self.stopLiving()
            } else {
                let randomCell = openCells[Int(arc4random_uniform(UInt32(openCells.count)))]

                if (self.hexCell != nil) {
                    self.hexCell!.hexPiece = nil
                }
                
                randomCell.hexPiece = self
                
                self.animateMoveTo(HexMapHelper.instance.hexMapToScreen(randomCell.position))
                
                
            }
        }
        
        return shouldTakeTurn
    }
    
    /**
        Move this piece's sprite to the specified position, with animation
    */
    func animateMoveTo(position: CGPoint) {
        self.sprite!.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.rotateByAngle(0.1, duration: 0),
            SKAction.waitForDuration(0.05),
            SKAction.rotateByAngle(-0.1, duration: 0),
            SKAction.waitForDuration(0.05),
            SKAction.rotateByAngle(-0.1, duration: 0),
            SKAction.waitForDuration(0.05),
            SKAction.rotateByAngle(0.1, duration: 0),
        ])), withKey: "walking")
        
        self.sprite!.runAction(
            SKAction.sequence([
                SKAction.moveTo(position, duration: 0.5),
                SKAction.runBlock({
                    self.sprite!.removeActionForKey("walking")
                    self.sprite!.zRotation = 0
                })
            ])
        )
    }
    
    /**
        Set isAlive to false and remove any animations, decorations associated with a "living" piece
    */
    func stopLiving() {
        isAlive = false
                
        // Remove eyes, etc.
        self.sprite!.removeAllActions()
        self.sprite!.removeAllChildren()
    }
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    
        self.isAlive = (decoder.decodeObjectForKey("isAlive") as? Bool)!
        self.wasAlive = (decoder.decodeObjectForKey("wasAlive") as? Bool)!
        self.wasInCell = (decoder.decodeObjectForKey("wasInCell") as? HexCell)
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(self.isAlive, forKey: "isAlive")
        coder.encodeObject(self.wasAlive, forKey: "wasAlive")
        coder.encodeObject(self.wasInCell, forKey: "wasInCell")
    }
    
}
