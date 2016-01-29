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

        self.scene = SceneHelper.instance.gameScene
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.scene!.scaleMode = .ResizeFill
        
        skView.presentScene(self.scene!)
        
        // Init state machine
        GameStateMachine.instance = GameStateMachine(scene: self.scene!)
        GameStateMachine.instance!.enterState(GameSceneInitialState.self)
        
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
        if (self.scene != nil) {
            self.scene!.updateGuiPositions()
        }
    }
}
