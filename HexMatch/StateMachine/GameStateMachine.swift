//
//  HexMatchStateMachine.swift
//  HexMatch
//
//  Created by Josh McKee on 1/19/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import GameKit

public class GameStateMachine: GKStateMachine {
    
    static var instance: GameStateMachine?
    
    init(scene:GameScene) {
        super.init(states: [
            GameScenePlayingState(scene: scene),
            GameSceneGameOverState(scene: scene)
        ]);
    }
    
}