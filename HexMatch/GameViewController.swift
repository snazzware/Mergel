//
//  GameViewController.swift
//  HexMatch
//
//  Created by Josh McKee on 1/11/16.
//  Copyright (c) 2016 Josh McKee. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Init sound helper
        if (GameState.instance!.getIntForKey("enable_sound_effects", 1) == 1) {
            SoundHelper.instance.enableSoundEffects()
        }

        self.scene = SceneHelper.instance.gameScene
        
        // Init state machine
        GameStateMachine.instance = GameStateMachine(scene: SceneHelper.instance.gameScene)
        GameStateMachine.instance!.enterState(GameSceneInitialState.self)
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.scene!.scaleMode = .ResizeFill
        
        skView.presentScene(SceneHelper.instance.splashScene)
        
        // GameKit
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.showAuthenticationViewController), name: PresentAuthenticationViewController, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.showGKGameCenterViewController), name: ShowGKGameCenterViewController, object: nil)
        GameKitHelper.sharedInstance.authenticateLocalPlayer()
    }
    
    func showAuthenticationViewController() {
        
        let gameKitHelper = GameKitHelper.sharedInstance
        
        if let authenticationViewController = gameKitHelper.authenticationViewController {
            self.presentViewController(authenticationViewController, animated: true, completion: nil)
        }
    }
    
    func showGKGameCenterViewController() {
        GameKitHelper.sharedInstance.showGKGameCenterViewController(self)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        SceneHelper.instance.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }
}
