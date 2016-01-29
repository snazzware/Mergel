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
    var wasAlive = true
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
    
    func addAnimation(node: SKSpriteNode) {
        if (self.isAlive) {
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
        }
    }
    
    override func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (!isAlive) {
            result = super.canMergeWithPiece(hexPiece)
        }
        
        print("\(self) canMergeWithPiece \(hexPiece) equals \(result)")
        
        return result
    }
    
    override func takeTurn() -> Bool {
        let shouldTakeTurn = super.takeTurn()
        
        self.wasAlive = self.isAlive
        self.wasInCell = self.hexCell
        
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
