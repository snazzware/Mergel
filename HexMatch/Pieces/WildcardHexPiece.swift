//
//  WildcardHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/18/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import GameKit

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
    
    override func createMergedSprite() -> SKSpriteNode? {
        return nil
    }
    
    override func canMergeWithPiece(_ hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (self.isWild && !(hexPiece is WildcardHexPiece)) {
            result = super.canMergeWithPiece(hexPiece)
        } else
        if (!self.isCollectible && hexPiece.value == self.value) {
            result = true
        }
        
        return result
    }
    
    override func getMaxMergeValue() -> Int {
        return self.isWild ? 9999 : 999
    }
    
    override func getMinMergeValue() -> Int {
        return self.isWild ? 0 : 999
    }
    
    override func wasPlacedWithoutMerge() {
        super.wasPlacedWithoutMerge()

        self.isWild = false

        self.value = 999

        self.sprite!.texture = HexMapHelper.instance.wildcardPlacedTexture
    }
    
    override func wasPlacedWithMerge(_ mergeValue: Int = -1, mergingPieces: [HexPiece]) -> HexPiece {
        super.wasPlacedWithMerge(mergeValue, mergingPieces: mergingPieces)

        var mergingWild = false
        var mergingEnemy = false
        
        for piece in mergingPieces {
            if (piece is EnemyHexPiece) {
                mergingEnemy = true
            } else
            if (piece is WildcardHexPiece) {
                mergingWild = true
            }
        }
        
        if (mergingWild) {
            self.isCollectible = true
            
            self.sprite!.texture = SKTexture(imageNamed: "BowieBolt")
            
            self.addAnimation(self.sprite!)
            
            return self
        } else {
            self.isWild = false
            
            var mergedPiece:HexPiece
            
            if (mergingEnemy) {
                // Create a non-alive enemy hex piece
                mergedPiece = EnemyHexPiece()
                (mergedPiece as! EnemyHexPiece).isAlive = false
                mergedPiece.value = mergeValue + 1
                mergedPiece.sprite = mergedPiece.createSprite()
                
                // Swap around sprites
                let currentParent = self.sprite!.parent
                currentParent!.addChild(mergedPiece.sprite!)
                mergedPiece.sprite!.zPosition = 10
                self.sprite!.removeFromParent()
                
                // Notify piece that it was placed w/ merge
                mergedPiece.wasPlacedWithMerge(mergeValue, mergingPieces: mergingPieces)
            } else {
                mergedPiece = HexPiece()
                
                mergedPiece.value = self.value
                mergedPiece.hexCell = self.hexCell
                mergedPiece.sprite = self.sprite
                mergedPiece.isCollectible = self.isCollectible
            }
            
            return mergedPiece
        }
    }
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    
        self.isWild = decoder.decodeBool(forKey: "isWild")
        
        // Enforce no-wildcards on board rule
        if (self.hexCell != nil) {
            self.isWild = false            
        }
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(self.isWild, forKey: "isWild")
    }
    
    override func getPieceDescription() -> String {
        return "Wildcard"
    }
    
    override func getStatsKey() -> String {
        if (self.isCollectible) {
            return "piece_wildcard_999"
        }
        
        return "piece_wildcard_0"
    }
    
    /**
     - Returns: Points to be awarded when piece is collected
     */
    override func getCollectedValue() -> Int {
        return 80313
    }
    
    override func wasCollected() {
        super.wasCollected()
        
        let achievement = GKAchievement(identifier: "com.snazzware.mergel.BowieBolt")
        
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = true
        
        GameKitHelper.sharedInstance.reportAchievements([achievement])
    }

}
