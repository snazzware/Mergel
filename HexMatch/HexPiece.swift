//
//  HexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class HexPiece : NSObject {

    var hexCell: HexCell?
    var sprite: SKSpriteNode?
    
    var value = 0
    
    func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        if (self.value == hexPiece.value && self.value < HexMapHelper.instance.maxPieceValue) {
            return true
        } else {
            return false
        }
    }
    
}