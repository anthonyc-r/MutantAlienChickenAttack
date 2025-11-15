//
//  IntroScene.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 07/11/2025.
//
import Foundation
import SpriteKit

class IntroScene2: SKScene {
    private var viewModel: ViewModel!
    
    private var ship: SKSpriteNode!
    private var space: SKSpriteNode!
    private var seed: SKNode!
    
    class func newGameScene(_ viewModel: ViewModel) -> IntroScene2 {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = IntroScene2(fileNamed: "IntroScene2") else {
            fatalError("Failed to load IntroScene2")
        }
        scene.createScene()
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.viewModel = viewModel
        return scene
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        camera = childNode(withName: "camera") as? SKCameraNode
        (childNode(withName: "egg") as? SKSpriteNode)?.texture?.filteringMode = .nearest
    }
    
    private func createScene() {
    }
}
