//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by yo hanashima on 2017/06/20.
//  Copyright © 2017年 yo hanashima. All rights reserved.
//

import SpriteKit
import GameplayKit

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

extension CGVector {
    public func length() -> CGFloat {
        return CGFloat(sqrt(dx*dx + dy*dy))
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game object connections */
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    
    /* cantileverNode */
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    
    /* Physics helpers */
    var touchJoint: SKPhysicsJointSpring?
    
    var penguinJoint: SKPhysicsJointPin?
    
    /* Define a var to hold the camera */
    var cameraNode:SKCameraNode!
    
    /* Add an optional camera target */
    var cameraTarget: SKSpriteNode?
    
    /* reset button */
    var buttonRestart: MSButtonNode!
    
    /* main menu Button */
    var buttonMainMenu: MSButtonNode!
    
    /* score label */
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    
    /* stage level */
    var stageLevel: Int!
    
    /* the number of seals in each stage */
    let numSealsArray: [Int] = [6, 5, 4]
    
    /* for counting seals */
    var sealsArray = [String]()
    
    /* penguin life = 3 */
    var life: Int = 3
    var penguinLife1: SKSpriteNode!
    var penguinLife2: SKSpriteNode!
    var penguinLife3: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        /* Set reference to catapultArm node */
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        catapult = childNode(withName: "catapult") as! SKSpriteNode
        cantileverNode = childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = childNode(withName: "touchNode") as! SKSpriteNode
        
        /* Set scoreLabel */
        scoreLabel = childNode(withName: "//scoreLabel") as! SKLabelNode
        
        /* Set penguin life node */
        penguinLife1 = childNode(withName: "penguinLife1") as! SKSpriteNode
        penguinLife2 = childNode(withName: "penguinLife2") as! SKSpriteNode
        penguinLife3 = childNode(withName: "penguinLife3") as! SKSpriteNode
        
        /* Create a new Camera */
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        
        /* buttons */
        buttonRestart = childNode(withName: "//buttonRestart") as! MSButtonNode
        buttonMainMenu = childNode(withName: "//buttonMainMenu") as! MSButtonNode
        
        /* Reset the game when the reset button is tapped */
        buttonRestart.selectedHandler = {
            guard let scene = GameScene.level(self.stageLevel) else {
                print("Level 1 is missing?")
                return
            }
            view.presentScene(scene)
        }
        
        /* Move on to the main menu when the mainmenu button is tapped */
        buttonMainMenu.selectedHandler = {
            guard let scene = MainMenu(fileNamed: "MainMenu") else {
                return
            }
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        setupCatapult()
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set seals array for preventonn of duplicate count*/
        let numseals = numSealsArray[stageLevel-1]
        for i in 0..<numseals {
            sealsArray += ["seal\(i)"]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if nodeAtPoint.name == "catapultArm" {  // If the touched node is named "catapultArm" do...
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
            physicsWorld.add(touchJoint!)
            
            if life > 0 {
                let penguin = Penguin()
                addChild(penguin)
                penguin.position.x += catapultArm.position.x + 20
                penguin.position.y += catapultArm.position.y + 50
                penguin.physicsBody?.usesPreciseCollisionDetection = true
                penguinJoint = SKPhysicsJointPin.joint(withBodyA: catapultArm.physicsBody!,
                                                   bodyB: penguin.physicsBody!,
                                                   anchor: penguin.position)
                physicsWorld.add(penguinJoint!)
                cameraTarget = penguin
                
                switch life {
                case 1:
                    penguinLife1.removeFromParent()
                    break;
                case 2:
                    penguinLife2.removeFromParent()
                    break;
                case 3:
                    penguinLife3.removeFromParent()
                    break;
                default:
                    break;
                }
                
                life-=1
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchNode.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        
        if let penguinJoint = penguinJoint {
            physicsWorld.remove(penguinJoint)
        }
        
        // Check if there is a penuin assigned to the cameraTarget
        guard let penguin = cameraTarget else {
            return
        }
        
        // Make sure not to generate a force by touching off except "catapultArm"
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtpoint = atPoint(location)
        guard nodeAtpoint.name == "touchNode" else { return }
        
        // Generate a vector and a force based on the angle of the arm.
        let force: CGFloat = 300
        let r = catapultArm.zRotation
        let dx = cos(r) * force
        let dy = sin(r) * force
        // Apply an impulse at the vector.
        let v = CGVector(dx: dx, dy: dy)
        penguin.physicsBody?.applyImpulse(v)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        moveCamera()
        checkPenguin()
        
        /* unlock stages */
        unlockStage(stageLevel)
        
        /* check final stage */
        if stageLevel < numSealsArray.count {
            moveNextStage()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            /* Was the collision more than a gentle nudge? */
            if contact.collisionImpulse > 2.0 {
                /* Kill Seal */
                if contactA.categoryBitMask == 2 {
                    if sealsArray.contains(nodeA.name!) {
                        removeSeal(node: nodeA)
                        sealsArray = sealsArray.filter {$0 != nodeA.name}
                    }
                }
                if contactB.categoryBitMask == 2 {
                    if sealsArray.contains(nodeB.name!) {
                        removeSeal(node: nodeB)
                        sealsArray = sealsArray.filter {$0 != nodeB.name}
                    }
                }
            }
        }
    }
    
    func removeSeal(node: SKNode) {
        /* Seal death*/
        
        // for debug
//         print(node.name)
        
        /* Create our hero death action */
        let sealDeath = SKAction.run({
            /* Remove seal node from scene */
            node.removeFromParent()
        })
        self.run(sealDeath)
        
        /* update scores */
        self.score+=1
        self.scoreLabel.text = String(self.score)
            
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "Poof")!
        /* Position particles at the Seal node
         If you've moved Seal to an sks, this will need to be
         node.convert(node.position, to: self), not node.position */
        particles.position = node.position
        /* Add particles to scene */
        addChild(particles)
        let wait = SKAction.wait(forDuration: 5)
        let removeParticles = SKAction.removeFromParent()
        let seq = SKAction.sequence([wait, removeParticles])
        particles.run(seq)
        
        /* Play SFX */
        let sound = SKAction.playSoundFileNamed("sfx_seal", waitForCompletion: false)
        self.run(sound)
    }
    
    /* Make a Class method to load levels */
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        
        /* Set stage level */
        scene.stageLevel = levelNumber
        
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    func resetCamera() {
        /* Reset camera */
        let cameraReset = SKAction.move(to: CGPoint(x:0, y:camera!.position.y), duration: 1.5)
        let cameraDelay = SKAction.wait(forDuration: 0.5)
        let cameraSequence = SKAction.sequence([cameraDelay,cameraReset])
        cameraNode.run(cameraSequence)
        cameraTarget = nil
    }
    
    func checkPenguin() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        
        /* Check penguin has come to rest */
        if cameraTarget.physicsBody!.joints.count == 0 && cameraTarget.physicsBody!.velocity.length() < 1.00 {
            resetCamera()
        }
        
        if cameraTarget.position.y < -200 {
            cameraTarget.removeFromParent()
            resetCamera()
        }
    }
    
    func setupCatapult() {
        /* Pin joint */
        var pinLocation = catapultArm.position
        pinLocation.x += -10
        pinLocation.y += -70
        let catapultJoint = SKPhysicsJointPin.joint(
            withBodyA:catapult.physicsBody!,
            bodyB: catapultArm.physicsBody!,
            anchor: pinLocation)
        physicsWorld.add(catapultJoint)
        
        /* Spring joint catapult arm and cantilever node */
        var anchorAPosition = catapultArm.position
        anchorAPosition.x += 0
        anchorAPosition.y += 50
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: anchorAPosition, anchorB: cantileverNode.position)
        physicsWorld.add(catapultSpringJoint)
        catapultSpringJoint.frequency = 6
        catapultSpringJoint.damping = 0.5
    }
    
    func unlockStage(_ level: Int) {
        if numSealsArray[stageLevel-1] == score {
            /* unlock buttonLevel */
            switch level {
            case 1:
                MainMenu.flagLevel1 = true
                break;
            case 2:
                MainMenu.flagLevel2 = true
                break;
            case 3:
                MainMenu.flagLevel3 = true
                break;
            default:
                break;
            }
            
            /* for debug */
            // print(MainMenu.flagLevel1)
        }
    }
    
    func moveNextStage() {
        if numSealsArray[stageLevel-1] == score {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Game scene */
            guard let scene = GameScene.level(stageLevel+1) else {
                print("Could not load GameScene with level 1")
                return
            }
            
            /* Set stage level */
            scene.stageLevel = stageLevel+1
            
            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFit
            
            /* 4) Start game scene */
            let waitMoveStage = SKAction.wait(forDuration: 4)
            let presentScene = SKAction.run ({
                skView.presentScene(scene)
            })
            let seqMoveStage = SKAction.sequence([waitMoveStage, presentScene])
            self.run(seqMoveStage)
        }
    }
    
}
