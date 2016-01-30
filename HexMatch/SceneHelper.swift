//
//  SceneHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/28/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation

import Foundation

class SceneHelper: NSObject {
    // singleton
    static var instance = SceneHelper()

    // scenes
    var gameScene: GameScene
    var levelScene: LevelScene
    
    override init() {
        self.gameScene = GameScene()
        self.levelScene = LevelScene()
        
        self.levelScene.updateGui()
        
        // Resize modes
        self.gameScene.scaleMode = .ResizeFill
        self.levelScene.scaleMode = .ResizeFill
    
        super.init()
    }
}