//
//  SceneHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/28/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import UIKit

class SceneHelper: NSObject {
    // singleton
    static var instance = SceneHelper()

    // scenes
    var gameScene: GameScene
    var levelScene: LevelScene
    var bankScene: BankScene
    
    override init() {
        self.gameScene = GameScene()
        self.levelScene = LevelScene()
        self.bankScene = BankScene()
        
        // Resize modes
        self.gameScene.scaleMode = .ResizeFill
        self.levelScene.scaleMode = .ResizeFill
        self.bankScene.scaleMode = .ResizeFill
        
        // Set initial gui positions
        self.levelScene.updateGui()
        self.bankScene.updateGui()
        
        super.init()
    }
    
    func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.gameScene.updateGuiPositions()
        self.levelScene.updateGui()
        self.bankScene.updateGui()
    }
}