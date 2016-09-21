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

// Occurs once when app starts
class GameSceneInitialState: GameSceneState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return ((stateClass is GameScenePlayingState.Type) || (stateClass is GameSceneRestartState.Type))
    }
    
}

// Sets up a new game
class GameSceneRestartState: GameSceneState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let result = (stateClass is GameScenePlayingState.Type)
        
        return result
    }
    
    override func didEnter(from previousState: GKState?) {
        // Start fresh copy of level
        self.scene.resetLevel()
        
        // Enter playing state
        GameStateMachine.instance!.enter(GameScenePlayingState.self)
    }
    
}

// Player is making move
class GameScenePlayingState: GameSceneState {
    
    override func didEnter(from previousState: GKState?) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let result = ((stateClass is GameSceneGameOverState.Type) || (stateClass is GameSceneRestartState.Type) || (stateClass is GameSceneMergingState.Type))
        
        return result
    }
    
}

// Pieces is merging
class GameSceneMergingState: GameSceneState {
    
    override func didEnter(from previousState: GKState?) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let result = (stateClass is GameSceneEnemyState.Type)
        
        return result
    }
    
}

// Enemy is making moves
class GameSceneEnemyState: GameSceneState {
    
    override func didEnter(from previousState: GKState?) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let result = (stateClass is GameScenePlayingState.Type || (stateClass is GameSceneGameOverState.Type))
        
        return result
    }
    
}

// Game is over
class GameSceneGameOverState: GameSceneState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let result = ((stateClass is GameSceneRestartState.Type))

        return result
    }
    
    override func didEnter(from previousState: GKState?) {
        self.scene.showGameOver()
    }
    
    override func willExit(to nextState: GKState) {
        self.scene.hideGameOver()
    }
}
