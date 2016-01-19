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
    
    var originalValue = 0
    var _value = -1
    var value: Int {
        get {
            if (self._value == -1) {
                return 0;
            } else {
                return self._value
            }
        }
        set {
            if (self._value == -1) {
                self.originalValue = newValue
            }
            self._value = newValue
        }
    }
    
    func getMinMergeValue() -> Int {
        return self.value
    }
    
    func getMaxMergeValue() -> Int {
        return self.value
    }
    
    func canMergeWithPiece(hexPiece: HexPiece) -> Bool {
        if (self.value == hexPiece.value && self.value < HexMapHelper.instance.maxPieceValue) {
            return true
        } else {
            return false
        }
    }
    
    func canPlaceWithoutMerge() -> Bool {
        return true
    }
    
    func wasPlacedWithMerge() {
        self.sprite!.texture = HexMapHelper.instance.hexPieceTextures[self.value]
    }
    
    func wasPlacedWithoutMerge() {
        //
    }
    
    func wasUnplaced() {
        self.value = self.originalValue
        self.sprite!.texture = HexMapHelper.instance.hexPieceTextures[self.value]
    }
    
    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: HexMapHelper.instance.hexPieceTextures[self.value])
    
        node.name = "hexPiece"
    
        return node
    }
    
}