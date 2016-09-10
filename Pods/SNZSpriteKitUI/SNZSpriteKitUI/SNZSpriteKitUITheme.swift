//
//  SNZSpriteKitUITheme.swift
//  SNZSpriteKitUI
//
//  Created by Josh McKee on 2/5/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit

public class SNZSpriteKitUIMargins {
    public var left: CGFloat
    public var right: CGFloat
    public var top: CGFloat
    public var bottom: CGFloat

    public var horizontal: CGFloat {
        get {
            return self.left + self.right
        }
    }

    public var vertical: CGFloat {
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

public class SNZSpriteKitUITheme {

    public static var instance = SNZSpriteKitUITheme()

    public var frameworkBundle: NSBundle = NSBundle(forClass: SNZSpriteKitUITheme.self)
    public var textures: SKTextureAtlas
    public var uiOuterMargins = SNZSpriteKitUIMargins(20,20,20,20)
    public var uiInnerMargins = SNZSpriteKitUIMargins(10,10,10,10)

    public var labelColor = UIColor.whiteColor()
    public var labelBackground = UIColor.clearColor()

    public var frameBackgroundColor = UIColor.whiteColor()
    public var frameStrokeColor = UIColor.blackColor()

    init() {
        //print(self.frameworkBundle.bundlePath)
        //let atlasPath = self.frameworkBundle.pathForResource("SNZSpriteKitUIGraphics", ofType: "atlasc")!
        // print(atlasPath)
        self.textures = SKTextureAtlas(named: "SNZSpriteKitUIGraphics")
        //self.textures = SKTextureAtlas(coder: coder)
    }


}
