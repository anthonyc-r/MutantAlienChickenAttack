//
//  CoupTransitionScene.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SpriteKit
import Combine
import SwiftUI

class FarmerScene: SKScene, SKPhysicsContactDelegate, ChickenSpawning {
    private var viewModel: ViewModel!
    private var fireAction: SKAction!
    private var farmer: WalkingSprite!
    private var player: PlayerSprite!
    
    private var observations = [AnyCancellable]()
    
    private var activeKeys = Set<KeyCode>()
    private var activeBullets = [SKNode]()
    private var currentAction: SKAction?
    private var lastAction: SKAction?
    private var lastActionType: ActionType = .start
    
    private var health = 4
    
    private enum ActionType {
        case start
        case seek
        case shoot
    }
    private enum ProjType {
        case bullet
        case egg
        var imageName: String {
            switch self {
            case .bullet: return "Bullet"
            case .egg: return "Egg"
            }
        }
    }
    
    
    
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
        scene.farmer = scene.childNode(withName: "shooting_farmer") as? WalkingSprite
        scene.farmer.imageBase = "Farmer_Walk"
        scene.farmer.frameCount = 7
        scene.physicsWorld.contactDelegate = scene
        scene.fireAction = .group([
            // A bump up and down
            .sequence([.moveBy(x: 0, y: 20, duration: 0.2), .moveBy(x: 0, y: -20, duration: 0.2)]),
            .sequence([.wait(forDuration: 0.1), .run(.sequence([
                .unhide(),
                .wait(forDuration: 0.1),
                .hide()
            ]), onChildWithName: "flash")])
        ])
        return scene
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        updatePlayer()
        updateFarmer()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        let nodes = [nodeA, nodeB]
        
        
        let _ = nodes.first { $0.userData?["type"] as? String == ProjType.bullet.imageName }
        let enemy = nodes.first { $0.userData?["type"] as? String == "enemy" }
        let egg = nodes.first { $0.userData?["type"] as? String == ProjType.egg.imageName }
                
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
    
        if health < 1 {
            print("Game over")
            
            view?.presentScene(GameOverScene.newGameScene(viewModel), transition: SKTransition.crossFade(withDuration: 1))
        }
        
        if let egg = egg {
            hatchEgg(egg)
        }
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
                tileNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                tileNode.physicsBody?.contactTestBitMask = PhysicsCategory.player

                addChild(tileNode)
            }
        }
    }
    private func updateFarmer() {
        guard currentAction == nil else {
            return
        }
        let currentAction: SKAction
        switch lastActionType {
        case .start, .shoot:
            let minX = childNode(withName: "min_x")!.position.x
            let maxX = childNode(withName: "max_x")!.position.x
            let x = ((CGFloat(arc4random()) / CGFloat(UInt32.max)) * (maxX - minX)) + minX
            let dx = x - farmer.position.x
            currentAction = SKAction.group([
                .run { [weak self] in self?.farmer.setDirection(CGVector(dx: dx, dy: 0), speed: abs(dx / 2))},
                .moveTo(x: x, duration: 2)
            ])
            self.lastActionType = .seek
        case .seek:
            let fireEggs = Bool.random() && Bool.random()
            currentAction = SKAction.group([
                .animate(with: [SKTexture(imageNamed: "Farmer_Shooting")], timePerFrame: 1),
                fireAction,
                .run { [weak self] in self?.createProjectiles(type: fireEggs ? .egg : .bullet) }
            ])
            self.lastActionType = .shoot
        }
        self.currentAction = currentAction
        farmer.run(currentAction, completion: {
            self.lastAction = currentAction
            self.currentAction = nil
        })
    }
    
    private func createProjectiles(type: ProjType = .bullet) {
        func projectile() -> SKNode {
            let node = SKSpriteNode(imageNamed: type.imageName)
            node.userData = ["type": type.imageName, "enemy": true]
            node.size = Dimension.tileSize
            node.position = farmer.position
            node.physicsBody = physicsBody()
            node.physicsBody?.isDynamic = true
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.categoryBitMask = PhysicsCategory.enemyProjectile
            node.physicsBody?.collisionBitMask = PhysicsCategory.player
            node.physicsBody?.contactTestBitMask = PhysicsCategory.player
            return node
        }
        
        let node1 = projectile()
        let node2 = projectile()
        let node3 = projectile()
        
        node1.physicsBody?.velocity = CGVector(dx: -400, dy: -400)
        node1.zRotation = .pi * 0.75
        node2.physicsBody?.velocity = CGVector(dx: 0, dy: -400)
        node3.physicsBody?.velocity = CGVector(dx: 400, dy: -400)
        node3.zRotation = .pi * 0.25

        addChild(node1)
        addChild(node2)
        addChild(node3)
    }
    
    private func hatchEgg(_ egg: SKNode) {
        let position = egg.position
        egg.removeFromParent()
        _ = spawnEnemy(position, player)
        _ = spawnEnemy(position, player)
        _ = spawnEnemy(position, player)
    }
    
    
    private func physicsBody() -> SKPhysicsBody {
        return SKPhysicsBody(rectangleOf: Dimension.tileSize.applying(.identity.scaledBy(x: 0.8, y: 0.8)))
    }
}
