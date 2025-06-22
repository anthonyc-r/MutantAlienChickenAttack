//
//  GameOverScene.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SpriteKit

class GameOverScene: SKScene {
    override func sceneDidLoad() {
        super.sceneDidLoad()
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    private func setUpScene() {
        childNode(withName: "restart_label")?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.0, duration: 1),
            SKAction.fadeAlpha(to: 1.0, duration: 1)
        ])))
    }
    
//    override func keyUp(with event: NSEvent) {
//        if KeyCode(rawValue: event.keyCode) == .space {
//            view?.presentScene(CoupScene.newGameScene(), transition: SKTransition.reveal(with: .down, duration: 1))
//        }
//    }
}
