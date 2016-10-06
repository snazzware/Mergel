//
//  HexPiece.swift
//  HexMatch
//
//  Created by Josh McKee on 1/14/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import GameKit

class HexPiece : NSObject, NSCoding {
    
    // Controls whether or not the player can take the piece from the board
    var isCollectible = false
    
    // order in which piece was added to board
    var added = 0

    // HexCell that this piece is currently placed in, if any
    var _hexCell: HexCell?
    var hexCell: HexCell? {
        get {
            return self._hexCell
        }
        set {
            self._hexCell = newValue
            if (self._hexCell != nil) {
                if (self._hexCell != newValue) {
                    self._hexCell!.hexPiece = nil
                }
                
                HexMapHelper.instance.addedCounter += 1
                self.added = HexMapHelper.instance.addedCounter
            }
        }
    }
    
    // Sprite which represents this piece, if any
    var sprite: SKSpriteNode?
    
    // Caption which will be displayed when this piece is selected for placement
    var caption: String = ""
    
    // How many turns we have left to skip, and how many we should skip after being placed.
    var skipTurnCounter = 1
    var skipTurnsOnPlace = 1
    
    // Did we take a turn on the last pass?
    var didTakeTurn = false
    
    // Value tracking
    var originalValue = 0
    var _value = -1
    var value: Int {
        get {
            if (self._value == -1) {
                return 0;
            } else {
                return self._value
            }
        }
        set {
            if (self._value == -1) {
                self.originalValue = newValue
            }
            self._value = newValue
        }
    }
    
    override init() {
        super.init()
    }
    
    /**
        Decode for NSCoder
    */
    required init(coder decoder: NSCoder) {
        super.init()
    
        self.originalValue = decoder.decodeInteger(forKey: "originalValue")
        self.value = decoder.decodeInteger(forKey: "value")
        
        let hexCell = decoder.decodeObject(forKey: "hexCell")
        if (hexCell != nil) {
            self._hexCell = (hexCell as? HexCell)!
        }
        
        if (decoder.containsValue(forKey: "isCollectible")) {
            self.isCollectible = decoder.decodeBool(forKey: "isCollectible")
        } else {
            self.isCollectible = false
        }
        
        let caption = decoder.decodeObject(forKey: "caption")
        if (caption != nil) {
            self.caption = (caption as? String)!
        }
        
        self.skipTurnCounter = decoder.decodeInteger(forKey: "skipTurnCounter")
        self.skipTurnsOnPlace = decoder.decodeInteger(forKey: "skipTurnsOnPlace")
    }
    
    /**
        Encode for NSCoder
    */
    func encode(with coder: NSCoder) {
        coder.encode(self.originalValue, forKey: "originalValue")
        coder.encode(self.value, forKey: "value")
        
        coder.encode(self._hexCell, forKey: "hexCell")
        
        coder.encode(self.caption, forKey: "caption")
        
        coder.encode(self.isCollectible, forKey: "isCollectible")
        
        coder.encode(self.skipTurnCounter, forKey: "skipTurnCounter")
        coder.encode(self.skipTurnsOnPlace, forKey: "skipTurnsOnPlace")
    }
    
    /**
        Returns the minimum value that this piece can merge with
    */
    func getMinMergeValue() -> Int {
        return self.value
    }
    
    /**
        Returns the maximum value that this piece can merge with
    */
    func getMaxMergeValue() -> Int {
        return self.value
    }
    
    /*
        Returns string used to identify this piece for statistics purposes
    */
    func getStatsKey() -> String {
        return "piece_value_\(self.value)"
    }
    
    /**
        Returns true if this piece can merge with hexPiece
    */
    func canMergeWithPiece(_ hexPiece: HexPiece) -> Bool {
        var result = false
        
        if (self.value == hexPiece.value && !self.isCollectible) {
            result = true
        }
        
        return result
    }
    
    /**
        Returns true if this piece can be placed on the gameboard without a merge
    */
    func canPlaceWithoutMerge() -> Bool {
        return true
    }
    
    /**
        Increase the value of this piece as though it had been merged, for merge testing purposes
    */
    func updateValueForMergeTest() {
        self.value += 1
    }
    
    /**
        Decrement the value of this piece after merge testing has finished
    */
    func rollbackValueForMergeTest() {
        self.value -= 1
    }
    
    /**
        Called after piece has been placed on a hexmap and was merged with other piece(s)
    */
    func wasPlacedWithMerge(_ mergeValue: Int = -1, mergingPieces: [HexPiece]) -> HexPiece {
        // Update to the next value in sequence, or cap at maxPieceValue
        self.value = mergeValue + 1
        
        if (self.value > HexMapHelper.instance.maxPieceValue) {
            self.value = HexMapHelper.instance.maxPieceValue
        }
        
        if (self.value == HexMapHelper.instance.maxPieceValue) {
            self.isCollectible = true
            self.addAnimation(self.sprite!)
        }
    
        self.sprite!.run(SKAction.sequence([
            SKAction.scale(to: 0.01, duration: 0.1),
            SKAction.setTexture(HexMapHelper.instance.hexPieceTextures[self.value]),
            SKAction.scale(to: 1.0, duration: 0.15)
        ]))
        self.skipTurnCounter = self.skipTurnsOnPlace
        
        self.playMergeSound()
        
        // Clear caption, if any
        self.caption = ""
        
        return self
    }
    
    /**
        Called before a turn will be taken, and before merges occur for the current round post-player move
     */
    func preTakeTurn() {
        // placeholder
    }
    
    /**
        Called when piece was placed on a hexmap without merging with any other piece(s)
    */
    func wasPlacedWithoutMerge() {
        self.skipTurnCounter = self.skipTurnsOnPlace
        
        // Clear caption, if any
        self.caption = ""
        
        self.playPlacementSound()
    }
    
    /**
        - Returns: Points to be awarded when piece is collected
    */
    func getCollectedValue() -> Int {
        return 200000
    }
    
    /**
        - Returns: Calculated point value based on the piece's value
    */
    func getPointValue() -> Int {
        var points = 10
        
        switch (self.value) {
            case 0: // Triangle
            break
            case 1: // Square
                points = 100
            break
            case 2: // Pentagon
                points = 500
            break
            case 3: // Hexagon
                points = 1000
            break
            case 4: // Purple Star
                points = 10000
            break
            case 5: // Gold Star
                points = 25000
            break
            case 6: // Collectible Gold Star
                points = 25000
            break
            default:
            break
        }
        
        return points
    }
    
    /**
        - Returns: Description of this piece, suitable for display to player
    */
    func getPieceDescription() -> String {
        var description = "Unknown"
        
        switch (self.value) {
            case 0: // Triangle
                description = "Triangle"
            break
            case 1: // Square
                description = "Square"
            break
            case 2: // Pentagon
                description = "Pentagon"
            break
            case 3: // Hexagon
                description = "Hexagon"
            break
            case 4: // Star
                description = "Star"
            break
            case 5: // Gold Star
                description = "Gold Star"
            break
            case 6: // Collectible Gold Star
                description = "Gold Stars"
            break
            default:
            break
        }
        
        return description
    }
    
    /**
        Creates a sprite to represent the hex piece
    
        - Returns: Instance of SKSpriteNode
    */
    func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: HexMapHelper.instance.hexPieceTextures[self.value])
    
        node.name = "hexPiece"
        
        self.addAnimation(node)
    
        return node
    }
    
    func createMergedSprite() -> SKSpriteNode? {
        var node: SKSpriteNode?
        
        if (self.value+1 <= HexMapHelper.instance.maxPieceValue) {
            node = SKSpriteNode(texture: HexMapHelper.instance.hexPieceTextures[self.value+1])
            node!.name = "hexPiece"
        }
        
        return node
    }
    
    func addAnimation(_ node: SKSpriteNode) {
        if (self.isCollectible) {
            let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.5)
            let scaleDownAction = SKAction.scale(to: 0.9, duration: 0.5)
            let rotateRightAction = SKAction.rotate(byAngle: 0.5, duration: 0.25)
            let rotateLeftAction = SKAction.rotate(byAngle: -0.5, duration: 0.25)
            
            let collectibleGroup = SKAction.group([
                SKAction.sequence([scaleUpAction,scaleDownAction]),
                SKAction.sequence([rotateRightAction,rotateLeftAction,rotateLeftAction,rotateRightAction])
                ])
            
            node.run(SKAction.repeatForever(collectibleGroup))
        }
    }
    
    func removeAnimation() {
        self.sprite!.removeAllActions()
        self.sprite!.removeAllChildren()
    }
    
    /**
        Allow piece to do something after player has taken a turn.
    
        - Returns: True if piece did something.
    */
    func takeTurn() -> Bool {
        if (self.skipTurnCounter > 0) {
            self.skipTurnCounter -= 1
            self.didTakeTurn = false
        } else {
            self.didTakeTurn = true
        }
        
        return self.didTakeTurn
    }
    
    /**
        Called when piece is collected by player
    */
    func wasCollected() {
        let scaleAction = SKAction.scale(to: 0.0, duration: 0.25)
        let collectSequence = SKAction.sequence([scaleAction, SKAction.removeFromParent()])
        
        // Award points, if any
        let points = self.getCollectedValue()
        if (points > 0) {
            SceneHelper.instance.gameScene.awardPoints(points)
            SceneHelper.instance.gameScene.scrollPoints(points, position: self.sprite!.position)
        }
        
        // Award achievement for collecting stars
        if (self.value == 6) {
            let achievement = GKAchievement(identifier: "com.snazzware.mergel.Star")
            
            achievement.percentComplete = 100
            achievement.showsCompletionBanner = true
            
            GameKitHelper.sharedInstance.reportAchievements([achievement])
        }
        
        // Animate the collection
        self.sprite!.run(collectSequence)
        
        // Play collect sound
        self.playCollectionSound()
    }
    
    func playCollectionSound() {
        self.sprite!.run(SoundHelper.instance.collect)
    }
    
    func playPlacementSound() {
        self.sprite!.run(SoundHelper.instance.placePiece)
    }
    
    func playMergeSound() {
        self.sprite!.run(SoundHelper.instance.mergePieces)
    }
    
    /**
        Called when piece is removed from the gameboard without collection / merge, i.e. by player using a RemovePiece.
    */
    func wasRemoved() {
        let collectSequence = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.08),
            SKAction.scale(to: 0.8, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08),
            SKAction.scale(to: 0.8, duration: 0.08),
            SKAction.scale(to: 0.9, duration: 0.08),
            SKAction.scale(to: 0.7, duration: 0.08),
            SKAction.scale(to: 0.8, duration: 0.08),
            SKAction.scale(to: 0.5, duration: 0.08),
            SKAction.scale(to: 0.2, duration: 0.08),
            SKAction.scale(to: 0.0, duration: 0.08),
            SKAction.removeFromParent()
        ])
        
        // Animate the collection
        self.sprite!.run(collectSequence)
    }

    
}
