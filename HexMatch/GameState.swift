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
    var bankPoints: Int
    var hexMap: HexMap
    var currentPiece: HexPiece?
    var lastPlacedPiece: HexPiece?
    var stashPiece: HexPiece?
    var unlockedLevels: [LevelHelperMode] = Array()
    var levelHelperMode: LevelHelperMode
    var buyablePieces: [BuyablePiece] = Array()
    var optionsInt: [String:Int]
    
    override init() {
        self.highScore = 0
        self.score = 0
        self.bankPoints = 25000
        self.hexMap = HexMap(7,7)
        
        self.unlockedLevels.append(.Welcome)
        self.unlockedLevels.append(.Hexagon)
        
        self.levelHelperMode = .Welcome
        
        self.optionsInt = [
            "include_mobile_pieces": 1,
            "include_enemy_pieces": 1,
            "enable_sound_effects": 1,
        ]
        
        super.init()
        
        self.resetBuyablePieces()
    }

    func getIntForKey(key: String, _ defaultValue: Int) -> Int {
        return self.optionsInt[key] != nil ? self.optionsInt[key]! : defaultValue
    }
    
    func setIntForKey(key: String, _ value: Int) {
        self.optionsInt[key] = value
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.highScore = (decoder.decodeObjectForKey("highScore") as? Int)!
        self.score = (decoder.decodeObjectForKey("score") as? Int)!
        
        let bankPoints = decoder.decodeObjectForKey("bankPoints")
        if (bankPoints != nil) {
            self.bankPoints = (bankPoints as? Int)!
        }
        
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
        
        let levels = decoder.decodeObjectForKey("unlockedLevels")
        if (levels != nil) {
            for levelRaw in (levels as! [Int]) {
                let unlockedLevel = LevelHelperMode(rawValue: (levelRaw))!
                
                if (!self.unlockedLevels.contains(unlockedLevel)) {
                    self.unlockedLevels.append(unlockedLevel)
                }
            }
        }
        
        let levelHelperMode = decoder.decodeObjectForKey("levelHelperMode")
        if (levelHelperMode != nil) {
            LevelHelper.instance.mode = LevelHelperMode(rawValue: levelHelperMode as! Int)!
        }
        
        let buyablePieces = decoder.decodeObjectForKey("buyablePieces")
        if (buyablePieces != nil) {
            self.buyablePieces = buyablePieces as! [BuyablePiece]
        } else {
            self.resetBuyablePieces()
        }
        
        let optionsInt = decoder.decodeObjectForKey("optionsInt")
        if (optionsInt != nil) {
            self.optionsInt = optionsInt as! [String:Int]
        }
        
        // Ensure that we always have Welcome and Hexagon levels available
        if (!self.unlockedLevels.contains(.Welcome)) {
             self.unlockedLevels.append(.Welcome)
        }
        
        if (!self.unlockedLevels.contains(.Hexagon)) {
             self.unlockedLevels.append(.Hexagon)
        }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.highScore, forKey: "highScore")
        coder.encodeObject(self.score, forKey: "score")
        coder.encodeObject(self.bankPoints, forKey: "bankPoints")
        coder.encodeObject(self.hexMap, forKey: "hexMap")
        coder.encodeObject(self.currentPiece, forKey: "currentPiece")
        coder.encodeObject(self.lastPlacedPiece, forKey: "lastPlacedPiece")
        coder.encodeObject(self.stashPiece, forKey: "stashPiece")
        
        coder.encodeObject(self.optionsInt, forKey: "optionsInt")
        
        var levels:[Int] = Array()
        
        for unlockedLevel in self.unlockedLevels {
            levels.append(unlockedLevel.rawValue)
        }
        coder.encodeObject(levels, forKey: "unlockedLevels")
        
        coder.encodeObject(LevelHelper.instance.mode.rawValue, forKey: "levelHelperMode")
        
        coder.encodeObject(self.buyablePieces, forKey: "buyablePieces")
    }
    
    func resetBuyablePieces() {
        self.buyablePieces.removeAll()
        
        for pieceValue in 0...2 {
            let buyablePiece = BuyablePiece()
            
            buyablePiece.value = pieceValue
            buyablePiece.basePrice = (pieceValue + 1) * 500
            buyablePiece.currentPrice = (pieceValue + 1) * 500
            
            self.buyablePieces.append(buyablePiece)
        }
        
        self.buyablePieces.append(WildcardBuyablePiece())
        
        self.buyablePieces.append(RemoveBuyablePiece())
    }
}