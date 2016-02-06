//
//  WildcardHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/18/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class WildcardHexPiece : HexPiece {

    var isWild = true

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: HexMapHelper.instance.wildcardPieceTextures.first)
        
        node.name = "hexPiece"
        
        if (!self.isWild) {
            if (self.isCollectible) {
                node.texture = SKTexture(imageNamed: "BowieBolt")
            } else {
                node.texture = HexMapHelper.instance.wildcardPlacedTexture
            }
        }
        
        self.addAnimation(node)
        
        return node
    }
    
    func addAnimation(node: SKSpriteNode) {
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
        
        if (self.isWild) {
            result = super.canMergeWithPiece(hexPiece)
        } else
        if (!self.isCollectible && hexPiece is WildcardHexPiece && !(hexPiece as! WildcardHexPiece).isWild) {
            result = true
        }
        
        return result
    }
    
    override func getMaxMergeValue() -> Int {
        if (self.isWild) {
            return HexMapHelper.instance.maxPieceValue
        } else {
            return 0
        }
    }
    
    override func getMinMergeValue() -> Int {
        return 0
    }
    
    override func wasPlacedWithoutMerge() {
        super.wasPlacedWithoutMerge()

        self.isWild = false

        self.value = 999

        self.sprite!.texture = HexMapHelper.instance.wildcardPlacedTexture
    }
    
    override func wasPlacedWithMerge(mergeValue: Int = -1) -> HexPiece {
        super.wasPlacedWithMerge(mergeValue)

        if (!self.isWild) {
            self.isCollectible = true
            
            self.sprite!.texture = SKTexture(imageNamed: "BowieBolt")
            
            self.addAnimation(self.sprite!)
            
            return self
        } else {
            self.isWild = false
            
            let mergedPiece = HexPiece()
            mergedPiece.value = self.value
            mergedPiece.hexCell = self.hexCell
            mergedPiece.sprite = self.sprite
            
            return mergedPiece
        }
    }
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    
        let isWild = decoder.decodeObjectForKey("isWild")
        if (isWild != nil) {
            self.isWild = (isWild as? Bool)!
        }
        
        // Enforce no-wildcards on board rule
        if (self.hexCell != nil) {
            self.isWild = false            
        }
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(self.isWild, forKey: "isWild")
    }
    
    override func getPieceDescription() -> String {
        return "Wildcard"
    }
    
    override func getStatsKey() -> String {
        if (self.value == 999) {
            return "piece_wildcard_999"
        }
        
        return "piece_wildcard_0"
    }
    
    override func wasCollected() {
        let collectedPoints = 80313
        
        SceneHelper.instance.gameScene.awardPoints(collectedPoints)
        SceneHelper.instance.gameScene.scrollPoints(collectedPoints, position: self.sprite!.position)
        
        super.wasCollected()
    }

}
