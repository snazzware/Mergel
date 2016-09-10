//
//  SoundHelper.swift
//  HexMatch
//
//  Created by Josh McKee on 1/29/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class SoundHelper: NSObject {
    // singleton
    static var instance = SoundHelper()

    // sounds
    var placePiece = SKAction.runBlock({})
    var mergePieces = SKAction.runBlock({})
    
    var placeEnemy = SKAction.runBlock({})
    
    var unlock = SKAction.runBlock({})
    var collect = SKAction.runBlock({})
    
    var gameover = SKAction.runBlock({})
    
    override init() {
        // Allow background music
        
        let sess = AVAudioSession.sharedInstance()

        _ = try? sess.setCategory(AVAudioSessionCategoryAmbient, withOptions: [])
        _ = try? sess.setActive(true, withOptions: [])
        
        super.init()
    }
    
    func disableSoundEffects() {
        self.placePiece = SKAction.runBlock({})
        self.mergePieces = SKAction.runBlock({})
        self.placeEnemy = SKAction.runBlock({})
        self.unlock = SKAction.runBlock({})
        self.collect = SKAction.runBlock({})
        self.gameover = SKAction.runBlock({})
    }
    
    func enableSoundEffects() {
        self.placePiece = SKAction.playSoundFileNamed("pop_9", waitForCompletion: false)
        self.mergePieces = SKAction.playSoundFileNamed("DM-CGS-19", waitForCompletion: false)
        self.placeEnemy = SKAction.playSoundFileNamed("251938__binarymonkflint__frog", waitForCompletion: false)
        self.unlock = SKAction.playSoundFileNamed("SUCCESS CHEERS Win Cute Vocal Chime 03", waitForCompletion: false)
        self.collect = SKAction.playSoundFileNamed("SUCCESS PICKUP Collect Chime 01", waitForCompletion: false)
        self.gameover = SKAction.playSoundFileNamed("133283__fins__game-over", waitForCompletion: false)
    }
}