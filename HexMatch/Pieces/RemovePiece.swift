//
//  RemovePiece.swift
//  HexMatch
//
//  Created by Josh McKee on 2/2/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

class RemovePiece: HexPiece {

    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    override func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture(imageNamed: "RemovePiece"))
    
        return node
    }
    
    override func createMergedSprite() -> SKSpriteNode? {
        return nil
    }

    override func getPieceDescription() -> String {
        return "Eraser"
    }

}