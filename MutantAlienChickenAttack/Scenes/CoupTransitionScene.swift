//
//  CoupTransitionScene.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SpriteKit
import Combine
import SwiftUI

class CoupTransitionScene: SKScene {
    private var viewModel: ViewModel!
    private var observations = [AnyCancellable]()
    private var chickenStart = CGPoint.zero
    private var chicken: PlayerSprite!
    
    class func newGameScene(_ viewModel: ViewModel, _ chickenStart: CGPoint? = nil) -> CoupTransitionScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "CoupTransitionScene") as? CoupTransitionScene else {
            print("Failed to load CoupTransitionScene.sks")
            abort()
        }
        if let start = chickenStart {
            scene.chickenStart = start
        }
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.viewModel = viewModel
        return scene
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let chickenEnd = childNode(withName: "chicken_destination")!.position
        let chickenNow = chicken.position
        let vec = CGVector(dx: chickenEnd.x - chickenNow.x, dy: chickenEnd.y - chickenNow.y)
        if abs(vec.dx) + abs(vec.dy) > 10 {
            chicken.position = CGPoint(
                x: chickenNow.x + 5 * (vec.dx / abs(vec.dx)),
                y: chickenNow.y + 5 * (vec.dy / abs(vec.dy))
            )
            chicken.setDirection(vec)
        }
    }
    
    private func setUpScene() {
        let chickenSprite = PlayerSprite()
        chickenSprite.size = CGSize(width: 64, height: 64)
        addChild(chickenSprite)
        chickenSprite.position = chickenStart
        chicken = chickenSprite
    }
}
