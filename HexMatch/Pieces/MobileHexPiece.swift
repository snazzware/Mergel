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
    override func addAnimation(_ node: SKSpriteNode) {
        if (self.isAlive) {
            let eyeTexture = SKTexture(imageNamed: "Eyes")
            let eyeclosedTexture = SKTexture(imageNamed: "EyeClosed")
            let eyeLookLeftTexture = SKTexture(imageNamed: "EyeLookLeft")
            let eyeLookRightTexture = SKTexture(imageNamed: "EyeLookRight")
            
            let leftEye = SKSpriteNode(texture: eyeTexture)
            let rightEye = SKSpriteNode(texture: eyeTexture)
            
            // Position eyes
            leftEye.position = CGPoint(x: -4,y: 16)
            leftEye.zPosition = 10
            leftEye.name = "leftEye"
            
            rightEye.position = CGPoint(x: 10,y: 12)
            rightEye.zPosition = 10
            rightEye.name = "rightEye"
            
            // Add eyes to sprite
            node.addChild(leftEye)
            node.addChild(rightEye)
            
            // Define eye animation
            let blinkAction = SKAction.run({
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
                
                leftEye.run(SKAction.sequence([
                    SKAction.setTexture(altTexture!),
                    SKAction.wait(forDuration: 0.25),
                    SKAction.setTexture(eyeTexture),
                ]))
                
                rightEye.run(SKAction.sequence([
                    SKAction.setTexture(altTexture!),
                    SKAction.wait(forDuration: 0.25),
                    SKAction.setTexture(eyeTexture),
                ]))
                
            })
            
            // Repeat blink action forever with a random delay of 3 to 6 seconds between blinks
            let blinkSequence = SKAction.sequence([blinkAction,SKAction.wait(forDuration: Double(arc4random_uniform(3)+3))])
            let blinkLoop = SKAction.repeatForever(blinkSequence)
            
            node.run(blinkLoop)
        }
    }
    
    /**
        Determines if this peice can merge with a given HexPiece
    
        - Returns: True if this piece can merge with hexPiece
    */
    override func canMergeWithPiece(_ hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (!isAlive) {
            result = super.canMergeWithPiece(hexPiece)
        }
        
        return result
    }
    
    /**
        Before merges occur, see if we have any free spots to move in to. If not, die now, so we can be merged.
     */
    override func preTakeTurn() {
        let openCells = HexMapHelper.instance.hexMap!.openCellsForRadius(self.hexCell!, radius: 1)
        
        if (self.isAlive && openCells.count == 0) {
            self.stopLiving()
        }
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
    func animateMoveTo(_ position: CGPoint) {
        self.sprite!.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0),
            SKAction.wait(forDuration: 0.05),
            SKAction.rotate(byAngle: -0.1, duration: 0),
            SKAction.wait(forDuration: 0.05),
            SKAction.rotate(byAngle: -0.1, duration: 0),
            SKAction.wait(forDuration: 0.05),
            SKAction.rotate(byAngle: 0.1, duration: 0),
        ])), withKey: "walking")
        
        self.sprite!.run(
            SKAction.sequence([
                SKAction.move(to: position, duration: 0.5),
                SKAction.run({
                    self.sprite!.removeAction(forKey: "walking")
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
                
        self.removeAnimation()
        
        // Add any death animation
        self.addAnimation(self.sprite!)
    }
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    
        if (decoder.containsValue(forKey: "isAlive")) {
            self.isAlive = decoder.decodeBool(forKey: "isAlive")
        } else {
            self.isAlive = false
        }
        if (decoder.containsValue(forKey: "wasAlive")) {
            self.wasAlive = decoder.decodeBool(forKey: "wasAlive")
        } else {
            self.wasAlive = false
        }
        
        self.wasInCell = (decoder.decodeObject(forKey: "wasInCell") as? HexCell)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(self.isAlive, forKey: "isAlive")
        coder.encode(self.wasAlive, forKey: "wasAlive")
        coder.encode(self.wasInCell, forKey: "wasInCell")
    }
    
}
