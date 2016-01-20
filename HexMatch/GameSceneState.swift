//
//  GameSceneState.swift
//  HexMatch
//
//  Created by Josh McKee on 1/19/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import GameKit

class GameSceneState: GKState {
    var scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
}

class GameScenePlayingState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameSceneGameOverState.Type
    }
    
}

class GameSceneGameOverState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameScenePlayingState.Type
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        
    }
}
