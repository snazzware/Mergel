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
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameSceneRestartState.Type
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        // Set up GUI, etc.
        self.scene.initGame()
    
        // Start fresh copy of level
        GameStateMachine.instance!.enterState(GameSceneRestartState.self)
    }
    
}

// Sets up a new game
class GameSceneRestartState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameScenePlayingState.Type
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        // Start fresh copy of level
        self.scene.resetLevel()
        
        // Enter playing state
        GameStateMachine.instance!.enterState(GameScenePlayingState.self)
    }
    
}

// Game is active
class GameScenePlayingState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameSceneGameOverState.Type || stateClass is GameSceneRestartState.Type
    }
    
}

// Game is over
class GameSceneGameOverState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is GameSceneRestartState.Type
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        self.scene.showGameOver()
    }
    
    override func willExitWithNextState(nextState: GKState) {
        self.scene.hideGameOver()
    }
}
