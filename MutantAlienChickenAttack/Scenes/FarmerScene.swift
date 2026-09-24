//
//  CoupTransitionScene.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SpriteKit
import Combine
import SwiftUI

class FarmerScene: SKScene {
    private var viewModel: ViewModel!
    private var observations = [AnyCancellable]()
    private var player: PlayerSprite!
    private var activeKeys = Set<KeyCode>()
    
    class func newGameScene(_ viewModel: ViewModel) -> FarmerScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "FarmerScene") as? FarmerScene else {
            print("Failed to load FarmerScene.sks")
            abort()
        }
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.viewModel = viewModel
        scene.observations.append(viewModel.$direction.sink { [weak scene] val in
            scene?.setDirection(val)
        })
        scene.observations.append(viewModel.$actionPressed.sink { [weak scene] val in
            scene?.setAction(val)
        })
        scene.observations.append(viewModel.$keyDown.sink { [weak scene] val in
            if let keycode = KeyCode(val?.key) {
                scene?.activeKeys.insert(keycode)
            }
        })
        scene.observations.append(viewModel.$keyUp.sink { [weak scene] val in
            if let keycode = KeyCode(val?.key) {
                scene?.activeKeys.remove(keycode)
            }
        })
        return scene
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        updatePlayer()
    }
    
    
    func setDirection(_ vector: CGSize) {
        activeKeys.remove(.rightArrow)
        activeKeys.remove(.leftArrow)
        activeKeys.remove(.upArrow)
        activeKeys.remove(.downArrow)
        
        let threshold: CGFloat = 0.5
        
        if vector.width < -threshold {
            activeKeys.insert(.leftArrow)
        } else if vector.width > threshold {
            activeKeys.insert(.rightArrow)
        }
        if vector.height > threshold {
            activeKeys.insert(.upArrow)
        } else if vector.height < -threshold {
            activeKeys.insert(.downArrow)
        }
    }
    
    func setAction(_ active: Bool) {
        if active {
            activeKeys.insert(.space)
        } else {
            activeKeys.remove(.space)
        }
    }
    
    private func updatePlayer() {
        if let vector = Direction(fromKeys: activeKeys)?.vector {
            player.setDirection(vector)
        } else {
            player.physicsBody?.velocity = .zero
        }
    }
    
    private func setUpScene() {
        let chickenSprite = PlayerSprite(nil)
        chickenSprite.size = CGSize(width: 64, height: 64)
        addChild(chickenSprite)
        chickenSprite.position = childNode(withName: "chicken_start")!.position
        player = chickenSprite
        if let map = childNode(withName: "building_map") as? SKTileMapNode {
            addCollisionBodies(from: map)
        }
        camera?.run(.moveBy(x: 0, y: -200, duration: 2.0))
    }
    
    private var healthBar: SKLabelNode {
        return descendant(withName: "health_label") as! SKLabelNode
    }
    private var healthContianer: SKNode {
        return childNode(withName: "health_background")!
    }
    private func addCollisionBodies(from tileMap: SKTileMapNode) {
        let tileSize = tileMap.tileSize

        for row in 0..<tileMap.numberOfRows {
            for col in 0..<tileMap.numberOfColumns {
                guard let _ = tileMap.tileDefinition(atColumn: col, row: row) else {
                    continue
                }
                
                let x = tileMap.frame.minX + (CGFloat(col) * tileSize.width) + (tileSize.width / 2)
                let y = tileMap.frame.minY + (CGFloat(row) * tileSize.height) + (tileSize.height / 2)
                let position = CGPoint(x: x - 1, y: y - 1)
                
                let modifiedSize = CGSize(width: tileSize.width + 2, height: tileSize.height + 2)
                
                let tileNode = SKNode()
                tileNode.position = position
                tileNode.physicsBody = SKPhysicsBody(rectangleOf: modifiedSize)
                tileNode.physicsBody?.isDynamic = false
                tileNode.physicsBody?.categoryBitMask = PhysicsCategory.building
                tileNode.physicsBody?.collisionBitMask = 0xFFFF
                tileNode.physicsBody?.contactTestBitMask = 0xFFFF

                addChild(tileNode)
            }
        }
    }
}
