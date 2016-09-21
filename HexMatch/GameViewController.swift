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
        GameStateMachine.instance!.enter(GameSceneInitialState.self)
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.scene!.scaleMode = .resizeFill
        
        skView.presentScene(SceneHelper.instance.splashScene)
        
        // GameKit
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showAuthenticationViewController), name: NSNotification.Name(rawValue: PresentAuthenticationViewController), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showGKGameCenterViewController), name: NSNotification.Name(rawValue: ShowGKGameCenterViewController), object: nil)
        GameKitHelper.sharedInstance.authenticateLocalPlayer()
    }
    
    func showAuthenticationViewController() {
        
        let gameKitHelper = GameKitHelper.sharedInstance
        
        if let authenticationViewController = gameKitHelper.authenticationViewController {
            self.present(authenticationViewController, animated: true, completion: nil)
        }
    }
    
    func showGKGameCenterViewController() {
        GameKitHelper.sharedInstance.showGKGameCenterViewController(self)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        SceneHelper.instance.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }
}
