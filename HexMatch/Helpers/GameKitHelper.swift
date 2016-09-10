/*
* Copyright (c) 2015-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Foundation
import GameKit

let PresentAuthenticationViewController = "PresentAuthenticationViewController"
let ShowGKGameCenterViewController = "ShowGKGameCenterViewController"

class GameKitHelper: NSObject {
  
  static let sharedInstance = GameKitHelper()
  
  var authenticationViewController: UIViewController?
  var gameCenterEnabled = false
  
  func authenticateLocalPlayer() {
    
    //1
    let localPlayer = GKLocalPlayer()
    localPlayer.authenticateHandler = {(viewController, error) in
      
      if viewController != nil {
        //2
        self.authenticationViewController = viewController
        
        NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController, object: self)
      } else if error == nil {
        //3
        self.gameCenterEnabled = true
      }
    }

  }
  
  func reportAchievements(achievements: [GKAchievement], errorHandler: ((NSError?)->Void)? = nil) {
    guard gameCenterEnabled else {
      return
    }
    
    GKAchievement.reportAchievements(achievements, withCompletionHandler: errorHandler)
  }
  
  func showGKGameCenterViewController(viewController: UIViewController) {
    guard gameCenterEnabled else {
      return
    }
    
    //1
    let gameCenterViewController = GKGameCenterViewController()
    
    //2
    gameCenterViewController.gameCenterDelegate = self
    
    //3
    viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
  }
  
  func reportScore(score: Int64, forLeaderBoardId leaderBoardId: String, errorHandler: ((NSError?)->Void)? = nil) {
    guard gameCenterEnabled else {
      return
    }
    
    //1
    let gkScore = GKScore(leaderboardIdentifier: leaderBoardId)
    gkScore.value = score
    
    //2
    GKScore.reportScores([gkScore], withCompletionHandler: errorHandler)
  }
}

extension GameKitHelper: GKGameCenterControllerDelegate {
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
  }
}