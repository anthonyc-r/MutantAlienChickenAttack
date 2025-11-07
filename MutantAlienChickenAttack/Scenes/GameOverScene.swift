//
//  GameOverScene.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SpriteKit

class GameOverScene: SKScene {
    private var viewModel: ViewModel!
    
    class func newGameScene(_ viewModel: ViewModel) -> GameOverScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameOverScene") as? GameOverScene else {
            print("Failed to load GameOverScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.viewModel = viewModel
        return scene
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
}


#if os(OSX)
extension GameOverScene {
    override func keyUp(with event: NSEvent) {
        if KeyCode(rawValue: event.keyCode) == .space {
            view?.presentScene(CoupScene.newGameScene(viewModel), transition: SKTransition.reveal(with: .down, duration: 1))
        }
    }
}
#endif
