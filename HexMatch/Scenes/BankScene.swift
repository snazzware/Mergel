//
//  BankScene.swift
//  HexMatch
//
//  Created by Josh McKee on 1/30/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import SpriteKit
import SNZSpriteKitUI

class BankScene: SNZScene {
    
    override func didMoveToView(view: SKView) {    
        super.didMoveToView(view)
        
        self.updateGui()
    }
    
    func close() {
        self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.pushWithDirection(SKTransitionDirection.Up, duration: 0.4))
    }
    
    func updateGui() {
        self.removeAllChildren()
        self.widgets.removeAll()
    
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Create primary header
        let caption = SKLabelNode(fontNamed: "Avenir-Black")
        caption.text = "Tap to Spend Points"
        caption.fontColor = UIColor.whiteColor()
        caption.fontSize = 24
        caption.horizontalAlignmentMode = .Center
        caption.verticalAlignmentMode = .Center
        caption.position = CGPointMake(self.size.width / 2, self.size.height - 20)
        caption.ignoreTouches = true
        self.addChild(caption)
        
        // Create sub-header
        let pointCaption = SKLabelNode(fontNamed: "Avenir-Black")
        pointCaption.text = "\(GameState.instance!.bankPoints) Points Available"
        pointCaption.fontColor = UIColor.whiteColor()
        pointCaption.fontSize = 18
        pointCaption.horizontalAlignmentMode = .Center
        pointCaption.verticalAlignmentMode = .Center
        pointCaption.position = CGPointMake(self.size.width / 2, self.size.height - 40)
        pointCaption.ignoreTouches = true
        self.addChild(pointCaption)
        
        // Create array of buyable button widgets to represent the pieces we have available
        var buyables: [BuyableButtonWidget] = Array()
        
        // Create buttons for buyables
        for buyablePiece in GameState.instance!.buyablePieces {
            let buyable = BuyableButtonWidget()
            
            let hexPiece = buyablePiece.createPiece()
            
            buyable.buyableSprite = hexPiece.createSprite()
            buyable.caption = hexPiece.getPieceDescription()
            buyable.points = buyablePiece.currentPrice
            
            buyable.bind("tap",{
                SceneHelper.instance.gameScene.captureState()
                SceneHelper.instance.gameScene.spendBankPoints(buyable.points)
                LevelHelper.instance.pushPiece(GameState.instance!.currentPiece!)
                SceneHelper.instance.gameScene.setCurrentPiece(hexPiece)
                buyablePiece.wasPurchased()
                self.close()
            });
            buyables.append(buyable)
        }
        
        // Position and add the buyable button widgets
        let verticalStart:CGFloat = self.frame.height - 110
        var horizontalOffset:CGFloat = 10
        var verticalOffset = verticalStart
        
        for buyable in buyables {
            buyable.position = CGPointMake(horizontalOffset,verticalOffset)
            self.addWidget(buyable)
            
            verticalOffset -= 60
            
            if (verticalOffset < 60) {
                horizontalOffset += buyable.size.width + 10
                verticalOffset = verticalStart
            }
        }
        
        // Add the close button
        let closeButton = SNZButtonWidget(parentNode: self)
        closeButton.anchorPoint = CGPointMake(0,0)
        closeButton.caption = "Cancel"
        closeButton.bind("tap",{
            self.close()
        });
        self.addWidget(closeButton)
        
        // Render the widgets
        self.renderWidgets()
    }
    
}