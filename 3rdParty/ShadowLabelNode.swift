//
//  SKLabelNode+ShadowLabelNode.swift
//
// A Swift port of Erica Sadun's ShadowLabelNode class.  Released under the Creative Commons 0 (CC0) license.
// Port done by Phillip Brisco
//
// Phillip Brisco - Added removeLabel() function so that user can easily delete all observers on the label before deleting
//                  the label, then delete the label itself.  This way, the user doesn't have to worry about it.
//
import SpriteKit

class ShadowLabelNode : SKLabelNode {
    var offset : CGPoint = CGPoint(x: -1,y: 1)
    var shadowColor : UIColor = UIColor.black
    var blurRadius : CGFloat = 3.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init () {
        super.init()
    }
    
    // Inital setup for the shadow node (in Objective-C this is the instanceType method)
    override init(fontNamed fontName: String?) {
        super.init(fontNamed: fontName)
    }
    
    func updateShadow () {
        var effectNode : SKEffectNode? = self.childNode(withName: "ShadowEffectNodeKey") as? SKEffectNode
        
        if (effectNode == nil) {
            effectNode = SKEffectNode();
            effectNode!.name = "ShadowEffectNodeKey"
            effectNode!.shouldEnableEffects = true
            effectNode!.zPosition = -1
        }
        
        // Super slow!
        /*let filter : CIFilter? = CIFilter (name: "CIGaussianBlur")
        filter?.setDefaults();
        filter?.setValue(blurRadius, forKey: "inputRadius")
        effectNode?.filter = filter
        effectNode?.removeAllChildren()*/
        
        // Duplicate and offset the label
        let labelNode = SKLabelNode (fontNamed: self.fontName)
        labelNode.text = self.text
        labelNode.fontSize = self.fontSize
        labelNode.verticalAlignmentMode = self.verticalAlignmentMode
        labelNode.horizontalAlignmentMode = self.horizontalAlignmentMode
        labelNode.fontColor = self.fontColor
        labelNode.position = offset            // Offset from parent
        labelNode.zPosition = self.zPosition+1
        
        // Become the shadow
        self.fontColor = shadowColor
        
        // Add the new foreground label
        self.addChild(labelNode)
    }
    
    func nodeTexture () -> SKTexture {
        return self.scene!.view!.texture(from: self)!
    }
    
}

extension ShadowLabelNode {
    
    // Removes all of the observers for the shadow node and the label itself.
    func removeLabel () {
        
        for keyPath in ["text", "fontName", "fontSize", "verticalAlignmentMode", "horizontalAlignmentMode", "fontColor"] {
            self.removeObserver(self, forKeyPath: keyPath);
            self.removeFromParent();
        }
        
    }
    
}
