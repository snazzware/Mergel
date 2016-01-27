//
//  GameScene.swift
//  HexMatch
//
//  Created by Josh McKee on 1/11/16.
//  Copyright (c) 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import CoreData

class GameScene: SKScene {
    var gameboardLayer = SKNode()
    var guiLayer = SKNode()
    
    var currentPieceLabel: SKLabelNode?
    var currentPiece: HexPiece?
    var currentPieceHome = CGPointMake(0,0)
    var currentPieceSprite: SKSpriteNode?
    
    var stashPieceLabel: SKLabelNode?
    var stashPiece: HexPiece?
    var stashPieceHome = CGPointMake(0,0)
    var stashBox: SKShapeNode?
    
    var resetButton: SKLabelNode?
    var undoButton: SKLabelNode?
    var gameOverLabel: SKLabelNode?
    
    var mergingPieces: [HexPiece] = Array()
    var mergedPieces: [HexPiece] = Array()

    var lastPlacedPiece: HexPiece?
    var lastPointsAwarded = 0
    
    var hexMap: HexMap?
    
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
            
            if (self._score > GameState.instance!.highScore) {
                GameState.instance!.highScore = self._score
                self.updateHighScore()
            }
        }
    }
    var scoreDisplay: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    var highScoreDisplay: SKLabelNode?
    var highScoreLabel: SKLabelNode?
    
    override func didMoveToView(view: SKView) {        
        // Init state machine
        GameStateMachine.instance = GameStateMachine(scene: self)
        GameStateMachine.instance!.enterState(GameSceneInitialState.self)
    }
    
    func initGame() {
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Add guiLayer to scene
        addChild(self.guiLayer)
        
        // Init HexMap
        self.hexMap = HexMap(7,7)
        
        // Init level
        LevelHelper.instance.initLevel(self.hexMap!)
        HexMapHelper.instance.hexMap = self.hexMap!
        
        // Render our hex map to the gameboardLayer
        HexMapHelper.instance.renderHexMap(gameboardLayer);
        
        // Init current piece
        self.generateCurrentPiece()
        
        // Add gameboardLayer to scene
        addChild(self.gameboardLayer)
        
        // Init guiLayer
        self.initGuiLayer()
    }
    
    /**
        Reset game state. This includes clearing current score, stashed piece, current piece, and regenerating hexmap with a new random starting layout.
    */
    func resetLevel() {
        // Clear the board
        HexMapHelper.instance.clearHexMap(self.gameboardLayer)
        
        // Clear the hexmap
        self.hexMap?.clear()
        
        // Generate level
        LevelHelper.instance.initLevel(self.hexMap!)
        
        // Generate new current piece
        self.currentPiece!.sprite!.removeFromParent()
        self.generateCurrentPiece()
        
        // Clear stash
        if (self.stashPiece != nil) {
            self.stashPiece!.sprite!.removeFromParent()
            self.stashPiece = nil
        }
        
        // Render game board
        HexMapHelper.instance.renderHexMap(gameboardLayer);
        
        // Reset score
        self.score = 0
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first?.locationInNode(self)
        
        if (location != nil) {
            let nodes = nodesAtPoint(location!)
         
            for node in nodes {
                if (node.name == "hexMapCell") {
                    let x = node.userData!.valueForKey("hexMapPositionX") as! Int
                    let y = node.userData!.valueForKey("hexMapPositionY") as! Int
                    
                    let cell = HexMapHelper.instance.hexMap!.cell(x,y)
                    
                    self.updateMergingPieces(cell!)
                    
                    // Move to touched point
                    currentPiece!.sprite!.removeActionForKey("moveAnimation")
                    currentPiece!.sprite!.position = self.convertPoint(self.convertPoint(node.position, fromNode: self.gameboardLayer), toNode: self.guiLayer)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first?.locationInNode(self)
        
        if (location != nil) {
            
            if (GameStateMachine.instance!.currentState is GameSceneGameOverState) {
                GameStateMachine.instance!.enterState(GameSceneRestartState.self)
            } else {
                let nodes = nodesAtPoint(location!)
             
                var handled = false
             
                for node in nodes {
                    print(node)
                    if (!handled) {
                        if (node == self.stashBox) {
                            self.swapStash()
                            
                            handled = true
                        } else
                        if (node == self.resetButton) {
                            print("reset button pressed")
                            GameStateMachine.instance!.enterState(GameSceneRestartState.self)

                            handled = true
                        } else
                        if (node == self.undoButton) {
                            self.undoLastMove()

                            handled = true
                        } else
                        if (node.name == "hexMapCell") {
                            let x = node.userData!.valueForKey("hexMapPositionX") as! Int
                            let y = node.userData!.valueForKey("hexMapPositionY") as! Int
                            
                            let cell = HexMapHelper.instance.hexMap!.cell(x,y)
                            
                            // Refresh merging pieces
                            self.updateMergingPieces(cell!)
                            
                            // Will the target cell accept our current piece, and will the piece either allow placement
                            // without a merge, or do we have a merge?
                            if (cell!.willAccept(self.currentPiece!) && (self.currentPiece!.canPlaceWithoutMerge() || self.mergingPieces.count>0)) {
                                // Store last placed piece, prior to any merging
                                self.lastPlacedPiece = self.currentPiece
                            
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
                                    
                                    // Assign current piece to the next value in sequence, or cap at maxPieceValue
                                    if (maxValue < HexMapHelper.instance.maxPieceValue) {
                                        self.currentPiece!.value = maxValue + 1
                                    } else {
                                        self.currentPiece!.value = maxValue
                                    }
                                    
                                    // Initialize new sprite for updated currentPiece value
                                    self.currentPiece!.wasPlacedWithMerge()                                
                                    
                                    // Store merged pieces, if any
                                    self.mergedPieces = self.mergingPieces
                                    
                                    // Remove merged pieces from board
                                    for hexPiece in self.mergingPieces {
                                        hexPiece.sprite!.removeFromParent()
                                        hexPiece.hexCell?.hexPiece = nil
                                    }
                                    
                                } else {
                                    // clear merged array, since we are not merging any on this placement
                                    self.mergedPieces.removeAll()
                                    
                                    // let piece know we are placing it
                                    self.currentPiece!.wasPlacedWithoutMerge()
                                }
                                
                                // Place the piece
                                cell!.hexPiece = self.currentPiece
                                currentPiece!.sprite!.removeActionForKey("moveAnimation")
                                
                                // Move sprite from GUI to gameboard layer
                                self.currentPiece!.sprite!.moveToParent(self.gameboardLayer)
                                
                                // Position on gameboard
                                self.currentPiece!.sprite!.position = node.position
                                
                                // Show undo button
                                self.undoButton!.hidden = false
                                
                                // Award points
                                self.awardPoints(self.currentPiece!)
                                self.scrollPoints(self.lastPointsAwarded, position: node.position)
                                
                                // Generate new piece
                                self.generateCurrentPiece()
                                
                                // End turn
                                self.turnDidEnd()
                            } else {
                                // Return to home
                                currentPiece!.sprite!.removeActionForKey("moveAnimation")
                                currentPiece!.sprite!.runAction(SKAction.moveTo(self.currentPieceHome, duration: 0.2), withKey: "moveAnimation")
                            }
                            
                            handled = true
                        }
                    }
                }
            }
        }
    }
    
    
    func turnDidEnd() {
        // Test for game over
        if (HexMapHelper.instance.hexMap!.getOpenCells().count==0) {
            GameStateMachine.instance!.enterState(GameSceneGameOverState.self)
        } else {
            let occupiedCells = HexMapHelper.instance.hexMap!.getOccupiedCells()
            
            // Give each piece a turn
            for occupiedCell in occupiedCells {
                occupiedCell.hexPiece?.takeTurn()
            }
        }
    }
    
    /**
        Rolls back the last move made. Places removed merged pieces back on the board, removes points awarded, and calls self.restoreLastPiece, which puts the last piece played back in the currentPiece property.
    */
    func undoLastMove() {
        if (self.lastPlacedPiece != nil) {
            // Clear out cell where the last piece was placed
            let cell = HexMapHelper.instance.hexMap!.cell(lastPlacedPiece!.lastX,lastPlacedPiece!.lastY)
            cell!.hexPiece = nil
            
            // Remove sprite from gameboard
            self.lastPlacedPiece!.sprite!.removeFromParent()
        
            // Restore last piece in to the current piece
            self.restoreLastPiece()
            
            // Restore piece merged
            for mergedPiece in self.mergedPieces {
                self.gameboardLayer.addChild(mergedPiece.sprite!)
                
                let cell = HexMapHelper.instance.hexMap!.cell(mergedPiece.lastX,mergedPiece.lastY)
                
                cell!.hexPiece = mergedPiece
            }
            
            // Clear merged pieces, since they have been restored
            self.mergedPieces.removeAll()
            
            // Reset lastPlacedPiece, disabling undo
            self.lastPlacedPiece = nil
            
            // Take back points
            self.score -= self.lastPointsAwarded
            
            // Hide undo button
            self.undoButton!.hidden = true
        }
    }
    
    /**
        Handles touch move events. Updates animations for any pieces which would be merged if the player were to end the touch event in the cell being touched, if any.
    */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first?.locationInNode(self)
        
        var touchInCell = false
        
        if (location != nil) {
            let nodes = nodesAtPoint(location!)
         
            for node in nodes {
                if (node.name == "hexMapCell") {
                    touchInCell = true
                    
                    let x = node.userData!.valueForKey("hexMapPositionX") as! Int
                    let y = node.userData!.valueForKey("hexMapPositionY") as! Int
                    
                    let cell = HexMapHelper.instance.hexMap!.cell(x,y)
                    
                    self.updateMergingPieces(cell!)
                    
                    // Move to touched point
                    currentPiece!.sprite!.removeActionForKey("moveAnimation")
                    currentPiece!.sprite!.position = self.convertPoint(self.convertPoint(node.position, fromNode: self.gameboardLayer), toNode: self.guiLayer)
                }
            }
        }
        
        if (!touchInCell) {
            // Return to home
            currentPiece!.sprite!.removeActionForKey("moveAnimation")
            currentPiece!.sprite!.runAction(SKAction.moveTo(self.currentPieceHome, duration: 0.2), withKey: "moveAnimation")
        }
    }
   
    /**
        Stops merge animation on any current set of would-be merged pieces, then updates self.mergingPieces with any merges which would occur if self.curentPiece were to be placed in cell. Stats merge animation on the new set of merging pieces, if any.
        
        - Parameters:
            - cell: The cell to test for merging w/ the current piece
    */
    func updateMergingPieces(cell: HexCell) {
        if (cell.willAccept(self.currentPiece!)) {
            // Stop animation on current merge set
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeActionForKey("mergeAnimation")
                hexPiece.sprite!.setScale(1.0)
            }
            
            self.mergingPieces = cell.getWouldMergeWith(self.currentPiece!)
            
            // Start animation on new merge set
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeActionForKey("mergeAnimation")
                hexPiece.sprite!.setScale(1.2)
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    /**
        Initializes GUI layer components, sets up labels, buttons, etc.
    */
    func initGuiLayer() {
        // set up score formatter
        self.scoreFormatter.numberStyle = .DecimalStyle
    
        // Calculate current piece home position
        self.currentPieceHome = CGPoint(x: 80, y: self.frame.height - 70)
        
        // Add current piece label
        self.currentPieceLabel = self.createUILabel("Current Piece")
        self.currentPieceLabel!.position = CGPoint(x: 20, y: self.frame.height - 40)
        self.guiLayer.addChild(self.currentPieceLabel!)
        
        // Calculate stash piece home position
        self.stashPieceHome = CGPoint(x: self.frame.width-80, y: self.frame.height - 70)
        
        // Add stash box
        self.stashBox = SKShapeNode(rect: CGRectMake(self.frame.width-160, self.frame.height-90, 140, 72))
        self.stashBox!.strokeColor = UIColor.blackColor()
        self.guiLayer.addChild(self.stashBox!)
        
        // Add stash piece label
        self.stashPieceLabel = self.createUILabel("Stash Piece")
        self.stashPieceLabel!.position = CGPoint(x: self.frame.width-150, y: self.frame.height - 40)
        self.guiLayer.addChild(self.stashPieceLabel!)
        
        // Add reset button
        self.resetButton = self.createUILabel("Start Over")
        self.resetButton!.position = CGPoint(x: self.frame.width-150, y: 40)
        self.guiLayer.addChild(self.resetButton!)
        
        // Add undo button
        self.undoButton = self.createUILabel("Undo")
        self.undoButton!.position = CGPoint(x: self.frame.width-150, y: 140)
        self.guiLayer.addChild(self.undoButton!)
        
        // Add score label
        self.scoreLabel = self.createUILabel("Score")
        self.scoreLabel!.position = CGPoint(x: 20, y: self.frame.height - 120)
        self.guiLayer.addChild(self.scoreLabel!)
        
        // Add score display
        self.scoreDisplay = self.createUILabel(self.scoreFormatter.stringFromNumber(self.score)!)
        self.scoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 144)
        self.scoreDisplay!.fontSize = 24
        self.guiLayer.addChild(self.scoreDisplay!)
        
        // Add high score label
        self.highScoreLabel = self.createUILabel("High Score")
        self.highScoreLabel!.position = CGPoint(x: 20, y: self.frame.height - 170)
        self.guiLayer.addChild(self.highScoreLabel!)
        
        // Add high score display
        self.highScoreDisplay = self.createUILabel(self.scoreFormatter.stringFromNumber(GameState.instance!.highScore)!)
        self.highScoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 194)
        self.highScoreDisplay!.fontSize = 24
        self.guiLayer.addChild(self.highScoreDisplay!)
    
        // Init the Game Over overlay
        self.initGameOver()
        
        // Set initial positions
        self.updateGuiPositions()
        
        // Set initial visibility of undo button
        self.undoButton!.hidden = (self.lastPlacedPiece == nil);
    }
    
    /**
        Updates the position of GUI elements. This gets called whem rotation changes.
    */
    func updateGuiPositions() {

        if (self.currentPieceLabel != nil) {
            // Current Piece
            self.currentPieceLabel!.position = CGPoint(x: 20, y: self.frame.height - 40)
            
            self.currentPieceHome = CGPoint(x: 80, y: self.frame.height - 70)
            
            if (self.currentPiece != nil && self.currentPiece!.sprite != nil) {
                self.currentPiece!.sprite!.position = self.currentPieceHome
            }
            
            // Stash
            self.stashBox!.removeFromParent()
            self.stashBox = SKShapeNode(rect: CGRectMake(self.frame.width-160, self.frame.height-90, 140, 72))
            self.stashBox!.strokeColor = UIColor.clearColor()
            self.guiLayer.addChild(self.stashBox!)
            
            self.stashPieceLabel!.position = CGPoint(x: self.frame.width-150, y: self.frame.height - 40)
            
            self.stashPieceHome = CGPoint(x: self.frame.width-80, y: self.frame.height - 70)
            if (self.stashPiece != nil && self.stashPiece!.sprite != nil) {
                self.stashPiece!.sprite!.position = self.stashPieceHome
            }
            
            // Score
            self.scoreLabel!.position = CGPoint(x: 20, y: self.frame.height - 120)
            self.scoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 144)
            
            if (self.frame.width > self.frame.height) { // landscape
                self.highScoreLabel!.position = CGPoint(x: 20, y: self.frame.height - 170)
                self.highScoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 194)
            } else {
                self.highScoreLabel!.position = CGPoint(x: self.frame.width-150, y: self.frame.height - 120)
                self.highScoreDisplay!.position = CGPoint(x: self.frame.width-150, y: self.frame.height - 144)
            }
            
            
            // Buttons
            self.resetButton!.position = CGPoint(x: 20, y: 40)
            
            self.undoButton!.position = CGPoint(x: self.frame.width-100, y: 40)
        }
        
        // Gameboard
        self.updateGameboardLayerPosition()
    }
    
    func updateGameboardLayerPosition() {
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
    
    /**
        Helper function to create an instance of SKLabelNode with typical defaults for our GUI and a specified caption.
        
        - Parameters:
            - caption: The caption for the label node
            
        - Returns: An instance of SKLabelNode, initialized with caption and gui defaults.
    */
    func createUILabel(caption: String) -> SKLabelNode {
        let label = SKLabelNode(text: caption)
        label.fontColor = UIColor(red: 0xf7/255, green: 0xef/255, blue: 0xed/255, alpha: 1.0)
        label.fontSize = 18
        label.zPosition = 20
        label.fontName = "Avenir-Black"
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left

        return label
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
        Refreshes the text of the high score display with a formatted copy of the current high score value
    */
    func updateHighScore() {
        if (self.highScoreDisplay != nil) {
            self.highScoreDisplay!.text = self.scoreFormatter.stringFromNumber(GameState.instance!.highScore)
        }
    }
    
    func scrollPoints(points: Int, position: CGPoint) {
        if (points > 0) {
            let scrollUp = SKAction.moveByX(0, y: 100, duration: 1.0)
            let fadeOut = SKAction.fadeAlphaTo(0, duration: 1.0)
            let remove = SKAction.removeFromParent()
            
            let scrollFade = SKAction.sequence([SKAction.group([scrollUp, fadeOut]),remove])
            
            let label = SKLabelNode(text: self.scoreFormatter.stringFromNumber(points))
            label.fontColor = UIColor.whiteColor()
            label.fontSize = 18
            label.zPosition = 30
            label.position = position
            label.fontName = "Avenir-Black"
            self.gameboardLayer.addChild(label)
            
            label.runAction(scrollFade)
        }
    }
    
    func initGameOver() {
        let label = SKLabelNode(text: "No Moves Remaining!")
        label.fontColor = UIColor.blackColor()
        label.fontSize = 64
        label.zPosition = 20
        label.fontName = "Avenir-Black"
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        
        label.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        self.gameOverLabel = label;
    }
    
    func showGameOver() {
        self.guiLayer.addChild(self.gameOverLabel!)
    }
    
    
    func hideGameOver() {
        self.gameOverLabel!.removeFromParent()
    }
    
    /**
        Generates a point value and applies it to self.score, based on the piece specified.
        
        - Parameters:
            - hexPiece: The piece for which points are being awarded.
    */
    func awardPoints(hexPiece: HexPiece) {
        var modifier = self.mergingPieces.count-1
        
        if (modifier < 1) {
            modifier = 1
        }
        
        self.lastPointsAwarded = hexPiece.getPointValue() * modifier
        self.score += lastPointsAwarded
    }
    
    /**
        Generates a random piece and assigns it to self.currentPiece. This is the piece which will be placed if the player
        touches a valid cell on the gameboard.
    */
    func generateCurrentPiece() {
    
        self.currentPiece = LevelHelper.instance.getRandomPiece()
        self.currentPiece!.sprite = self.currentPiece!.createSprite()
        
        self.currentPiece!.sprite!.position = self.currentPieceHome
        self.currentPiece!.sprite!.zPosition = 10
        guiLayer.addChild(self.currentPiece!.sprite!)
        
        // Sprite to go on the game board
        self.currentPieceSprite = self.currentPiece!.createSprite()
    }
    
    /**
        Restores self.currentPiece back to the previously placed piece.
    */
    func restoreLastPiece() {
        self.currentPiece!.sprite!.removeFromParent()
    
        self.currentPiece = self.lastPlacedPiece
        
        self.currentPiece!.sprite!.removeFromParent()
        
        self.currentPiece!.wasUnplaced()
        
        self.currentPiece!.sprite!.position = self.currentPieceHome
        self.currentPiece!.sprite!.zPosition = 10
        
        guiLayer.addChild(self.currentPiece!.sprite!)
    }
    
    /**
        Swaps self.currentPiece with the piece currently in the stash, if any. If no piece is in the stash, a new currentPiece is geneated and the old currentPiece is placed in the stash.
    */
    func swapStash() {
        if (self.stashPiece != nil) {
            let tempPiece = self.currentPiece!
            
            self.currentPiece = self.stashPiece
            self.stashPiece = tempPiece
            
            self.currentPiece!.sprite!.runAction(SKAction.moveTo(self.currentPieceHome, duration: 0.3))
            self.stashPiece!.sprite!.runAction(SKAction.moveTo(self.stashPieceHome, duration: 0.3))
        } else {
            self.stashPiece = currentPiece
            self.stashPiece!.sprite!.runAction(SKAction.moveTo(self.stashPieceHome, duration: 0.3))
            self.generateCurrentPiece()
        }
    }
}
