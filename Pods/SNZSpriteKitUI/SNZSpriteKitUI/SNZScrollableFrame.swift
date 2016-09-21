//
//  SNZScrollableFrame.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/8/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

open class SNZScrollableFrame: SNZFrame {

    open var content = SKNode()

    open var contentMaximumPoint: CGPoint = CGPoint(x: 0,y: 0)
    open var contentMinimumPoint: CGPoint = CGPoint(x: 0,y: 0)

    override public init() {
        super.init()

        self.size = CGSize(width: 200, height: 48)

        self.wantsPanGestures = true

        self.bind("blur",{
            if (abs(self.contentMinimumPoint.y) > self.size.height) {
                if (self.content.position.y < self.size.height) {
                    self.content.run(SKAction.move(to: CGPoint(x: 0,y: self.size.height - self.contentMaximumPoint.y), duration: 0.25))
                }

                if (self.content.position.y > abs(self.contentMinimumPoint.y)) {
                    self.content.run(SKAction.move(to: CGPoint(x: 0,y: abs(self.contentMinimumPoint.y)), duration: 0.25))
                }
            }
        })
    }

    override open func panGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)

        if (abs(self.contentMinimumPoint.y) > self.size.height) {

            var adjustment = translation.y

            if (self.content.position.y - adjustment < (self.size.height - self.contentMaximumPoint.y)) {
                adjustment /= (abs(self.content.position.y - adjustment) / 50)
            }

            if (self.content.position.y - adjustment > (abs(self.contentMinimumPoint.y))) {
                adjustment /= (abs(self.content.position.y - adjustment) / 50)
            }

            self.content.position.y -= adjustment

            sender.setTranslation(CGPoint.zero, in: sender.view!)

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

    override open func render() {

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

        self.contentMaximumPoint = CGPoint(x: 0,y: maxY)
        self.contentMinimumPoint = CGPoint(x: 0,y: minY)

        let cropNode = SKCropNode()

        let frameRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let frameSprite = SKShapeNode(rect: frameRect)
        frameSprite.fillColor = self.backgroundColor
        frameSprite.strokeColor = self.strokeColor
        frameSprite.lineWidth = 1

        print(frameSprite.fillColor)

        self.content.position = CGPoint(x: 0,y: self.size.height - self.contentMaximumPoint.y)

        frameSprite.addChild(self.content)
        frameSprite.ignoreTouches = true
        self.content.ignoreTouches = true

        let mask = SKShapeNode(rect: frameRect)
        mask.fillColor = UIColor.green
        mask.strokeColor = UIColor.clear
        mask.name = "mask"

        cropNode.name = "cropNode"
        frameSprite.name = "frameSprite"
        self.content.name = "content"

        let touchNode = SKShapeNode(rect: frameRect)
        touchNode.fillColor = UIColor.clear
        touchNode.strokeColor = UIColor.clear
        touchNode.name = "touchable"
        
        cropNode.maskNode = mask
        cropNode.addChild(frameSprite)
        cropNode.addChild(touchNode)
        cropNode.position = self.position

        self.sprite = cropNode

        super.render()

        self.sprite = frameSprite

        // Set touchableSprite so that touches outside mask don't register
        self.touchableSprite = touchNode
    }

}
