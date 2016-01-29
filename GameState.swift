//
//  GameState.swift
//  HexMatch
//
//  Created by Josh McKee on 1/17/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

class GameState: NSObject, NSCoding {
    // singleton
    static var instance: GameState?
    
    var highScore: Int
    var score: Int
    var hexMap: HexMap
    var currentPiece: HexPiece?
    var lastPlacedPiece: HexPiece?
    var stashPiece: HexPiece?
    
    override init() {
        self.highScore = 0
        self.score = 0
        self.hexMap = HexMap(7,7)
        
        super.init()
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.highScore = (decoder.decodeObjectForKey("highScore") as? Int)!
        self.score = (decoder.decodeObjectForKey("score") as? Int)!
        
        let hexMap = decoder.decodeObjectForKey("hexMap")
        if (hexMap != nil) {
            self.hexMap = (hexMap as? HexMap)!
        }
        
        let currentPiece = decoder.decodeObjectForKey("currentPiece")
        if (currentPiece != nil) {
            self.currentPiece = (currentPiece as? HexPiece)!
        }
        
        let lastPlacedPiece = decoder.decodeObjectForKey("lastPlacedPiece")
        if (lastPlacedPiece != nil) {
            self.lastPlacedPiece = (lastPlacedPiece as? HexPiece)!
        }
        
        let stashPiece = decoder.decodeObjectForKey("stashPiece")
        if (stashPiece != nil) {
            self.stashPiece = (stashPiece as? HexPiece)!
        }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.highScore, forKey: "highScore")
        coder.encodeObject(self.score, forKey: "score")
        coder.encodeObject(self.hexMap, forKey: "hexMap")
        coder.encodeObject(self.currentPiece, forKey: "currentPiece")
        coder.encodeObject(self.lastPlacedPiece, forKey: "lastPlacedPiece")
        coder.encodeObject(self.stashPiece, forKey: "stashPiece")
    }
}