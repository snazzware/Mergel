//
//  SNZEventReceiver.swift
//  SNZSpriteKitUI
//
//  Created by Josh M. McKee on 9/29/16.
//  Copyright © 2016 Josh McKee. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public typealias SNZEventHandler = () -> ()

open class SNZEventReceiver : UIResponder {
    // Dictionary of events
    open var events = [String: [String: SNZEventHandler]]()
    
    /**
     Bind a handler to a named event
     */
    open func bind(_ event: String, _ handler: @escaping SNZEventHandler) {
        self.bind(event, handler, forKey: UUID().uuidString)
    }
    
    /**
     Bind a handler to a named event with a given key
     */
    open func bind(_ event: String, _ handler: @escaping SNZEventHandler, forKey: String) {
        if (self.events[event] == nil) {
            self.events[event] = [String: SNZEventHandler]()
        }
        self.events[event]![forKey] = handler
    }
    
    /**
     Unbinds a handler from a named event for a given key, or all handlers for the named event if no key is specified.
     */
    open func unbind(_ event: String, _ key: String? = nil) {
        if (key == nil) {
            self.events[event]?.removeAll()
        } else {
            self.events[event]?.removeValue(forKey: key!)
        }
    }
    
    /**
     Trigger handler(s) for a named event.
     */
    open func trigger(_ event: String) {
        if (self.events[event] != nil) {
            for (_, handler) in self.events[event]! {
                handler()
            }
        }
    }
    
}
