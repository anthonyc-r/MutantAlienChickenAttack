import SpriteKit

class CoupScene: SKScene, SKPhysicsContactDelegate {
    private let tileSize = CGSize(width: 64, height: 64)
    private let mapSize = (width: 16, height: 8)
    private let coupSize = (width: 14, height: 6)
    
    private var backgroundMap: SKTileMapNode!
    private var mainCamera: SKCameraNode!
    private var fences: [SKNode]!
    private var player: SKNode!
    private var healthBar: SKLabelNode!
    
    private var activeKeys = Set<KeyCode>()
    private var lastFire = Date()
    private var stage = 0
    private var health = 5 {
        didSet {
            healthBar.text = "Lives: " + String(repeating: "🐔", count: max(0, health))
        }
    }
    private var gameStart = Date() 

    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        mainCamera = SKCameraNode()
        mainCamera.xScale = tileSize.width * CGFloat(mapSize.width)
        mainCamera.yScale = tileSize.height * CGFloat(mapSize.height)
        camera = mainCamera
        backgroundMap = createBackground()
        fences = createFences()
        player = createPlayer()
        healthBar = createHealthBar()
        
        addChild(backgroundMap)
        fences.forEach(addChild)
        addChild(player)
        addChild(healthBar)
        
        physicsWorld.contactDelegate = self
    }
    
    private func createHealthBar() -> SKLabelNode {
        let node = SKLabelNode()
        return node
    }
    
    private func createFences() -> [SKNode] {
        var nodes = [SKNode]()
        let y1 = (mapSize.height - coupSize.height) / 2
        let y2 = mapSize.height - y1
        let x1 = (mapSize.width - coupSize.width) / 2
        let x2 = mapSize.width - x1
        for x in x1...x2 {
            for y in [y1, y2] {
                nodes.append(createFence(withImageNamed: "Fence Horizontal", x: CGFloat(x), y: CGFloat(y)))  
            }
        }
        for x in [x1, x2] {
            for y in y1...y2 {
                nodes.append(createFence(withImageNamed: "Fence Vertical", x: CGFloat(x), y: CGFloat(y)))
            }
        }
        return nodes
    }
    
    private func createPlayer() -> SKNode {
        let player = SKSpriteNode(imageNamed: "Chicken")
        player.size = tileSize
        player.position = CGPoint(x: 8, y: 4)
        player.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.building
        player.physicsBody?.contactTestBitMask = PhysicsCategory.building
        return player
    }
    
    private func createBackground() -> SKTileMapNode {        
        let grassDef1 = SKTileDefinition(texture: SKTexture(imageNamed: "Grass"), size: tileSize)
        let grassDef2 = SKTileDefinition(texture: SKTexture(imageNamed: "Grass"), size: tileSize)
        grassDef2.rotation = .rotation90
        let grassDef3 = SKTileDefinition(texture: SKTexture(imageNamed: "Grass"), size: tileSize)
        grassDef3.rotation = .rotation180
        
        let grassTile = SKTileGroup(rules: [
            .init(adjacency: .adjacencyAll, tileDefinitions: [
                grassDef1,
                grassDef2,
                grassDef3
            ]),
        ])
        let tileSet = SKTileSet(tileGroups: [
            grassTile
        ])
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: mapSize.width, rows: mapSize.height, tileSize: tileSize, fillWith: grassTile)
        tileMap.position = .zero
        return tileMap
    }
    
    
    func createFence(withImageNamed name: String, x: CGFloat, y: CGFloat) -> SKNode {
        let fenceNode = SKSpriteNode(imageNamed: name)
        fenceNode.size = tileSize
        fenceNode.position = CGPoint(
            x: x * tileSize.width,
            y: y * tileSize.height
        )
        fenceNode.physicsBody = SKPhysicsBody(rectangleOf: fenceNode.size)
        fenceNode.physicsBody?.isDynamic = false
        fenceNode.physicsBody?.categoryBitMask = PhysicsCategory.building
        fenceNode.physicsBody?.collisionBitMask = 0xFFFF
        fenceNode.physicsBody?.contactTestBitMask = 0xFFFF
        return fenceNode
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
                
                view?.presentScene(GameOverScene(), transition: SKTransition.crossFade(withDuration: 1))
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
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let codeVal = press.key?.keyCode {
                if let keyCode = KeyCode(uiKeyCode: codeVal) {
                    activeKeys.insert(keyCode)                    
                }
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let codeVal = press.key?.keyCode {
                if let keyCode = KeyCode(uiKeyCode: codeVal) {
                    activeKeys.remove(keyCode)                    
                }
            }
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
        node.size = tileSize
        node.position = source.position
        node.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
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
        node.size = tileSize
        node.position = .zero
        node.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
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
