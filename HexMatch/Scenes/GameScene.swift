//
//  GameScene.swift
//  HexMatch
//
//  Created by Josh McKee on 1/11/16.
//  Copyright (c) 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import CoreData
import SNZSpriteKitUI

class GameScene: SNZScene {
    var gameboardLayer = SKNode()
    var guiLayer = SKNode()
    
    var currentPieceLabel: SKLabelNode?
    var currentPieceHome = CGPointMake(0,0)
    var currentPieceSprite: SKSpriteNode?
    var currentPieceCaption: SKShapeNode?
    var currentPieceCaptionText: String = ""
    
    var stashPieceLabel: SKLabelNode?
    var stashPieceHome = CGPointMake(0,0)
    var stashBox: SKShapeNode?
    
    var menuButton: SNZTextureButtonWidget?
    var undoButton: SNZTextureButtonWidget?
    var gameOverLabel: SKLabelNode?
    var bankButton: BankButtonWidget?
    var stashButton: SNZButtonWidget?
    var currentButton: SNZButtonWidget?
    var statsButton: SNZButtonWidget?
    var highScoreButton: SNZButtonWidget?
    
    var uiTextScale:CGFloat = 1.0
    
    var scoreDisplay: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    var bankPointsDisplay: SKLabelNode?
    var bankPointsLabel: SKLabelNode?
    
    var highScoreDisplay: SKLabelNode?
    var highScoreLabel: SKLabelNode?
    
    var mergingPieces: [HexPiece] = Array()
    var mergedPieces: [HexPiece] = Array()

    var lastPlacedPiece: HexPiece?
    var lastPointsAwarded = 0
    
    var hexMap: HexMap?
    
    var undoState: NSData?
    
    var debugShape: SKShapeNode?
    
    let scoreFormatter = NSNumberFormatter()
    
    var _score = 0
    var score: Int {
        get {
            return self._score
        }
        set {
            self._score = newValue
            self.updateScore()
            
            // Update score in state
            GameState.instance!.score = self._score
            
            // Update overall high score
            if (self._score > GameState.instance!.highScore) {
                GameState.instance!.highScore = self._score
            }
            
            // Update level mode specific high score
            if (self._score > GameStats.instance!.getIntForKey("highscore_"+String(LevelHelper.instance.mode.rawValue))) {
                GameStats.instance!.setIntForKey("highscore_"+String(LevelHelper.instance.mode.rawValue), self._score)
                
                self.updateHighScore()
            }
        }
    }
    
    var _bankPoints = 0
    var bankPoints: Int {
        get {
            return self._bankPoints
        }
        set {
            self._bankPoints = newValue
            self.updateBankPoints()
            
            // Update score in state
            GameState.instance!.bankPoints = self._bankPoints
        }
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.updateGuiPositions()
    }
    
    func initGame() {
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Calculate font scale factor
        self.initScaling()
        
        // Add guiLayer to scene
        addChild(self.guiLayer)
        
        // Get the hex map and render it
        self.renderFromState()
        
        // Generate proxy sprite for current piece
        self.updateCurrentPieceSprite()
        
        // Add gameboardLayer to scene
        addChild(self.gameboardLayer)
        
        // Init bank points
        self.bankPoints = GameState.instance!.bankPoints
        
        // Init guiLayer
        self.initGuiLayer()
        
        // Check to see if we are already out of open cells, and change to end game state if so
        // e.g. in case state was saved during end game.
        if (HexMapHelper.instance.hexMap!.getOpenCells().count==0) {
            GameStateMachine.instance!.enterState(GameSceneGameOverState.self)
        }
    }
    
    func renderFromState() {
        // Init HexMap
        self.hexMap = GameState.instance!.hexMap
        
        // Init score
        self._score = GameState.instance!.score
        
        // Init level
        HexMapHelper.instance.hexMap = self.hexMap!
        
        // Render our hex map to the gameboardLayer
        HexMapHelper.instance.renderHexMap(gameboardLayer);
    }
    
    /**
        Reset game state. This includes clearing current score, stashed piece, current piece, and regenerating hexmap with a new random starting layout.
    */
    func resetLevel() {
        // Remove current piece, stash piece sprites
        self.removeTransientGuiSprites()
    
        // Clear the board
        HexMapHelper.instance.clearHexMap(self.gameboardLayer)
        
        // Clear the hexmap
        self.hexMap?.clear()
        
        // Generate level
        LevelHelper.instance.initLevel(self.hexMap!)
        
        // Generate new current piece
        self.generateCurrentPiece()
        
        // Generate proxy sprite for current piece
        self.updateCurrentPieceSprite()
        
        // Reset buyables
        GameState.instance!.resetBuyablePieces()
        
        // Clear stash
        if (GameState.instance!.stashPiece != nil) {
            if (GameState.instance!.stashPiece!.sprite != nil) {
                GameState.instance!.stashPiece!.sprite!.removeFromParent()
            }
            GameState.instance!.stashPiece = nil
        }
        
        // Render game board
        HexMapHelper.instance.renderHexMap(gameboardLayer);
        
        // Reset score
        self.score = 0
        
        // Update GUI
        self.updateGuiLayer()
        
        // Clear undo
        self.undoButton!.hidden = true
        self.undoState = nil
    }
    
    /**
        Handles touch begin and move events. Updates animations for any pieces which would be merged if the player were to end the touch event in the cell being touched, if any.
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.widgetTouchesBegan(touches, withEvent: event)) {
            return
        }
        
        let location = touches.first?.locationInNode(self)
        
        if (location != nil) {
            let nodes = nodesAtPoint(location!)
         
            for node in nodes {
                if (node.name == "hexMapCell") {
                    // Get cell using stord position from node's user data
                    let x = node.userData!.valueForKey("hexMapPositionX") as! Int
                    let y = node.userData!.valueForKey("hexMapPositionY") as! Int
                    
                    let cell = HexMapHelper.instance.hexMap!.cell(x,y)
    
                    // If we have a Remove piece, move it to the target cell regardless of contents
                    if (GameState.instance!.currentPiece != nil && GameState.instance!.currentPiece is RemovePiece) {
                        currentPieceSprite!.position = node.position
                    } else
                    // Otherwise, check to see if the cell will accept the piece
                    if (cell!.willAccept(GameState.instance!.currentPiece!)) {
                        self.updateMergingPieces(cell!)
                        
                        // Move to touched point
                        currentPieceSprite!.removeActionForKey("moveAnimation")
                        currentPieceSprite!.position = node.position
                    }
                }
            }
        }
    }
    
    /**
        touchesMoved override. We just call touchesBegan for this game, since the logic is the same.
    */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchesBegan(touches, withEvent: event)
    }
    
    /**
        touchesEnded override. Widgets first, then our own local game nodes.
    */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (self.widgetTouchesEnded(touches, withEvent: event) || touches.first == nil) {
            return
        }
        
        let location = touches.first?.locationInNode(self)
        
        if ((location != nil) && (GameStateMachine.instance!.currentState is GameScenePlayingState)) {
            for node in self.nodesAtPoint(location!) {
                if (self.nodeWasTouched(node)) {
                    break;
                }
            }
        }
    }
    
    /**
     
        Handle a node being touched. Place piece, merge, collect, etc.
     
    */
    func nodeWasTouched(node: SKNode) -> Bool {
        var handled = false
        
        if (node.name == "hexMapCell") {
            let x = node.userData!.valueForKey("hexMapPositionX") as! Int
            let y = node.userData!.valueForKey("hexMapPositionY") as! Int
            
            let cell = HexMapHelper.instance.hexMap!.cell(x,y)
            
            // Refresh merging pieces
            self.updateMergingPieces(cell!)
            
            // Do we have a Remove piece?
            if (GameState.instance!.currentPiece != nil && GameState.instance!.currentPiece is RemovePiece) {
                // Capture state for undo
                self.captureState()
                
                // Process the removal
                self.playRemovePiece(cell!)
            } else
            // Does the cell contain a collectible hex piece?
            if (cell!.hexPiece != nil && cell!.hexPiece!.isCollectible) {
                // Capture state for undo
                self.captureState()
                
                // Let the piece know it was collected
                cell!.hexPiece!.wasCollected()
                
                // Clear out the hex cell
                cell!.hexPiece = nil
            } else
            // Will the target cell accept our current piece, and will the piece either allow placement
            // without a merge, or if not, do we have a merge?
            if (cell!.willAccept(GameState.instance!.currentPiece!) && (GameState.instance!.currentPiece!.canPlaceWithoutMerge() || self.mergingPieces.count>0)) {
                // Capture state for undo
                self.captureState()
            
                // Store last placed piece, prior to any merging
                GameState.instance!.lastPlacedPiece = GameState.instance!.currentPiece

                // Place the current piece
                self.placeCurrentPiece(cell!)
            }
            
            handled = true
        }
        
        return handled
    }
    
    /**
        
        Handle the merging of pieces
     
    */
    func handleMerge(cell: HexCell) {
        // Are we merging pieces?
        if (self.mergingPieces.count>0) {
            var maxValue = 0
            
            // Remove animations from merging pieces, and find the maximum value
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeActionForKey("mergeAnimation")
                hexPiece.sprite!.setScale(1.0)
                if (hexPiece.value > maxValue) {
                    maxValue = hexPiece.value
                }
            }
            
            // Let piece know it was placed w/ merge
            GameState.instance!.currentPiece = GameState.instance!.currentPiece!.wasPlacedWithMerge(maxValue)
            
            // Store merged pieces, if any
            self.mergedPieces = self.mergingPieces
            
            // Create merge animation
            let moveAction = SKAction.moveTo(HexMapHelper.instance.hexMapToScreen(cell.position), duration: 0.15)
            let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
            
            // Remove merged pieces from board
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.runAction(moveSequence)
                hexPiece.hexCell?.hexPiece = nil
            }
        } else {
            // let piece know we are placing it
            GameState.instance!.currentPiece!.wasPlacedWithoutMerge()
        }
    }
    
    /**
        Take the current piece and place it in a given cell.
    */
    func placeCurrentPiece(cell: HexCell) {
        // Handle merging, if any
        self.handleMerge(cell)
    
        // Place the piece
        cell.hexPiece = GameState.instance!.currentPiece
        
        // Record statistic
        GameStats.instance!.incIntForKey(cell.hexPiece!.getStatsKey())
        
        // Move sprite from GUI to gameboard layer
        GameState.instance!.currentPiece!.sprite!.moveToParent(self.gameboardLayer)
        
        // Position on gameboard
        GameState.instance!.currentPiece!.sprite!.position = HexMapHelper.instance.hexMapToScreen(cell.position)
        
        // Award points
        self.awardPointsForPiece(GameState.instance!.currentPiece!)
        self.scrollPoints(self.lastPointsAwarded, position: GameState.instance!.currentPiece!.sprite!.position)
        
        // Generate new piece
        self.generateCurrentPiece()
        
        // Update current piece sprite
        self.updateCurrentPieceSprite()
        
        // End turn
        self.turnDidEnd()
    }
    
    /**
        Use a "remove" piece on a given cell. This causes the piece currently in the cell to be removed from play.
    */
    func playRemovePiece(cell: HexCell) {
        if (cell.hexPiece != nil) {
            // Let the piece know it was collected
            cell.hexPiece!.wasRemoved()
            
            // Clear out the hex cell
            cell.hexPiece = nil
            
            // Remove sprite
            GameState.instance!.currentPiece!.sprite!.removeFromParent()
            
            // Generate new piece
            self.generateCurrentPiece()
            
            // Update current piece sprite
            self.updateCurrentPieceSprite()
            
            // End turn
            self.turnDidEnd()
        }
    }
    
    /**
        Captures state for undo.
    */
    func captureState() {
        self.undoState = NSKeyedArchiver.archivedDataWithRootObject(GameState.instance!)
        
        // Show undo button
        self.undoButton!.hidden = false
    }
    
    /**
        Restores the previous state from undo.
    */
    func restoreState() {
        if (self.undoState != nil) {
            // Push the current piece back on to the stack
            if (GameState.instance!.currentPiece != nil) {
                LevelHelper.instance.pushPiece(GameState.instance!.currentPiece!)
            }
            
            // Remove current piece, stash piece sprites
            self.removeTransientGuiSprites()
        
            // Clear piece sprites from rendered hexmap
            HexMapHelper.instance.clearHexMap(self.gameboardLayer)
            
            // Load undo state
            GameState.instance = (NSKeyedUnarchiver.unarchiveObjectWithData(self.undoState!) as? GameState)!
            
            // Get the hex map and render it
            self.renderFromState()
            
            // Restore bank points
            self.bankPoints = GameState.instance!.bankPoints
            
            // Update gui
            self.updateGuiLayer()
            
            // Clear undo state
            self.undoState = nil
        }
    }
    
    /**
        Called after player has placed a piece. Processes moves for mobile pieces, checks for end game state.
    */
    func turnDidEnd() {
        let occupiedCells = HexMapHelper.instance.hexMap!.getOccupiedCells()
        
        // Give each piece a turn
        for occupiedCell in occupiedCells {
            occupiedCell.hexPiece?.takeTurn()
        }
        
        // Look for merges resulting from hexpiece turns
        var merges = HexMapHelper.instance.getFirstMerge();
        while (merges.count>0) {
            var mergeFocus: HexPiece?
            var highestAdded = -1
            var maxValue = 0
            
            for merged in merges {
                if (merged.added > highestAdded) {
                    highestAdded = merged.added
                    mergeFocus = merged
                }
                if (merged.value > maxValue) {
                    maxValue = merged.value
                }
            }
            
            // Create merge animation
            let moveAction = SKAction.moveTo(mergeFocus!.sprite!.position, duration: 0.15)
            let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
            
            var actualMerged: [HexPiece] = Array()
            
            // Remove merged pieces from board
            for merged in merges {
                if (merged != mergeFocus) {
                    actualMerged.append(merged)
                    merged.sprite!.runAction(moveSequence)
                    merged.hexCell?.hexPiece = nil
                }
            }
            
            // add pieces which were not the merge focus to our list of pieces merged on the last turn
            self.mergedPieces += actualMerged
            
            // let merge focus know it was merged
            mergeFocus = mergeFocus!.wasPlacedWithMerge(maxValue)
            
            // Award points
            self.awardPointsForPiece(mergeFocus!)
            self.scrollPoints(self.lastPointsAwarded, position: mergeFocus!.sprite!.position)
        
            // Get next merge
            merges = HexMapHelper.instance.getFirstMerge();
        }
        
        // Stick a proxy for the current piece on to the game board in an empty cell.
        // Calling this after all other pieces have taken their turn, to avoid doubling up
        // in a cell where a mobile has recently moved in.
        self.updateCurrentPieceSprite()
            
        // Test for game over
        if (HexMapHelper.instance.hexMap!.getOpenCells().count==0) {
            GameStateMachine.instance!.enterState(GameSceneGameOverState.self)
        }
    }
    
    /**
        Rolls back the last move made. Places removed merged pieces back on the board, removes points awarded, and calls self.restoreLastPiece, which puts the last piece played back in the currentPiece property.
    */
    func undoLastMove() {
        self.restoreState()
        
        // Hide undo button
        self.undoButton!.hidden = true    
    }
   
    /**
        Stops merge animation on any current set of would-be merged pieces, then updates self.mergingPieces with any merges which would occur if self.curentPiece were to be placed in cell. Stats merge animation on the new set of merging pieces, if any.
        
        - Parameters:
            - cell: The cell to test for merging w/ the current piece
    */
    func updateMergingPieces(cell: HexCell) {
        if (cell.willAccept(GameState.instance!.currentPiece!)) {
            // Stop animation on current merge set
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeActionForKey("mergeAnimation")
                hexPiece.sprite!.setScale(1.0)
            }
            
            self.mergingPieces = cell.getWouldMergeWith(GameState.instance!.currentPiece!)
            
            // Start animation on new merge set
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeActionForKey("mergeAnimation")
                hexPiece.sprite!.setScale(1.2)
            }
        }
    }
    
    func initScaling() {
        let width = (self.frame.width < self.frame.height) ? self.frame.width : self.frame.height
        
        if (width >= 375) {
            self.uiTextScale = 1.0
        } else {
            self.uiTextScale = width / 375
        }
        
        print("uiTextScale = \(self.uiTextScale)")
    }
    
    /**
        Initializes GUI layer components, sets up labels, buttons, etc.
    */
    func initGuiLayer() {
        // set up score formatter
        self.scoreFormatter.numberStyle = .DecimalStyle
    
        // Calculate size of upper UI
        let upperUsableArea = (self.frame.height < self.frame.width ? self.frame.height : self.frame.width) - SNZSpriteKitUITheme.instance.uiOuterMargins.horizontal
        
        var bankButtonWidth = (upperUsableArea / 2) - (SNZSpriteKitUITheme.instance.uiInnerMargins.horizontal / 3)
        var currentButtonWidth = (upperUsableArea / 4) - (SNZSpriteKitUITheme.instance.uiInnerMargins.horizontal / 3)
        var stashButtonWidth = currentButtonWidth
        
        bankButtonWidth = bankButtonWidth > 200 ? 200 : bankButtonWidth
        currentButtonWidth = currentButtonWidth > 100 ? 100 : currentButtonWidth
        stashButtonWidth = stashButtonWidth > 100 ? 100 : stashButtonWidth
    
        // Calculate current piece home position
        self.currentPieceHome = CGPoint(x: 80, y: self.frame.height - 70)
        
        // Add current piece label
        self.currentPieceLabel = self.createUILabel("Current")
        self.currentPieceLabel!.position = CGPoint(x: 20, y: self.frame.height - 40)
        self.currentPieceLabel!.horizontalAlignmentMode = .Center
        self.guiLayer.addChild(self.currentPieceLabel!)
        
        // Add current button
        self.currentButton = SNZButtonWidget()
        self.currentButton!.size = CGSizeMake(currentButtonWidth, 72)
        self.currentButton!.position = CGPoint(x: SNZSpriteKitUITheme.instance.uiOuterMargins.left, y: self.frame.height - 90)
        self.currentButton!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.currentButton!.focusBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        self.currentButton!.caption = ""
        self.currentButton!.bind("tap",{
            self.swapStash()
        })
        self.addWidget(self.currentButton!)
        
        // Calculate stash piece home position
        self.stashPieceHome = CGPoint(x: 180, y: self.frame.height - 70)
        
        // Add stash button
        self.stashButton = SNZButtonWidget()
        self.stashButton!.size = CGSizeMake(stashButtonWidth, 72)
        self.stashButton!.position = CGPoint(x: currentButton!.position.x + (SNZSpriteKitUITheme.instance.uiInnerMargins.left) + currentButtonWidth, y: self.frame.height - 90)
        self.stashButton!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.stashButton!.focusBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        self.stashButton!.caption = ""
        self.stashButton!.bind("tap",{
            self.swapStash()
        })
        self.addWidget(self.stashButton!)
        
        // Add stash piece label
        self.stashPieceLabel = self.createUILabel("Stash")
        self.stashPieceLabel!.position = CGPoint(x: 150, y: self.frame.height - 40)
        self.stashPieceLabel!.horizontalAlignmentMode = .Center
        self.guiLayer.addChild(self.stashPieceLabel!)
        
        // Add stash piece sprite, if any
        self.updateStashPieceSprite()
        
        // Add bank label
        self.bankPointsLabel = self.createUILabel("Bank Points")
        self.bankPointsLabel!.position = CGPoint(x: self.frame.width - 100, y: self.frame.height - 120)
        self.bankPointsLabel!.ignoreTouches = true
        self.guiLayer.addChild(self.bankPointsLabel!)
        
        // Add bank display
        self.bankPointsDisplay = self.createUILabel(self.scoreFormatter.stringFromNumber(self.bankPoints)!)
        self.bankPointsDisplay!.position = CGPoint(x: self.frame.width - 100, y: self.frame.height - 144)
        self.bankPointsDisplay!.fontSize = 18 * self.uiTextScale
        self.guiLayer.addChild(self.bankPointsDisplay!)
    
        // Add bank button
        self.bankButton = BankButtonWidget()
        self.bankButton!.size = CGSizeMake(bankButtonWidth, 72)
        self.bankButton!.position = CGPointMake(self.frame.width - 100, self.frame.height-90)
        self.bankButton!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.bankButton!.focusBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        self.bankButton!.caption = ""
        self.bankButton!.bind("tap",{
            self.scene!.view?.presentScene(SceneHelper.instance.bankScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 0.4))
        })
        self.addWidget(self.bankButton!)
        
        // Add menu button
        self.menuButton = SNZTextureButtonWidget(parentNode: guiLayer)
        self.menuButton!.texture = SKTexture(imageNamed: "menu51")
        self.menuButton!.anchorPoint = CGPointMake(0,0)
        self.menuButton!.textureScale = 0.8
        self.menuButton!.bind("tap",{
            self.scene!.view?.presentScene(SceneHelper.instance.levelScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 0.4))
        })
        self.addWidget(self.menuButton!)
        
        // Add undo button
        self.undoButton = SNZTextureButtonWidget(parentNode: guiLayer)
        self.undoButton!.texture = SKTexture(imageNamed: "curve4")
        self.undoButton!.anchorPoint = CGPointMake(1,0)
        self.undoButton!.bind("tap",{
            self.undoLastMove()
        })
        self.addWidget(self.undoButton!)
        
        // Add score label
        self.scoreLabel = self.createUILabel("Score")
        self.scoreLabel!.position = CGPoint(x: 20, y: self.frame.height - 120)
        self.guiLayer.addChild(self.scoreLabel!)
        
        // Add score display
        self.scoreDisplay = self.createUILabel(self.scoreFormatter.stringFromNumber(self.score)!)
        self.scoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 144)
        self.scoreDisplay!.fontSize = 24 * self.uiTextScale
        self.guiLayer.addChild(self.scoreDisplay!)
        
        // Add stats button
        self.statsButton = SNZButtonWidget()
        self.statsButton!.size = CGSizeMake((self.stashButton!.position.x + self.stashButton!.size.width) - self.currentButton!.position.x, 62)
        self.statsButton!.position = CGPointMake(20, self.currentButton!.position.y - (self.currentButton!.size.height / 2) - 4 - (self.statsButton!.size.height / 2))
        self.statsButton!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.statsButton!.focusBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        self.statsButton!.caption = ""
        self.statsButton!.bind("tap",{
            self.scene!.view?.presentScene(SceneHelper.instance.statsScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: 0.4))
        })
        self.addWidget(self.statsButton!)
        
        self.highScoreButton = SNZButtonWidget()
        self.highScoreButton!.size = CGSizeMake(bankButtonWidth, 62)
        self.highScoreButton!.position = CGPointMake(self.bankButton!.position.x, self.statsButton!.position.y)
        self.highScoreButton!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.highScoreButton!.focusBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        self.highScoreButton!.caption = ""
        self.highScoreButton!.bind("tap",{
            self.scene!.view?.presentScene(SceneHelper.instance.statsScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: 0.4))
        })
        self.addWidget(self.highScoreButton!)
        
        // Add high score label
        self.highScoreLabel = self.createUILabel("High Score")
        self.highScoreLabel!.position = CGPoint(x: 20, y: self.frame.height - 170)
        self.highScoreLabel!.horizontalAlignmentMode = .Right
        self.guiLayer.addChild(self.highScoreLabel!)
        
        // Add high score display
        self.highScoreDisplay = self.createUILabel(self.scoreFormatter.stringFromNumber(GameStats.instance!.getIntForKey("highscore_"+String(LevelHelper.instance.mode.rawValue)))!)
        self.highScoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 194)
        self.highScoreDisplay!.fontSize = 24 * self.uiTextScale
        self.highScoreDisplay!.horizontalAlignmentMode = .Right
        self.guiLayer.addChild(self.highScoreDisplay!)
    
        // Current piece caption
        self.buildCurrentPieceCaption()
    
        // Init the Game Over overlay
        self.initGameOver()
        
        // Set initial positions
        self.updateGuiPositions()
        
        // Set initial visibility of undo button
        self.undoButton!.hidden = (GameState.instance!.lastPlacedPiece == nil);
        
        // Render the widgets
        self.renderWidgets()
    }
    
    func buildCurrentPieceCaption() {
        var isHidden = true
    
        if (self.currentPieceCaption != nil) {
            isHidden = self.currentPieceCaption!.hidden
            self.currentPieceCaption!.removeFromParent()
        }
        
        if (self.frame.width > self.frame.height) {
            self.currentPieceCaption = SKShapeNode(rect: CGRectMake(0, 0, self.statsButton!.size.width, self.statsButton!.size.width), cornerRadius: 4)
        } else {
            self.currentPieceCaption = SKShapeNode(rect: CGRectMake(0, 0, self.size.width - 40, 100), cornerRadius: 4)
        }
        self.currentPieceCaption!.fillColor = UIColor(red: 54/255, green: 93/255, blue: 126/255, alpha: 1.0)
        self.currentPieceCaption!.lineWidth = 0
        self.currentPieceCaption!.zPosition = 999
        self.guiLayer.addChild(self.currentPieceCaption!)
        
        self.updateCurrentPieceCaption(self.currentPieceCaptionText)
        
        self.currentPieceCaption!.hidden = isHidden
    }
    
    /**
        Updates the position of GUI elements. This gets called whem rotation changes.
    */
    func updateGuiPositions() {

        if (self.currentPieceLabel != nil) {
        
            // Calculate size of upper UI
            let upperUsableArea = (self.frame.height < self.frame.width ? self.frame.height : self.frame.width) - SNZSpriteKitUITheme.instance.uiOuterMargins.horizontal
            
            // Calculate upper button widths
            var bankButtonWidth = (upperUsableArea / 2) - (SNZSpriteKitUITheme.instance.uiInnerMargins.horizontal / 3)
            var currentButtonWidth = (upperUsableArea / 4) - (SNZSpriteKitUITheme.instance.uiInnerMargins.horizontal / 3)
            var stashButtonWidth = currentButtonWidth
            
            bankButtonWidth = bankButtonWidth > 200 ? 200 : bankButtonWidth
            currentButtonWidth = currentButtonWidth > 100 ? 100 : currentButtonWidth
            stashButtonWidth = stashButtonWidth > 100 ? 100 : stashButtonWidth

            // Current Piece
            self.currentButton!.position = CGPoint(x: SNZSpriteKitUITheme.instance.uiOuterMargins.left, y: self.frame.height - 90)
            self.currentButton!.size = CGSizeMake(currentButtonWidth, 72)
            
            self.currentPieceLabel!.position = CGPoint(x: self.currentButton!.position.x + (currentButtonWidth / 2), y: self.frame.height - 40)
            self.currentPieceHome = CGPoint(x: self.currentButton!.position.x + (currentButtonWidth / 2), y: self.frame.height - 70)
            
            if (GameState.instance!.currentPiece != nil && GameState.instance!.currentPiece!.sprite != nil) {
                GameState.instance!.currentPiece!.sprite!.position = self.currentPieceHome
            }
            
            // Current Piece Caption
            self.buildCurrentPieceCaption()
            if (self.frame.width > self.frame.height) {
                self.currentPieceCaption!.position = CGPoint(x: 20, y: (self.frame.height - 145) - (self.currentPieceCaption!.frame.height / 2))
            } else {
                self.currentPieceCaption!.position = CGPoint(x: 20, y: (self.frame.height - 145) - (self.currentPieceCaption!.frame.height / 2))
            }
            
            // Stash Piece
            self.stashButton!.position = CGPoint(x: currentButton!.position.x + (SNZSpriteKitUITheme.instance.uiInnerMargins.left) + currentButtonWidth, y: self.frame.height - 90)
            self.stashButton!.size = CGSizeMake(stashButtonWidth, 72)
            
            self.stashPieceLabel!.position = CGPoint(x: self.stashButton!.position.x + (stashButtonWidth/2), y: self.frame.height - 40)
            
            self.stashPieceHome = CGPoint(x: self.stashButton!.position.x + (stashButtonWidth/2), y: self.frame.height - 70)
            
            if (GameState.instance!.stashPiece != nil && GameState.instance!.stashPiece!.sprite != nil) {
                GameState.instance!.stashPiece!.sprite!.position = self.stashPieceHome
            }

            // Bank Button
            self.bankButton!.position = CGPointMake(self.frame.width - bankButtonWidth - SNZSpriteKitUITheme.instance.uiOuterMargins.right, self.frame.height-90)
            self.bankButton!.size = CGSizeMake(bankButtonWidth, 72)
            
            // bank points
            self.bankPointsLabel!.position = CGPoint(x: self.bankButton!.position.x + SNZSpriteKitUITheme.instance.uiInnerMargins.left, y: self.frame.height - 40)
            self.bankPointsDisplay!.position = CGPoint(x: self.bankButton!.position.x + SNZSpriteKitUITheme.instance.uiInnerMargins.left, y: self.frame.height - 64)
            
            
            
            // Score
            self.scoreLabel!.position = CGPoint(x: 30, y: self.frame.height - 120)
            self.scoreDisplay!.position = CGPoint(x: 30, y: self.frame.height - 145)
            
            self.highScoreLabel!.position = CGPoint(x: self.frame.width - 30, y: self.frame.height - 120)
            self.highScoreDisplay!.position = CGPoint(x: self.frame.width - 30, y: self.frame.height - 145)
            
            // Stats button
            self.statsButton!.position = CGPointMake(20, self.currentButton!.position.y - (self.currentButton!.size.height / 2) - 4 - (self.statsButton!.size.height / 2))
            
            // High Score button
            self.highScoreButton!.position = CGPointMake(self.bankButton!.position.x, self.statsButton!.position.y)
            
            // Gameboard
            self.updateGameboardLayerPosition()
            
            // Widgets
            self.updateWidgets()
        }
    }
    
    /**
        Scales and positions the gameboard to fit the current screen size and orientation.
    */
    func updateGameboardLayerPosition() {
        if (HexMapHelper.instance.hexMap != nil) {
            var scale: CGFloat = 1.0
            var shiftY: CGFloat = 0
            
            let marginPortrait: CGFloat = 90
            let marginLandscape: CGFloat = 60
            
            let gameboardWidth = HexMapHelper.instance.getRenderedWidth()
            let gameboardHeight = HexMapHelper.instance.getRenderedHeight()
            
            // Calculate scaling factor to make gameboard fit screen
            if (self.frame.width > self.frame.height) { // landscape
                scale = self.frame.height / (gameboardHeight + marginLandscape)
            } else { // portrait
                scale = self.frame.width / (gameboardWidth + marginPortrait)
                
                shiftY = 30 // shift down a little bit if we are in portrait, so that we don't overlap UI elements.
            }
            
            // Scale gameboard layer
            self.gameboardLayer.setScale(scale)
            
            // Reposition gameboard layer to center in view
            self.gameboardLayer.position = CGPointMake(((self.frame.width) - (gameboardWidth * scale))/2, (((self.frame.height) - (gameboardHeight * scale))/2) - shiftY)
        }
    }
    
    /**
        Helper function to create an instance of SKLabelNode with typical defaults for our GUI and a specified caption.
        
        - Parameters:
            - caption: The caption for the label node
            
        - Returns: An instance of SKLabelNode, initialized with caption and gui defaults.
    */
    func createUILabel(caption: String) -> SKLabelNode {
        let label = SKLabelNode(text: caption)
        label.fontColor = UIColor(red: 0xf7/255, green: 0xef/255, blue: 0xed/255, alpha: 1.0)
        label.fontSize = 18 * self.uiTextScale
        label.zPosition = 20
        label.fontName = "Avenir-Black"
        label.ignoreTouches = true
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

        print(self.frame.width)

        return label
    }
    
    /**
        Remove sprites which are not a static part of the gui - the current piece and the stash piece.
    */
    func removeTransientGuiSprites() {
        if (GameState.instance!.stashPiece != nil) {
            if (GameState.instance!.stashPiece!.sprite != nil) {
                GameState.instance!.stashPiece!.sprite!.removeFromParent()
            }
        }
        
        if (GameState.instance!.currentPiece != nil) {
            if (GameState.instance!.currentPiece!.sprite != nil) {
                GameState.instance!.currentPiece!.sprite!.removeFromParent()
            }
        }
    }
    
    /**
        Helper method to call all of the various gui update methods.
    */
    func updateGuiLayer() {
        self.updateStashPieceSprite()
        self.updateScore()
        self.updateHighScore()
        self.updateCurrentPieceSprite()
        self.updateGuiPositions()
    }
    
    /**
        Refresh the current stash piece sprite. We call createSprite method of the stash piece to get the new sprite, 
        so that we also get any associated animations, etc.
    */
    func updateStashPieceSprite() {
        if (GameState.instance!.stashPiece != nil) {
            if (GameState.instance!.stashPiece!.sprite == nil) {
                GameState.instance!.stashPiece!.sprite = GameState.instance!.stashPiece!.createSprite()
                GameState.instance!.stashPiece!.sprite!.position = self.stashPieceHome
                self.guiLayer.addChild(GameState.instance!.stashPiece!.sprite!)
            } else {
                GameState.instance!.stashPiece!.sprite!.removeFromParent()
                GameState.instance!.stashPiece!.sprite = GameState.instance!.stashPiece!.createSprite()
                GameState.instance!.stashPiece!.sprite!.position = self.stashPieceHome
                self.guiLayer.addChild(GameState.instance!.stashPiece!.sprite!)
            }
        }
    }
    
    /**
        Refreshes the text of the score display with a formatted copy of the current self.score value
    */
    func updateScore() {
        if (self.scoreDisplay != nil) {
            self.scoreDisplay!.text = self.scoreFormatter.stringFromNumber(self.score)
        }
    }
    
    /**
        Refreshes the bank point display with a formatted copy of the current self.bankPoints value.
    */
    func updateBankPoints() {
        if (self.bankPointsDisplay != nil) {
            self.bankPointsDisplay!.text = self.scoreFormatter.stringFromNumber(self.bankPoints)
        }
    }
    
    /**
        Refreshes the text of the high score display with a formatted copy of the current high score value
    */
    func updateHighScore() {
        if (self.highScoreDisplay != nil) {
            self.highScoreDisplay!.text = self.scoreFormatter.stringFromNumber(GameStats.instance!.getIntForKey("highscore_"+String(LevelHelper.instance.mode.rawValue)))
        }
    }
    
    /**
        Scrolls a number upward with a fade-out animation, starting from a given point.
    */
    func scrollPoints(points: Int, position: CGPoint) {
        if (points > 0) {
            let scrollUp = SKAction.moveByX(0, y: 100, duration: 1.0)
            let fadeOut = SKAction.fadeAlphaTo(0, duration: 1.0)
            let remove = SKAction.removeFromParent()
            
            let scrollFade = SKAction.sequence([SKAction.group([scrollUp, fadeOut]),remove])
            
            let pointString:String = self.scoreFormatter.stringFromNumber(points)!
            
            let label = SKLabelNode(text: pointString)
            label.fontColor = UIColor.whiteColor()
            label.fontSize = CGFloat(18 + pointString.characters.count)  * self.uiTextScale
            label.zPosition = 30
            label.position = position
            label.fontName = "Avenir-Black"
            self.gameboardLayer.addChild(label)
            
            label.runAction(scrollFade)
        }
    }
    
    /**
        Calculates and applies a multiplier to the fontSize of an SKLabelNode to make it fit in a given rectangle.
    */
    func scaleToFitRect(node:SKLabelNode, rect:CGRect) {
        node.fontSize *= min(rect.width / node.frame.width, rect.height / node.frame.height)
    }
    
    /**
        Displays a message with a scale up, pause, and fade out effect, centered on the screen.
        
        - Parameters:
            - message: The message to be displayed. Newline (\n) characters in the message will be used as delimiters for the creation of separate SKLabelNodes, effectively allowing for the display of multi-line messages.
            - action: If provided, an SKAction which should be called once the fade-out animation completes.
    */
    func burstMessage(message: String, action: SKAction? = nil) {
        let tokens = message.componentsSeparatedByString("\n").reverse()
        
        var totalHeight:CGFloat = 0
        let padding:CGFloat = 20
        
        var labels: [SKLabelNode] = Array()
        
        for token in tokens {
            let label = SKLabelNode(text: token)
            label.fontColor = UIColor.whiteColor()
            label.zPosition = 500
            label.fontName = "Avenir-Black"
            label.fontSize = 20
            
            self.scaleToFitRect(label, rect: CGRectInset(self.frame, 30, 30))
            
            totalHeight += label.frame.height + padding
            
            label.position = CGPointMake(self.frame.width / 2, (self.frame.height / 2))
            
            labels.append(label)
        }
        
        // Create the burst animation sequence
        var burstSequence: [SKAction] = [
            SKAction.scaleTo(1.2, duration: 0.4),
            SKAction.scaleTo(0.8, duration: 0.2),
            SKAction.scaleTo(1.0, duration: 0.2),
            SKAction.waitForDuration(1.5),
            SKAction.group([
                SKAction.scaleTo(5.0, duration: 1.0),
                SKAction.fadeOutWithDuration(1.0)
            ])
        ]
        
        // Append the action parameter, if provided
        if (action != nil) {
            burstSequence.append(action!)
        }
        
        let burstAnimation = SKAction.sequence(burstSequence)
        
        burstAnimation
        
        var verticalOffset:CGFloat = 0
        
        for label in labels {
            label.position.y = (self.frame.height / 2) - (totalHeight / 2) + (label.frame.height / 2) + verticalOffset
        
            verticalOffset += padding + label.frame.height
        
            label.setScale(0)
            SceneHelper.instance.gameScene.addChild(label)
            label.runAction(burstAnimation)
        }
    }

    func initGameOver() {
        let label = SKLabelNode(text: "GAME OVER")
        label.fontColor = UIColor.whiteColor()
        label.fontSize = 64 * self.uiTextScale
        label.zPosition = 20
        label.fontName = "Avenir-Black"
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        label.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        self.gameOverLabel = label;
    }
    
    func showGameOver() {
        // Play game over sound
        self.runAction(SoundHelper.instance.gameover)
    
        // Disable Undo
        self.undoButton!.hidden = true
        self.undoState = nil
    
        // Show game over message and display Game Over label afterward
        self.burstMessage("NO MOVES REMAINING", action: SKAction.runBlock({
            self.guiLayer.addChild(self.gameOverLabel!)
        }))
        
    }
    
    
    func hideGameOver() {
        self.gameOverLabel!.removeFromParent()
    }
    
    /**
        Generates a point value and applies it to self.score, based on the piece specified.
        
        - Parameters:
            - hexPiece: The piece for which points are being awarded.
    */
    func awardPointsForPiece(hexPiece: HexPiece) {
        var modifier = self.mergingPieces.count-1
        
        if (modifier < 1) {
            modifier = 1
        }
        
        self.awardPoints(hexPiece.getPointValue() * modifier)
    }
    
    func awardPoints(points: Int) {
        self.lastPointsAwarded = points
        self.score += lastPointsAwarded
        
        // Bank 5%
        self.bankPoints += Int(Double(points) * 0.05)
        
        self.checkForUnlocks()
    }
    
    func checkForUnlocks() {
        if ((LevelHelper.instance.mode == .Hexagon || LevelHelper.instance.mode == .Welcome) && !GameState.instance!.unlockedLevels.contains(.Pit) && self.score >= 500000) {
            GameState.instance!.unlockedLevels.append(.Pit)
            
            self.burstMessage("New Map Unlocked\nTHE PIT")
        }
        
        if (LevelHelper.instance.mode == .Pit && !GameState.instance!.unlockedLevels.contains(.Moat) && self.score >= 1000000) {
            GameState.instance!.unlockedLevels.append(.Moat)
            
            self.burstMessage("New Map Unlocked\nTHE MOAT")
        }
    }
    
    /**
        Gets the next piece from the level helper and assigns it to GameState.instance!.currentPiece. This is the piece which will be placed if the player
        touches a valid cell on the gameboard.
    */
    func generateCurrentPiece() {
        GameState.instance!.currentPiece = LevelHelper.instance.popPiece()
    }
    
    func setCurrentPiece(hexPiece: HexPiece) {
        if (GameState.instance!.currentPiece!.sprite != nil) {
            GameState.instance!.currentPiece!.sprite!.removeFromParent()
        }
        
        GameState.instance!.currentPiece = hexPiece
        self.updateCurrentPieceSprite()
    }
    
    func spendBankPoints(points: Int) {
        self.bankPoints -= points
    }
    
    func updateCurrentPieceSprite(relocate: Bool = true) {
        var position: CGPoint?
    
        if (GameState.instance!.currentPiece != nil) {
            if (!relocate) {
                position = self.currentPieceSprite!.position
            }
            
            // Sprite to go in the GUI
            if (GameState.instance!.currentPiece!.sprite != nil) {
                GameState.instance!.currentPiece!.sprite!.removeFromParent()
            }
            
            // Generate sprite
            GameState.instance!.currentPiece!.sprite = GameState.instance!.currentPiece!.createSprite()
            
            // Ignore touches
            GameState.instance!.currentPiece!.sprite!.ignoreTouches = true
            
            GameState.instance!.currentPiece!.sprite!.position = self.currentPieceHome
            GameState.instance!.currentPiece!.sprite!.zPosition = 10
            guiLayer.addChild(GameState.instance!.currentPiece!.sprite!)
        
            // Sprite to go on the game board
            if (self.currentPieceSprite != nil) {
                self.currentPieceSprite!.removeFromParent()
            }
            
            // Create sprite
            self.currentPieceSprite = GameState.instance!.currentPiece!.createSprite()
            
            // Ignore touches
            self.currentPieceSprite!.ignoreTouches = true
            
            // fix z position
            self.currentPieceSprite!.zPosition = 999
            
            // Pulsate
            self.currentPieceSprite!.runAction(SKAction.repeatActionForever(SKAction.sequence([
                SKAction.scaleTo(1.4, duration: 0.4),
                SKAction.scaleTo(0.8, duration: 0.4)
            ])))
            
            if (relocate || position == nil) {
                var targetCell: HexCell?
                
                // Either use last placed piece, or center of game board, for target position
                if (GameState.instance!.lastPlacedPiece != nil && GameState.instance!.lastPlacedPiece!.hexCell != nil) {
                    targetCell = GameState.instance!.lastPlacedPiece!.hexCell!
                } else {
                    targetCell = HexMapHelper.instance.hexMap!.cell(Int(HexMapHelper.instance.hexMap!.width/2), Int(HexMapHelper.instance.hexMap!.height/2))!
                }
                
                // Get a random open cell near the target position
                let boardCell = HexMapHelper.instance.hexMap!.getRandomCellNear(targetCell!)
            
                // Get cell position
                if (boardCell != nil) {
                    position = HexMapHelper.instance.hexMapToScreen(boardCell!.position)
                }
            }

            // Position sprite
            if (position != nil) { // position will be nil if board is full
                self.currentPieceSprite!.position = position!
                self.gameboardLayer.addChild(self.currentPieceSprite!)
            }
            
            // Update caption, if any
            if (self.currentPieceCaption != nil) {
                if (GameState.instance!.currentPiece!.caption != "") {
                    self.currentPieceCaption!.hidden = false
                    self.updateCurrentPieceCaption(GameState.instance!.currentPiece!.caption)
                } else {
                    self.currentPieceCaption!.hidden = true
                    self.currentPieceCaptionText = ""
                }
            }
        }
    }
    
    func updateCurrentPieceCaption(caption: String) {
        self.currentPieceCaptionText = caption
    
        self.currentPieceCaption!.removeAllChildren()
        
        let tokens = caption.componentsSeparatedByString(" ")
        var idx = 0
        var token = ""
        var label = self.createUILabel("")
        var priorText = ""
        var verticalOffset:CGFloat = self.currentPieceCaption!.frame.height / 2
        let horizontalOffset:CGFloat = self.currentPieceCaption!.frame.width / 2
        
        var lineHeight:CGFloat = 0
        var totalHeight:CGFloat = 0
        
        while (idx < tokens.count) {
            token = tokens[idx]
            
            priorText = label.text!
            label.text = label.text!+" "+token
            
            if (label.frame.width > (self.currentPieceCaption!.frame.width) - 20) {
                label.text = priorText
                label.horizontalAlignmentMode = .Center
                label.position = CGPointMake(horizontalOffset,verticalOffset)
                self.currentPieceCaption!.addChild(label)
                verticalOffset -= 20
                
                totalHeight += label.frame.height
                
                label = self.createUILabel("")
            } else {
                idx++
            }
            
            if (lineHeight == 0) {
                lineHeight = label.frame.height
            }
        }
        
        if (label.text != "") {
            label.horizontalAlignmentMode = .Center
            label.position = CGPointMake(horizontalOffset,verticalOffset)
            self.currentPieceCaption!.addChild(label)
            
            totalHeight += label.frame.height
        }
        
        // Vertically center the entire block
        for label in self.currentPieceCaption!.children {
            label.position.y += (totalHeight / 2) - (lineHeight / 2)
        }
        
    }
    
    /**
        Swaps GameState.instance!.currentPiece with the piece currently in the stash, if any. If no piece is in the stash, a new currentPiece is geneated and the old currentPiece is placed in the stash.
    */
    func swapStash() {
        // Clear any caption when piece is going to be swapped in to stash
        GameState.instance!.currentPiece!.caption = ""
        
        // Handle the swap
        if (GameState.instance!.stashPiece != nil) {
            let tempPiece = GameState.instance!.currentPiece!
            
            GameState.instance!.currentPiece = GameState.instance!.stashPiece
            GameState.instance!.stashPiece = tempPiece
            
            GameState.instance!.currentPiece!.sprite!.runAction(SKAction.moveTo(self.currentPieceHome, duration: 0.1))
            GameState.instance!.stashPiece!.sprite!.runAction(SKAction.sequence([SKAction.moveTo(self.stashPieceHome, duration: 0.1),SKAction.runBlock({
                self.updateCurrentPieceSprite(false)
            })]))
        } else {
            GameState.instance!.stashPiece = GameState.instance!.currentPiece
            GameState.instance!.stashPiece!.sprite!.runAction(SKAction.sequence([SKAction.moveTo(self.stashPieceHome, duration: 0.1),SKAction.runBlock({
                self.generateCurrentPiece()
                self.updateCurrentPieceSprite(false)
            })]))
            self.generateCurrentPiece()
        }
    }
}
