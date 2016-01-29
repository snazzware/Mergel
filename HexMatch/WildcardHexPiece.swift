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
            node.texture = HexMapHelper.instance.wildcardPlacedTexture
        }
        
        return node
    }
    
    override func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (self.isWild) {
            result = super.canMergeWithPiece(hexPiece)
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

        self.isWild = false
        
        let mergedPiece = HexPiece()
        mergedPiece.value = self.value
        mergedPiece.hexCell = self.hexCell
        mergedPiece.sprite = self.sprite
        
        return mergedPiece
    }
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        print("wildcard init with coder")
        super.init(coder: decoder)
    
        let isWild = decoder.decodeObjectForKey("isWild")
        if (isWild != nil) {
            self.isWild = (isWild as? Bool)!
        }
        
        // Enforce no-wildcards on board rule
        if (self.hexCell != nil) {
            self.isWild = false
            print("\(self) isWild = \(self.isWild)")
        } else {
            print("\(self) is not in a hex cell")
        }
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        
        coder.encodeObject(self.isWild, forKey: "isWild")
    }

}
