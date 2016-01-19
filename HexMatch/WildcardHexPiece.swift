//
//  WildcardHexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/18/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class WildcardHexPiece : HexPiece {

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: HexMapHelper.instance.wildcardPieceTextures.first)
        node.name = "hexPiece"
        
        return node
    }
    
    override func getMaxMergeValue() -> Int {
        return HexMapHelper.instance.maxPieceValue
    }
    
    override func getMinMergeValue() -> Int {
        return 0
    }
    
    override func wasUnplaced() {
        self.value = 0
        self.sprite!.texture = HexMapHelper.instance.wildcardPieceTextures.first
    }
    
    override func wasPlacedWithoutMerge() {
        super.wasPlacedWithoutMerge()
    
        self.value = HexMapHelper.instance.wildcardPlacedValue
        self.sprite!.texture = HexMapHelper.instance.wildcardPlacedTexture
    }

}
