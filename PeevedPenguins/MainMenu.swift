//
//  MainMenu.swift
//  PeevedPenguins
//
//  Created by yo hanashima on 2017/06/20.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import Foundation

import SpriteKit

class MainMenu: SKScene {
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    
    /* Level buttons */
    var buttonLevel1: MSButtonNode!
    var buttonLevel2: MSButtonNode!
    var buttonLevel3: MSButtonNode!
    
    /* unlock level stages flag */
    static var flagLevel1: Bool?
    static var flagLevel2: Bool?
    static var flagLevel3: Bool?
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        buttonPlay = self.childNode(withName: "buttonPlay") as! MSButtonNode
        buttonLevel1 = self.childNode(withName: "buttonLevel1") as! MSButtonNode
        buttonLevel2 = self.childNode(withName: "buttonLevel2") as! MSButtonNode
        buttonLevel3 = self.childNode(withName: "buttonLevel3") as! MSButtonNode
        
        /* load each level stage */
        buttonPlay.selectedHandler = {
            self.loadGame(1)
        }
        
        buttonLevel1.selectedHandler = {
            self.loadGame(1)
        }
        
        buttonLevel2.selectedHandler = {
            self.loadGame(2)
        }
        
        buttonLevel3.selectedHandler = {
            self.loadGame(3)
        }
        
        /* for debug */
        //print(MainMenu.flagLevel1)
        
        /* Hide Level button */
        buttonLevel1.state = .msButtonNodeStateHidden
        buttonLevel2.state = .msButtonNodeStateHidden
        buttonLevel3.state = .msButtonNodeStateHidden
        
        /* unlock Level button */
        if MainMenu.flagLevel1 ?? false { buttonLevel1.state = .msButtonNodeStateActive }
        if MainMenu.flagLevel2 ?? false { buttonLevel2.state = .msButtonNodeStateActive }
        if MainMenu.flagLevel3 ?? false { buttonLevel3.state = .msButtonNodeStateActive }
    }
    
    func loadGame(_ level: Int) {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene.level(level) else {
            print("Could not load GameScene with level 1")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        // skView.showsPhysics = true
        // skView.showsDrawCount = true
        // skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
