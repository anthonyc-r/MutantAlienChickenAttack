//
//  GameScene.swift
//  MutantAlientChickenAttack Shared
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//

import SpriteKit

class CoupScene: SKScene, SKPhysicsContactDelegate {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    
    private var activeKeys = Set<KeyCode>()
    private var lastFire = Date()
    private var stage = 0
    private var health = 5 {
        didSet {
            healthBar.text = "Lives: " + String(repeating: "🐔", count: max(0, health))
        }
    }
    private var gameStart = Date()

    
    class func newGameScene() -> CoupScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "CoupScene") as? CoupScene else {
            print("Failed to load CoupScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        
        return scene
    }
    
    func setUpScene() {
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        children.compactMap { $0 as? SKTileMapNode }.forEach {
            $0.blendMode = .alpha
        }
        physicsWorld.contactDelegate = self
        addCollisionBodies(from: buildingMap)
        player.physicsBody = SKPhysicsBody(rectangleOf: Dimension.tileSize)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.building
        player.physicsBody?.contactTestBitMask = PhysicsCategory.building
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

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
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
        
        if let player = player, gameStart.addingTimeInterval(5) < Date() {
            health -= 1
            if health < 1 {
                print("Game over")
                
                view?.presentScene(GameOverScene.newGameScene(), transition: SKTransition.crossFade(withDuration: 1))
            }
        }
        
        if let egg = egg {
            egg.run(SKAction.sequence([
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
    
    
    private var tileMap: SKTileMapNode {
        return childNode(withName: "tile_map") as! SKTileMapNode
    }
    
    private var player: SKNode {
        return childNode(withName: "player")!
    }
    
    private var buildingMap: SKTileMapNode {
        return childNode(withName: "building_map") as! SKTileMapNode
    }
    
    private var healthBar: SKLabelNode {
        return self.childNode(withName: "health_background")!.childNode(withName: "health_label") as! SKLabelNode
    }
    
    override func keyUp(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: event.keyCode) {
            activeKeys.remove(keyCode)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: event.keyCode) {
            activeKeys.insert(keyCode)
        }
    }
    
    private func updatePlayer() {
        if let vector = Direction(fromKeys: activeKeys)?.vector {
            player.physicsBody?.velocity = CGVector(dx: 200 * vector.dx, dy: 200 * vector.dy)
            if vector.dx > 0 {
                player.xScale = -1
            } else if vector.dx < 0 {
                player.xScale = 1
            }
            
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

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension CoupScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

