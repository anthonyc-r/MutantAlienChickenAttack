//
//  GameScene.swift
//  MutantAlientChickenAttack Shared
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//

import SpriteKit
import Combine
import SwiftUI
import AVFoundation

class CoupScene: SKScene, SKPhysicsContactDelegate {
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var viewModel: ViewModel!
    private var activeKeys = Set<KeyCode>()
    private var lastFire = Date()
    private var stage = 0
    private var health = 5 {
        didSet {
            healthBar.text = "Lives: " + String(repeating: "🐔", count: max(0, health))
        }
    }
    private var gameStart = Date()
    private var observations = [AnyCancellable]()
    private var player: PlayerSprite!
    
    
    deinit {
        backgroundMusicPlayer?.stop()
    }
    
    class func newGameScene(_ viewModel: ViewModel) -> CoupScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "CoupScene") as? CoupScene else {
            print("Failed to load CoupScene.sks")
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
    
    func setUpScene() {
        physicsWorld.contactDelegate = self
        addCollisionBodies(from: buildingMap)
        playBackgroundMusic()
        player = PlayerSprite(healthContianer)
        camera = player.camera
        addChild(player)
    }
    
    func addCollisionBodies(from tileMap: SKTileMapNode) {
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
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        let nodes = [nodeA, nodeB]
        
        
        let egg = nodes.first { $0.userData?["type"] as? String == "egg" }
        let player = nodes.first { $0 === self.player }
        let enemy = nodes.first { $0.userData?["type"] as? String == "enemy" }
                
        if let enemy = enemy, let hp = enemy.userData?["hp"] as? Int, egg?.userData?["enemy"] as? Bool == false {
            if hp <= 1 {
                enemy.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 1.0),
                    SKAction.removeFromParent()
                ]))
            } else {
                enemy.userData?["hp"] = hp - 1
            }
        }
        
        if let _ = player, gameStart.addingTimeInterval(5) < Date() {
            health -= 1
            if health < 1 {
                print("Game over")
                
                view?.presentScene(GameOverScene.newGameScene(viewModel), transition: SKTransition.crossFade(withDuration: 1))
            }
        }
        
        if let egg = egg {
            egg.run(SKAction.sequence([
                SKAction.setTexture(SKTexture(imageNamed: "Egg Broken")),
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updatePlayer()
        updateEnemies()
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
    
    private func playBackgroundMusic() {
        let url = Bundle.main.url(forResource: "Background", withExtension: "m4a")!
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: url)
        backgroundMusicPlayer!.numberOfLoops = -1 // loop forever
        backgroundMusicPlayer!.volume = 0.5
        backgroundMusicPlayer!.play()
    }
    
    private var tileMap: SKTileMapNode {
        return childNode(withName: "tile_map") as! SKTileMapNode
    }
    
    private var buildingMap: SKTileMapNode {
        return childNode(withName: "building_map") as! SKTileMapNode
    }
    
    private var healthBar: SKLabelNode {
        return descendant(withName: "health_label") as! SKLabelNode
    }
    private var healthContianer: SKNode {
        return childNode(withName: "health_background")!
    }
    
    private func updatePlayer() {
        if let vector = Direction(fromKeys: activeKeys)?.vector {
            player.setDirection(vector)
            if activeKeys.contains(.space) && lastFire.timeIntervalSinceNow < -0.5 {
                fireProjectile(from: player, vector: vector)
                lastFire = Date()
            }
        } else {
            player.physicsBody?.velocity = .zero
        }
    }
    
    private func updateEnemies() {
        var enemies = children.filter {
            $0.userData?["type"] as? String == "enemy"
        }
        
        if enemies.count < 4 {
            enemies.append(spawnEnemy())
        }
        
        enemies.forEach { enemy in
            let dx = player.position.x - enemy.position.x
            let dy = player.position.y - enemy.position.y
            let vec = CGVector(dx: abs(dx) / dx, dy: abs(dy) / dy)
            
            
            if let lastWonder = enemy.userData?["lastWonder"] as? Date, lastWonder.timeIntervalSinceNow > -2 {
                
            } else {
                enemy.userData?["lastWonder"] = Date()
                let dir = Direction.allCases.randomElement()!.vector
                enemy.physicsBody?.velocity = CGVector(dx: 100 * dir.dx, dy: 100 * dir.dy)
                if dir.dx > 0 {
                    enemy.xScale = -1
                } else if dir.dx < 0 {
                    enemy.xScale = 1
                }
            }
            
            if let lastFire = enemy.userData?["nextFire"] as? Date, lastFire.timeIntervalSinceNow > 0 {
                
            } else {
                enemy.userData?["nextFire"] = Date(timeIntervalSinceNow: TimeInterval(3 + (0..<3).randomElement()!))
                fireProjectile(from: enemy, vector: vec, true)
            }
        }
    }
    
    private func fireProjectile(from source: SKNode, vector: CGVector, _ enemy: Bool = false) {
        let node = SKSpriteNode(imageNamed: "Egg")
        node.userData = ["type": "egg", "enemy": enemy]
        node.size = Dimension.tileSize
        node.position = source.position
        node.physicsBody = SKPhysicsBody(rectangleOf: Dimension.tileSize)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        if enemy {
            node.physicsBody?.categoryBitMask = PhysicsCategory.enemyProjectile
            node.physicsBody?.collisionBitMask = 0xFFFF ^ PhysicsCategory.enemy
            node.physicsBody?.contactTestBitMask = 0xFFFF ^ PhysicsCategory.enemy
        } else {
            node.physicsBody?.categoryBitMask = PhysicsCategory.playerProjectile
            node.physicsBody?.collisionBitMask = 0xFFFF ^ PhysicsCategory.player
            node.physicsBody?.contactTestBitMask = 0xFFFF ^ PhysicsCategory.player
        }

        node.physicsBody?.velocity = CGVector(dx: 400 * vector.dx, dy: 400 * vector.dy)

        addChild(node)
    }
    
    private func spawnEnemy() -> SKNode {
        let node = SKSpriteNode(imageNamed: "Chicken2")
        node.userData = ["type": "enemy", "hp": 3]
        node.size = Dimension.tileSize
        node.position = .zero
        node.physicsBody = SKPhysicsBody(rectangleOf: Dimension.tileSize)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = 0xFFFF ^ PhysicsCategory.enemyProjectile
        node.physicsBody?.contactTestBitMask = 0xFFFF ^ PhysicsCategory.enemyProjectile

        addChild(node)
        return node
    }
}
