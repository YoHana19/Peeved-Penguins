//
//  Penguin.swift
//  PeevedPenguins
//
//  Created by yo hanashima on 2017/06/20.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation

import SpriteKit

class Penguin: SKSpriteNode {
    
    init() {
        // Make a texture from an image, a color, and size
        let texture = SKTexture(imageNamed: "flyingpenguin")
        let color = UIColor.clear
        let size = texture.size()
        
        // Call the designated initializer
        super.init(texture: texture, color: color, size: size)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = 1
        physicsBody?.friction = 0.6
        physicsBody?.mass = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
