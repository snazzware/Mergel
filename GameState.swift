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
    
    override init() {
        self.highScore = 0
        
        super.init()
    }

    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.highScore = (decoder.decodeObjectForKey("highScore") as? Int)!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.highScore, forKey: "highScore")
    }
}