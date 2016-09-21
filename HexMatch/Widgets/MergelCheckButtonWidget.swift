//
//  MergelCheckButtonWidget.swift
//  Mergel
//
//  Created by Josh McKee on 9/9/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SNZSpriteKitUI

class MergelCheckButtonWidget : SNZCheckButtonWidget {
    
    override init() {
        super.init()
        
        self.color = UIColor.white
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.focusBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
    }
    
}
