//
//  SNZScrollableFrame.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/8/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

public class SNZScrollableFrame: SNZFrame {
    
    public var content = SKNode()
    
    public var contentMaximumPoint: CGPoint = CGPointMake(0,0)
    public var contentMinimumPoint: CGPoint = CGPointMake(0,0)
    
    override public init() {
        super.init()
        
        self.size = CGSizeMake(200, 48)
        
        self.wantsPanGestures = true
        
        self.bind("blur",{
            if (abs(self.contentMinimumPoint.y) > self.size.height) {
                if (self.content.position.y < self.size.height) {
                    self.content.runAction(SKAction.moveTo(CGPointMake(0,self.size.height - self.contentMaximumPoint.y), duration: 0.25))
                }
                
                if (self.content.position.y > abs(self.contentMinimumPoint.y)) {
                    self.content.runAction(SKAction.moveTo(CGPointMake(0,abs(self.contentMinimumPoint.y)), duration: 0.25))
                }
            }
        })
    }
    
    override public func panGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(sender.view!)
        
        if (abs(self.contentMinimumPoint.y) > self.size.height) {
            
            var adjustment = translation.y
            
            if (self.content.position.y - adjustment < (self.size.height - self.contentMaximumPoint.y)) {
                adjustment /= (abs(self.content.position.y - adjustment) / 50)
            }
            
            if (self.content.position.y - adjustment > (abs(self.contentMinimumPoint.y))) {
                adjustment /= (abs(self.content.position.y - adjustment) / 50)
            }
            
            self.content.position.y -= adjustment
            
            sender.setTranslation(CGPointZero, inView: sender.view!)
            
            /*
            print("-----")
            print(self.content.position)
            print(self.contentMaximumPoint)
            print(self.contentMinimumPoint)
            print(self.size)
            print("-----")
            */
       }
    }
    
    override public func render() {
        
        // Find size of contents
        var minY: CGFloat = 999999
        var maxY: CGFloat = -999999
        for node in self.content.children {
            if (node.frame.maxY > maxY) {
                maxY = node.frame.maxY
            }
            if (node.frame.minY < minY) {
                minY = node.frame.minY
            }
        }
        
        // Apply margins
        maxY += SNZSpriteKitUITheme.instance.uiInnerMargins.top
        minY -= SNZSpriteKitUITheme.instance.uiInnerMargins.bottom
        
        self.contentMaximumPoint = CGPointMake(0,maxY)
        self.contentMinimumPoint = CGPointMake(0,minY)
        
        let cropNode = SKCropNode()
        
        let frameRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let frameSprite = SKShapeNode(rect: frameRect)
        frameSprite.fillColor = UIColor.whiteColor()
        frameSprite.strokeColor = UIColor.blackColor()
        frameSprite.lineWidth = 1
    
        self.content.position = CGPointMake(0,self.size.height - self.contentMaximumPoint.y)
    
        frameSprite.addChild(self.content)
        frameSprite.ignoreTouches = true
        self.content.ignoreTouches = true
        
        let mask = SKShapeNode(rect: frameRect)
        mask.fillColor = UIColor.whiteColor()
        mask.name = "mask"
        
        cropNode.name = "cropNode"
        frameSprite.name = "frameSprite"
        self.content.name = "content"
        
        cropNode.maskNode = mask
        cropNode.addChild(frameSprite)
        cropNode.addChild(mask)
        cropNode.position = self.position
        
        self.sprite = cropNode    
        
        super.render()
        
        self.sprite = frameSprite
        
        // Set touchableSprite so that touches outside mask don't register
        self.touchableSprite = mask
    }
    
}