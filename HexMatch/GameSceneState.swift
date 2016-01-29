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
        return ((stateClass is GameScenePlayingState.Type) || (stateClass is GameSceneRestartState.Type))
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("initial")
    
        // Set up GUI, etc.
        self.scene.initGame()
    
        // If hexMap is blank, enter restart state to set up new game
        if (GameState.instance!.hexMap.isBlank) {
            GameStateMachine.instance!.enterState(GameSceneRestartState.self)
        } else {
            GameStateMachine.instance!.enterState(GameScenePlayingState.self)
        }
    }
    
}

// Sets up a new game
class GameSceneRestartState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        let result = (stateClass is GameScenePlayingState.Type)
        print("is valid next state for \(self) \(stateClass) = \(result)")
        return result
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("restart")
        
        // Start fresh copy of level
        self.scene.resetLevel()
        
        // Enter playing state
        GameStateMachine.instance!.enterState(GameScenePlayingState.self)
    }
    
}

// Game is active
class GameScenePlayingState: GameSceneState {
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("playing")
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        let result = ((stateClass is GameSceneGameOverState.Type) || (stateClass is GameSceneRestartState.Type))
        print("is valid next state for \(self) \(stateClass) = \(result)")
        return result
    }
    
}

// Game is over
class GameSceneGameOverState: GameSceneState {
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        let result = ((stateClass is GameSceneRestartState.Type))

        return result
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        print("gameover")
        self.scene.showGameOver()
    }
    
    override func willExitWithNextState(nextState: GKState) {
        self.scene.hideGameOver()
    }
}
