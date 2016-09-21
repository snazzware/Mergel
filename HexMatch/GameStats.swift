//
//  GameStats.swift
//  HexMatch
//
//  Created by Josh McKee on 2/4/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

class GameStats: NSObject, NSCoding {
    // singleton
    static var instance: GameStats?
    
    var statsInt: [String:Int]
    
    let lock = Spinlock()
    
    let statNames: [String:String] = [
        "piece_value_0": "Pieces Placed or Merged/Triangle",
        "piece_value_1": "Pieces Placed or Merged/Square",
        "piece_value_2": "Pieces Placed or Merged/Pentagon",
        "piece_value_3": "Pieces Placed or Merged/Hexagon",
        "piece_value_4": "Pieces Placed or Merged/Star",
        "piece_value_5": "Pieces Placed or Merged/Gold Star",
        "piece_value_6": "Pieces Placed or Merged/Gold Stars (collectible)",
        "piece_wildcard_0": "Pieces Placed or Merged/Black Star",
        "piece_wildcard_999": "Pieces Placed or Merged/Bowie Bolt",
        "piece_vanillabean_1000": "Pieces Placed or Merged/Vanilla Gel",
        "piece_vanillabean_1001": "Pieces Placed or Merged/Vanilla Jelly Bean",
        "piece_vanillabean_1002": "Pieces Placed or Merged/Vanilla Jelly Beans (collectible)",
        "highscore_"+String(LevelHelperMode.welcome.rawValue): "High Scores/Tutorial",
        "highscore_"+String(LevelHelperMode.hexagon.rawValue): "High Scores/Beginner",
        "highscore_"+String(LevelHelperMode.moat.rawValue): "High Scores/The Moat",
        "highscore_"+String(LevelHelperMode.pit.rawValue): "High Scores/The Pit"
    ]
    
    override init() {
        
        self.statsInt = [
            "piece_value_0": 0,
            "piece_value_1": 0,
            "piece_value_2": 0,
            "piece_value_3": 0,
            "piece_value_4": 0,
            "piece_value_5": 0,
            "piece_value_6": 0,
            "piece_wildcard_0": 0,
            "piece_wildcard_999": 0,
            "piece_vanillabean_1000": 0,
            "piece_vanillabean_1001": 0,
            "piece_vanillabean_1002": 0,
            "highscore_"+String(LevelHelperMode.welcome.rawValue): 0,
            "highscore_"+String(LevelHelperMode.hexagon.rawValue): 0,
            "highscore_"+String(LevelHelperMode.moat.rawValue): 0,
            "highscore_"+String(LevelHelperMode.pit.rawValue): 0
        ]
        
        super.init()
    }

    func getIntForKey(_ key: String, _ defaultValue: Int = 0) -> Int {
        return self.statsInt[key] != nil ? self.statsInt[key]! : defaultValue
    }
    
    func setIntForKey(_ key: String, _ value: Int) {
        self.lock.around {
            self.statsInt[key] = value
        }
    }
    
    func incIntForKey(_ key: String, _ amount: Int = 1) {
        self.lock.around {
            if (self.statsInt[key] == nil) {
                self.statsInt[key] = amount
            } else {
                self.statsInt[key]? += amount
            }
        }
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        let statsInt = decoder.decodeObject(forKey: "statsInt")
        if (statsInt != nil) {
            self.statsInt = statsInt as! [String:Int]
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.statsInt, forKey: "statsInt")
    }
    
    func updateGameCenter() {
        // Overall high score
        GameKitHelper.sharedInstance.reportScore(Int64(GameState.instance!.highScore), forLeaderBoardId: "com.snazzware.mergel.HighScore")
        
        // Map-specific high scores
        GameKitHelper.sharedInstance.reportScore(Int64(self.statsInt["highscore_"+String(LevelHelperMode.hexagon.rawValue)]!), forLeaderBoardId: "com.snazzware.mergel.HighScore.Beginner")
        GameKitHelper.sharedInstance.reportScore(Int64(self.statsInt["highscore_"+String(LevelHelperMode.pit.rawValue)]!), forLeaderBoardId: "com.snazzware.mergel.HighScore.Pit")
        GameKitHelper.sharedInstance.reportScore(Int64(self.statsInt["highscore_"+String(LevelHelperMode.moat.rawValue)]!), forLeaderBoardId: "com.snazzware.mergel.HighScore.Moat")
        
    }
    
}
