//
//  HexMatchStateMachine.swift
//  HexMatch
//
//  Created by Josh McKee on 1/19/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import GameKit

open class GameStateMachine: GKStateMachine {
    
    static var instance: GameStateMachine?
    
    var blocked: Bool = false
    
    init(scene:GameScene) {
        super.init(states: [
            GameSceneInitialState(scene: scene),
            GameSceneRestartState(scene: scene),
            GameScenePlayingState(scene: scene),
            GameSceneMergingState(scene: scene),
            GameSceneEnemyState(scene: scene),
            GameSceneGameOverState(scene: scene)
        ]);
    }
    
}
