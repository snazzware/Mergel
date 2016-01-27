//
//  HexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class HexPiece : NSObject, NSCoding {

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
                if (self._hexCell != newValue) {
                    self._hexCell!.hexPiece = nil
                }
                self.lastX = self._hexCell!.x
                self.lastY = self._hexCell!.y
            }
        }
    }
    var sprite: SKSpriteNode?
    
    // How many turns we have left to skip, and how many we should skip after being placed.
    var skipTurnCounter = 0
    var skipTurnsOnPlace = 1
    
    // Value tracking
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
    
    override init() {
        super.init()
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
        self.skipTurnCounter = self.skipTurnsOnPlace
    }
    
    func wasPlacedWithoutMerge() {
        self.skipTurnCounter = self.skipTurnsOnPlace
    }
    
    func wasUnplaced() {
        self.value = self.originalValue
        self.skipTurnCounter = self.skipTurnsOnPlace
        self.sprite!.texture = HexMapHelper.instance.hexPieceTextures[self.value]
    }
    
    func getPointValue() -> Int {
        var points = 10
        
        switch (self.value) {
            case 0: // Triangle
            break
            case 1: // Rhombus
                points = 100
            break
            case 2: // Square
                points = 500
            break
            case 3: // Pentagon
                points = 1000
            break
            case 4: // Hexagon
                points = 10000
            break
            case 5: // Star
                points = 25000
            break
            default:
            break
        }
        
        return points
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
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
    
        self.originalValue = (decoder.decodeObjectForKey("originalValue") as? Int)!
        self.value = (decoder.decodeObjectForKey("value") as? Int)!
        self.lastX = (decoder.decodeObjectForKey("lastX") as? Int)!
        self.lastY = (decoder.decodeObjectForKey("lastY") as? Int)!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.originalValue, forKey: "originalValue")
        coder.encodeObject(self.value, forKey: "value")
        coder.encodeObject(self.lastX, forKey: "lastX")
        coder.encodeObject(self.lastY, forKey: "lastY")
    }
    
    func takeTurn() -> Bool {
        if (skipTurnCounter > 0) {
            skipTurnCounter--
            return false
        }
        return true
    }
    
}