//
//  IntroScene.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 07/11/2025.
//
import Foundation
import SpriteKit

class IntroScene1: SKScene {
    private var viewModel: ViewModel!
    
    private var ship: SKSpriteNode!
    private var space: SKSpriteNode!
    private var seed: SKNode!
    
    class func newGameScene(_ viewModel: ViewModel) -> IntroScene1 {
        // Load 'GameScene.sks' as an SKScene.
        let scene = IntroScene1()
        scene.createScene()
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.viewModel = viewModel
        return scene
    }
    
    private func createScene() {
        let filter = CIFilter(name: "CIPixellate")!
        filter.setDefaults()
        filter.setValue(8, forKey: "inputScale")
        
        let effectNode = SKEffectNode()
        effectNode.filter = filter
        effectNode.shouldEnableEffects = true
        effectNode.shouldRasterize = true
        effectNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(effectNode)
        
        let rootNode = SKNode()
        effectNode.addChild(rootNode)
        
        let camera = SKCameraNode()
        camera.setScale(1000)
        let ship = SKSpriteNode(imageNamed: "ship_1")
        ship.size = CGSize(width: 15 * 15, height: 15 * 10)
        ship.zRotation = 0.4
        let space = SKSpriteNode(imageNamed: "space_1")
        space.size = CGSize(width: 200 * 15, height: 200 * 10)
        rootNode.addChild(space)
        rootNode.addChild(ship)
        rootNode.addChild(camera)
        self.camera = camera
        self.ship = ship
        self.space = space
        
        let moveAction = SKAction.moveBy(x: -400, y: -800, duration: 5)
        let rumbleAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.05),
            SKAction.rotate(byAngle: -0.1, duration: 0.05)
        ]))
        let textureAction = SKAction.animate(with: [
            SKTexture(imageNamed: "ship_1"),
            SKTexture(imageNamed: "ship_2"),
            SKTexture(imageNamed: "ship_3")
        ], timePerFrame: 0.1, resize: false, restore: false)
        let cameraZoomAction = SKAction.scale(by: 0.5, duration: 0.75)
        let leaveAction = SKAction.moveBy(x: -400, y: 800, duration: 1)
        camera.run(moveAction)
        ship.run(moveAction) {
            ship.removeAction(forKey: "rumble")
            ship.run(SKAction.rotate(byAngle: -0.5, duration: 0.25))
            camera.run(cameraZoomAction) {
                self.dropSeed {
                    ship.run(rumbleAction, withKey: "rumble")
                    ship.run(leaveAction) {
                        ship.removeAllActions()
                        ship.removeFromParent()
                        self.zoomExit()
                    }
                }
            }
        }
        ship.run(rumbleAction, withKey: "rumble")
        ship.run(SKAction.repeatForever(textureAction))
    }
    
    private func dropSeed(_ onComplete: @escaping () -> Void) {
        let seed = SKShapeNode(rect: CGRect(origin: .zero, size: CGSize(width: 0.001, height: 0.001)))
        seed.fillColor = .cyan
        seed.setScale(100)
        seed.position = ship.position
        self.seed = seed
        addChild(seed)
        
        seed.run(SKAction.moveBy(x: 0, y: -150, duration: 2)) {
            onComplete()
        }
    }
    
    private func zoomExit() {
        camera!.run(SKAction.move(to: seed.position, duration: 0.5))
        camera!.run(SKAction.scale(by: 0.01, duration: 0.5)) {
            self.view?.presentScene(IntroScene2.newGameScene(self.viewModel))
        }
    }
}
