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
    
    override func didMove(to view: SKView) {    
        super.didMove(to: view)
        
        self.updateGui()
    }
    
    func close() {
        self.view?.presentScene(SceneHelper.instance.gameScene, transition: SKTransition.push(with: SKTransitionDirection.up, duration: 0.4))
    }
    
    func updateGui() {
        self.removeAllChildren()
        self.widgets.removeAll()
    
        // Set background
        self.backgroundColor = UIColor(red: 0x69/255, green: 0x65/255, blue: 0x6f/255, alpha: 1.0)
        
        // Create primary header
        let caption = SKLabelNode(fontNamed: "Avenir-Black")
        caption.text = "Tap to Spend Points"
        caption.fontColor = UIColor.white
        caption.fontSize = 24
        caption.horizontalAlignmentMode = .center
        caption.verticalAlignmentMode = .center
        caption.position = CGPoint(x: self.size.width / 2, y: self.size.height - 20)
        caption.ignoreTouches = true
        self.addChild(caption)
        
        // Create sub-header
        let pointCaption = SKLabelNode(fontNamed: "Avenir-Black")
        pointCaption.text = "\(HexMapHelper.instance.scoreFormatter.string(from: NSNumber(integerLiteral: GameState.instance!.bankPoints))!) Points Available"
        pointCaption.fontColor = UIColor.white
        pointCaption.fontSize = 18
        pointCaption.horizontalAlignmentMode = .center
        pointCaption.verticalAlignmentMode = .center
        pointCaption.position = CGPoint(x: self.size.width / 2, y: self.size.height - 44)
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
        var horizontalOffset:CGFloat = 20
        var verticalOffset = verticalStart
        
        for buyable in buyables {
            buyable.position = CGPoint(x: horizontalOffset,y: verticalOffset)
            self.addWidget(buyable)
            
            verticalOffset -= 60
            
            if (verticalOffset < 60) {
                horizontalOffset += buyable.size.width + 10
                verticalOffset = verticalStart
            }
        }
        
        // Add the close button
        let closeButton = MergelButtonWidget(parentNode: self)
        closeButton.anchorPoint = CGPoint(x: 0,y: 0)
        closeButton.caption = "Back"
        closeButton.bind("tap",{
            self.close()
        });
        self.addWidget(closeButton)
        
        // Render the widgets
        self.renderWidgets()
    }
    
}
