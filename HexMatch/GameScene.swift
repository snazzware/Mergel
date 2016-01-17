//
//  GameScene.swift
//  HexMatch
//
//  Created by Josh McKee on 1/11/16.
//  Copyright (c) 2016 Josh McKee. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameboardLayer = SKNode()
    var guiLayer = SKNode()
    
    var currentPiece: HexPiece?
    var currentPieceHome = CGPointMake(0,0)
    
    var stashPiece: HexPiece?
    var stashPieceHome = CGPointMake(0,0)
    var stashBox: SKShapeNode?
    
    var resetButton: SKLabelNode?
    
    var mergingPieces: [HexPiece] = Array()
    
    var hexMap: HexMap?
    
    var _score = 0
    var score: Int {
        get {
            return self._score
        }
        set {
            self._score = newValue
            self.updateScore()
        }
    }
    var scoreDisplay: SKLabelNode?

    override func didMoveToView(view: SKView) {
        // Init guiLayer
        self.initGuiLayer()
        
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
        
        // Center gameboardLayer
        let gameboardWidth = CGFloat(HexMapHelper.instance.cellNodeHorizontalAdvance*(HexMapHelper.instance.hexMap!.width-1))
        let gameboardHeight = CGFloat(HexMapHelper.instance.cellNodeVerticalAdvance*(HexMapHelper.instance.hexMap!.height-1))
        
        self.gameboardLayer.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.gameboardLayer.position.x -= gameboardWidth * 0.75
        self.gameboardLayer.position.y -= gameboardHeight * 0.75
        
        // Scale up gameboard
        self.gameboardLayer.setScale(1.5)
        
        // Add gameboardLayer to scene
        addChild(self.gameboardLayer)
        
        // Set scale mode
        self.scaleMode = .AspectFit
    }
    
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
                    currentPiece!.sprite!.removeAllActions()
                    currentPiece!.sprite!.position = self.convertPoint(self.convertPoint(node.position, fromNode: self.gameboardLayer), toNode: self.guiLayer)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let location = touches.first?.locationInNode(self)
        
        if (location != nil) {
            let nodes = nodesAtPoint(location!)
         
            var handled = false
         
            for node in nodes {
                if (!handled) {
                    if (node == self.stashBox) {
                        self.swapStash()
                        
                        handled = true
                    } else
                    if (node == self.resetButton) {
                        self.resetLevel()

                        handled = true
                    } else
                    if (node.name == "hexMapCell") {
                        let x = node.userData!.valueForKey("hexMapPositionX") as! Int
                        let y = node.userData!.valueForKey("hexMapPositionY") as! Int
                        
                        let cell = HexMapHelper.instance.hexMap!.cell(x,y)
                        
                        if (cell!.willAccept(self.currentPiece!)) {
                            // Are we merging pieces?
                            if (self.mergingPieces.count>0) {
                                var maxValue = 0
                                
                                // Remove animations from merging pieces, and find the maximum value
                                for hexPiece in self.mergingPieces {
                                    hexPiece.sprite!.removeAllActions()
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
                                self.currentPiece!.sprite?.removeFromParent()
                                self.currentPiece!.sprite = HexMapHelper.instance.createHexPieceSprite(self.currentPiece!)
                                self.currentPiece!.sprite!.position = node.position
                                self.currentPiece!.sprite!.zPosition = 2
                                guiLayer.addChild(self.currentPiece!.sprite!)
                                
                                // Remove merged pieces from board
                                for hexPiece in self.mergingPieces {
                                    hexPiece.sprite!.removeFromParent()
                                    hexPiece.hexCell?.hexPiece = nil
                                }
                            }
                            
                            // Place the piece
                            cell!.hexPiece = self.currentPiece
                            currentPiece!.sprite!.removeAllActions()
                            
                            // Move sprite from GUI to gameboard layer
                            self.currentPiece!.sprite!.moveToParent(self.gameboardLayer)
                            
                            // Position on gameboard
                            self.currentPiece!.sprite!.position = node.position
                            
                            // Award points
                            self.awardPoints(self.currentPiece!)
                            
                            // Generate new piece
                            self.generateCurrentPiece()
                        } else {
                            // Return to home
                            currentPiece!.sprite!.removeAllActions()
                            currentPiece!.sprite!.runAction(SKAction.moveTo(self.currentPieceHome, duration: 0.2))
                        }
                        
                        handled = true
                    }
                }
            }
        }
    }
    
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
                    currentPiece!.sprite!.removeAllActions()
                    currentPiece!.sprite!.position = self.convertPoint(self.convertPoint(node.position, fromNode: self.gameboardLayer), toNode: self.guiLayer)
                }
            }
        }
        
        if (!touchInCell) {
            // Return to home
            currentPiece!.sprite!.removeAllActions()
            currentPiece!.sprite!.runAction(SKAction.moveTo(self.currentPieceHome, duration: 0.2))
        }
    }
   
    func updateMergingPieces(cell: HexCell) {
        if (cell.willAccept(self.currentPiece!)) {
            // Stop animation on current merge set
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeAllActions()
                hexPiece.sprite!.setScale(1.0)
            }
            
            self.mergingPieces = cell.getWouldMergeWith(self.currentPiece!)
            
            // Start animation on new merge set
            for hexPiece in self.mergingPieces {
                hexPiece.sprite!.removeAllActions()
                hexPiece.sprite!.setScale(1.2)
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    func initGuiLayer() {
        // Calculate current piece home position
        self.currentPieceHome = CGPoint(x: 80, y: self.frame.height - 70)
        
        // Add current piece label
        let label = SKLabelNode(text: "Current Piece")
        label.fontColor = UIColor.blackColor()
        label.fontSize = 18
        label.zPosition = 20
        label.fontName = "Avenir-Black"
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label.position = CGPoint(x: 20, y: self.frame.height - 40)
        self.guiLayer.addChild(label)
        
        // Calculate stash piece home position
        self.stashPieceHome = CGPoint(x: self.frame.width-80, y: self.frame.height - 70)
        
        self.stashBox = SKShapeNode(rect: CGRectMake(self.frame.width-150, self.frame.height-90, 120, 72))
        self.stashBox!.strokeColor = UIColor.blackColor()
        self.guiLayer.addChild(self.stashBox!)
        
        // Add stash piece label
        let label2 = SKLabelNode(text: "Stashed Piece")
        label2.fontColor = UIColor.blackColor()
        label2.fontSize = 18
        label2.zPosition = 20
        label2.fontName = "Avenir-Black"
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        label2.position = CGPoint(x: self.frame.width-150, y: self.frame.height - 40)
        self.guiLayer.addChild(label2)
        
        // Add reset button
        self.resetButton = SKLabelNode(text: "Start Over")
        self.resetButton!.fontColor = UIColor.blackColor()
        self.resetButton!.fontSize = 18
        self.resetButton!.zPosition = 20
        self.resetButton!.fontName = "Avenir-Black"
        self.resetButton!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        self.resetButton!.position = CGPoint(x: self.frame.width-150, y: 40)
        self.guiLayer.addChild(self.resetButton!)
        
        // Add score label
        self.scoreDisplay = SKLabelNode(text: "0")
        self.scoreDisplay!.fontColor = UIColor.blackColor()
        self.scoreDisplay!.fontSize = 18
        self.scoreDisplay!.zPosition = 20
        self.scoreDisplay!.fontName = "Avenir-Black"
        self.scoreDisplay!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        self.scoreDisplay!.position = CGPoint(x: 20, y: self.frame.height - 120)
        self.guiLayer.addChild(self.scoreDisplay!)
    }
    
    func updateScore() {
        if (self.scoreDisplay != nil) {
            self.scoreDisplay!.text = "\(self.score)"
        }
    }
    
    func awardPoints(hexPiece: HexPiece) {
        self.score += Int(pow(Float(10), Float(hexPiece.value+1))) * self.mergingPieces.count
    }
    
    func generateCurrentPiece() {
        self.currentPiece = LevelHelper.instance.getRandomPiece()
        self.currentPiece!.sprite = HexMapHelper.instance.createHexPieceSprite(self.currentPiece!)
        
        self.currentPiece!.sprite!.position = self.currentPieceHome
        self.currentPiece!.sprite!.zPosition = 10
        guiLayer.addChild(self.currentPiece!.sprite!)
    }
    
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
