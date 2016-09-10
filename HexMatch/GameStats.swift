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
        "piece_value_0": "Pieces Placed or Merged by Type/Triangle",
        "piece_value_1": "Pieces Placed or Merged by Type/Square",
        "piece_value_2": "Pieces Placed or Merged by Type/Pentagon",
        "piece_value_3": "Pieces Placed or Merged by Type/Hexagon",
        "piece_value_4": "Pieces Placed or Merged by Type/Star",
        "piece_value_5": "Pieces Placed or Merged by Type/Gold Star",
        "piece_wilecard_0": "Pieces Placed or Merged by Type/Black Star",
        "piece_wildcard_1": "Pieces Placed or Merged by Type/Bowie Bolt",
        "piece_vanillabean_0": "Pieces Placed or Merged by Type/Vanilla Gel",
        "piece_vanillabean_1": "Pieces Placed or Merged by Type/Vanilla Jelly Bean",
        "piece_vanillabean_2": "Pieces Placed or Merged by Type/Vanilla Jelly Beans (collectible)",
        "highscore_"+String(LevelHelperMode.Welcome.rawValue): "High Scores/Tutorial",
        "highscore_"+String(LevelHelperMode.Hexagon.rawValue): "High Scores/Beginner",
        "highscore_"+String(LevelHelperMode.Moat.rawValue): "High Scores/The Moat",
        "highscore_"+String(LevelHelperMode.Pit.rawValue): "High Scores/The Pit"
    ]
    
    override init() {
        
        self.statsInt = [
            "piece_value_0": 0,
            "piece_value_1": 0,
            "piece_value_2": 0,
            "piece_value_3": 0,
            "piece_value_4": 0,
            "piece_value_5": 0,
            "piece_wildcard_0": 0,
            "piece_wildcard_999": 0,
            "piece_vanillabean_0": 0,
            "piece_vanillabean_1": 0,
            "piece_vanillabean_2": 0,
            "highscore_"+String(LevelHelperMode.Welcome.rawValue): 0,
            "highscore_"+String(LevelHelperMode.Hexagon.rawValue): 0,
            "highscore_"+String(LevelHelperMode.Moat.rawValue): 0,
            "highscore_"+String(LevelHelperMode.Pit.rawValue): 0
        ]
        
        super.init()
    }

    func getIntForKey(key: String, _ defaultValue: Int = 0) -> Int {
        return self.statsInt[key] != nil ? self.statsInt[key]! : defaultValue
    }
    
    func setIntForKey(key: String, _ value: Int) {
        self.lock.around {
            self.statsInt[key] = value
        }
    }
    
    func incIntForKey(key: String, _ amount: Int = 1) {
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
        
        let statsInt = decoder.decodeObjectForKey("statsInt")
        if (statsInt != nil) {
            self.statsInt = statsInt as! [String:Int]
        }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.statsInt, forKey: "statsInt")
    }
    
    func updateGameCenter() {
        // Overall high score
        GameKitHelper.sharedInstance.reportScore(Int64(GameState.instance!.highScore), forLeaderBoardId: "com.snazzware.mergel.HighScore")
        
        // Map-specific high scores
        GameKitHelper.sharedInstance.reportScore(Int64(self.statsInt["highscore_"+String(LevelHelperMode.Hexagon.rawValue)]!), forLeaderBoardId: "com.snazzware.mergel.HighScore.Beginner")
        GameKitHelper.sharedInstance.reportScore(Int64(self.statsInt["highscore_"+String(LevelHelperMode.Pit.rawValue)]!), forLeaderBoardId: "com.snazzware.mergel.HighScore.Pit")
        GameKitHelper.sharedInstance.reportScore(Int64(self.statsInt["highscore_"+String(LevelHelperMode.Moat.rawValue)]!), forLeaderBoardId: "com.snazzware.mergel.HighScore.Moat")
        
    }
    
}