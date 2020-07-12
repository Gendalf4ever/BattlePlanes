//
//  MenuTouchClass.swift
//  PlaneBattles
//
//  Created by Master on 05/04/2020.
//  Copyright © 2020 Master. All rights reserved.
//

import SpriteKit
class MenuTouchClass: SKScene {
    var infinityGameButton:SKSpriteNode!
    override func didMove(to view: SKView) {
        infinityGameButton.self.childNode(withName: "infinityModeButton") as! SKSpriteNode
    }
}
