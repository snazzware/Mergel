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
    
    override init() {
        self.highScore = 0
        self.score = 0
        self.bankPoints = 0
        self.hexMap = HexMap(7,7)
        
        self.unlockedLevels.append(.Welcome)
        
        self.levelHelperMode = .Welcome
        
        super.init()
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
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.highScore, forKey: "highScore")
        coder.encodeObject(self.score, forKey: "score")
        coder.encodeObject(self.bankPoints, forKey: "bankPoints")
        coder.encodeObject(self.hexMap, forKey: "hexMap")
        coder.encodeObject(self.currentPiece, forKey: "currentPiece")
        coder.encodeObject(self.lastPlacedPiece, forKey: "lastPlacedPiece")
        coder.encodeObject(self.stashPiece, forKey: "stashPiece")
        
        var levels:[Int] = Array()
        
        for unlockedLevel in self.unlockedLevels {
            levels.append(unlockedLevel.rawValue)
        }
        coder.encodeObject(levels, forKey: "unlockedLevels")
        
        coder.encodeObject(LevelHelper.instance.mode.rawValue, forKey: "levelHelperMode")
    }
}