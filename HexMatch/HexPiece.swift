//
//  HexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class HexPiece : NSObject {

    // Last coordinates that this piece was placed on a hex map
    var lastX = -1
    var lastY = -1

    var _hexCell: HexCell?
    var hexCell: HexCell? {
        get {
            return self._hexCell
        }
        set {
            self._hexCell = newValue
            if (self._hexCell != nil) {
                self.lastX = self._hexCell!.x
                self.lastY = self._hexCell!.y
            }
        }
    }
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