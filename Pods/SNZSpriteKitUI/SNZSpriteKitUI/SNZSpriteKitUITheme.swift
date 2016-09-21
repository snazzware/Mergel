//
//  SNZSpriteKitUITheme.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/5/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

open class SNZSpriteKitUIMargins {
    open var left: CGFloat
    open var right: CGFloat
    open var top: CGFloat
    open var bottom: CGFloat

    open var horizontal: CGFloat {
        get {
            return self.left + self.right
        }
    }

    open var vertical: CGFloat {
        get {
            return self.top + self.bottom
        }
    }

    init (_ top: CGFloat, _ right: CGFloat, _ bottom: CGFloat, _ left: CGFloat) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
}

open class SNZSpriteKitUITheme {

    open static var instance = SNZSpriteKitUITheme()

    open var frameworkBundle: Bundle = Bundle(for: SNZSpriteKitUITheme.self)
    open var textures: SKTextureAtlas
    open var uiOuterMargins = SNZSpriteKitUIMargins(20,20,20,20)
    open var uiInnerMargins = SNZSpriteKitUIMargins(10,10,10,10)

    open var labelColor = UIColor.white
    open var labelBackground = UIColor.clear

    open var frameBackgroundColor = UIColor.white
    open var frameStrokeColor = UIColor.black

    init() {
        //print(self.frameworkBundle.bundlePath)
        //let atlasPath = self.frameworkBundle.pathForResource("SNZSpriteKitUIGraphics", ofType: "atlasc")!
        // print(atlasPath)
        self.textures = SKTextureAtlas(named: "SNZSpriteKitUIGraphics")
        //self.textures = SKTextureAtlas(coder: coder)
    }


}
