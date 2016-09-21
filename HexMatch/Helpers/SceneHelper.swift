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
    var statsScene: StatsScene
    var newGameScene: NewGameScene
    var splashScene: SplashScene
    
    override init() {
        self.gameScene = GameScene()
        self.levelScene = LevelScene()
        self.bankScene = BankScene()
        self.statsScene = StatsScene()
        self.newGameScene = NewGameScene()
        self.splashScene = SplashScene()
        
        // Resize modes
        self.gameScene.scaleMode = .resizeFill
        self.levelScene.scaleMode = .resizeFill
        self.bankScene.scaleMode = .resizeFill
        self.statsScene.scaleMode = .resizeFill
        self.newGameScene.scaleMode = .resizeFill
        self.splashScene.scaleMode = .resizeFill
        
        // Set initial gui positions
        self.levelScene.updateGui()        
        self.statsScene.updateGui()
        
        super.init()
    }
    
    func didRotateFromInterfaceOrientation(_ fromInterfaceOrientation: UIInterfaceOrientation) {
        self.gameScene.updateGuiPositions()
        self.levelScene.updateGui()
        self.bankScene.updateGui()
        self.statsScene.updateGui()
        self.newGameScene.updateGui()
    }
}
