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
    }
    
    func enableSoundEffects() {
        self.placePiece = SKAction.playSoundFileNamed("pop_9", waitForCompletion: false)
        self.mergePieces = SKAction.playSoundFileNamed("shuffle", waitForCompletion: false)
    }
}