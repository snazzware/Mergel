//
//  GameState.swift
//  HexMatch
//
//  Created by Josh McKee on 1/17/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

enum GameMode : String {
    case Playing = "Playing"
    case GameOver = "Game Over"
}

class GameState: NSObject, NSCoding {
    // singleton
    static var instance: GameState?
    
    var highScore: Int
    var gameMode: GameMode
    
    override init() {
        self.highScore = 0
        self.gameMode = .Playing
        
        super.init()
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.highScore = (decoder.decodeObjectForKey("highScore") as? Int)!
        self.gameMode = GameMode(rawValue: (decoder.decodeObjectForKey("gameMode") as! String))!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.highScore, forKey: "highScore")
        coder.encodeObject(self.gameMode.rawValue, forKey: "gameMode")
    }
}