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
    var goalScore: Int
    var bankPoints: Int
    var hexMap: HexMap
    var currentPiece: HexPiece?
    var lastPlacedPiece: HexPiece?
    var stashPiece: HexPiece?
    var unlockedLevels: [LevelHelperMode] = Array()
    var levelHelperMode: LevelHelperMode
    var buyablePieces: [BuyablePiece] = Array()
    var optionsInt: [String:Int]
    var pieceStack = Stack<HexPiece>()
    
    override init() {
        self.highScore = 0
        self.score = 0
        self.goalScore = 250000
        self.bankPoints = 25000
        self.hexMap = HexMap(7,7)
        
        self.unlockedLevels.append(.welcome)
        self.unlockedLevels.append(.hexagon)
        self.unlockedLevels.append(.bighex)
        
        self.levelHelperMode = .welcome
        
        self.optionsInt = [
            "include_mobile_pieces": 1,
            "include_enemy_pieces": 1,
            "enable_sound_effects": 1,
        ]
        
        super.init()
        
        self.resetBuyablePieces()
    }

    func getIntForKey(_ key: String, _ defaultValue: Int) -> Int {
        return self.optionsInt[key] != nil ? self.optionsInt[key]! : defaultValue
    }
    
    func setIntForKey(_ key: String, _ value: Int) {
        self.optionsInt[key] = value
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.highScore = decoder.decodeInteger(forKey: "highScore")
        self.score = decoder.decodeInteger(forKey: "score")
        self.goalScore = decoder.decodeInteger(forKey: "goalScore")
        self.bankPoints = decoder.decodeInteger(forKey: "bankPoints")
        
        if (self.goalScore == 0) {
            self.goalScore = 250000
        }
        
        let hexMap = decoder.decodeObject(forKey: "hexMap")
        if (hexMap != nil) {
            self.hexMap = (hexMap as? HexMap)!
        }
        
        let currentPiece = decoder.decodeObject(forKey: "currentPiece")
        if (currentPiece != nil) {
            self.currentPiece = (currentPiece as? HexPiece)!
        }
        
        let lastPlacedPiece = decoder.decodeObject(forKey: "lastPlacedPiece")
        if (lastPlacedPiece != nil) {
            self.lastPlacedPiece = (lastPlacedPiece as? HexPiece)!
        }
        
        let stashPiece = decoder.decodeObject(forKey: "stashPiece")
        if (stashPiece != nil) {
            self.stashPiece = (stashPiece as? HexPiece)!
        }
        
        let levels = decoder.decodeObject(forKey: "unlockedLevels")
        if (levels != nil) {
            for levelRaw in (levels as! [Int]) {
                let unlockedLevel = LevelHelperMode(rawValue: (levelRaw))!
                
                if (!self.unlockedLevels.contains(unlockedLevel)) {
                    self.unlockedLevels.append(unlockedLevel)
                }
            }
        }
        
        let levelHelperMode = decoder.decodeInteger(forKey: "levelHelperMode")
        LevelHelper.instance.mode = LevelHelperMode(rawValue: levelHelperMode)!
        
        let buyablePieces = decoder.decodeObject(forKey: "buyablePieces")
        if (buyablePieces != nil) {
            self.buyablePieces = buyablePieces as! [BuyablePiece]
        } else {
            self.resetBuyablePieces()
        }
        
        let optionsInt = decoder.decodeObject(forKey: "optionsInt")
        if (optionsInt != nil) {
            self.optionsInt = optionsInt as! [String:Int]
        }
        
        // Ensure that we always have Welcome and Hexagon levels available
        if (!self.unlockedLevels.contains(.welcome)) {
             self.unlockedLevels.append(.welcome)
        }
        
        if (!self.unlockedLevels.contains(.hexagon)) {
             self.unlockedLevels.append(.hexagon)
        }
        
        if (!self.unlockedLevels.contains(.bighex)) {
            self.unlockedLevels.append(.bighex)
        }
        
        let pieceStack = decoder.decodeObject(forKey: "pieceStack")
        if (pieceStack != nil) {
            self.pieceStack.items = pieceStack as! [HexPiece]
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.highScore, forKey: "highScore")
        coder.encode(self.score, forKey: "score")
        coder.encode(self.goalScore, forKey: "goalScore")
        coder.encode(self.bankPoints, forKey: "bankPoints")
        coder.encode(self.hexMap, forKey: "hexMap")
        coder.encode(self.currentPiece, forKey: "currentPiece")
        coder.encode(self.lastPlacedPiece, forKey: "lastPlacedPiece")
        coder.encode(self.stashPiece, forKey: "stashPiece")
        
        coder.encode(self.optionsInt, forKey: "optionsInt")
        
        var levels:[Int] = Array()
        
        for unlockedLevel in self.unlockedLevels {
            levels.append(unlockedLevel.rawValue)
        }
        coder.encode(levels, forKey: "unlockedLevels")
        
        coder.encode(LevelHelper.instance.mode.rawValue, forKey: "levelHelperMode")
        
        coder.encode(self.buyablePieces, forKey: "buyablePieces")
        
        coder.encode(self.pieceStack.items, forKey: "pieceStack")
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
