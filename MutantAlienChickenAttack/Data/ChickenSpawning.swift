//
//  ChickenSpawning.swift
//  MutantAlienChickenAttack
//
//  Created by Anthony Cohn-Richardby on 25/09/2026.
//
import SpriteKit

protocol ChickenSpawning where Self: SKScene {
    
    
}

extension ChickenSpawning {
    func spawnEnemy(_ location: CGPoint, _ player: SKNode) -> SKNode {
        let node = WalkingSprite()
        node.frameCount = 14
        node.imageBase = "Chicken_Walk"
        node.userData = ["type": "enemy", "hp": 3]
        node.size = Dimension.tileSize
        node.position = .zero
        node.physicsBody = physicsBody()
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = 0xFFFF ^ PhysicsCategory.enemyProjectile
        node.physicsBody?.contactTestBitMask = 0xFFFF ^ PhysicsCategory.enemyProjectile
        addChild(node)
        node.run(.repeatForever(.group([
            .sequence([
                .wait(forDuration: 1.0),
                .run { [weak self] in self?.updateEnemy(player, node) }
            ])
        ])))
        return node
    }
    
    private func physicsBody() -> SKPhysicsBody {
        return SKPhysicsBody(rectangleOf: Dimension.tileSize.applying(.identity.scaledBy(x: 0.8, y: 0.8)))
    }
    
    private func updateEnemy(_ player: SKNode, _ enemy: SKNode) {
        let dx = player.position.x - enemy.position.x
        let dy = player.position.y - enemy.position.y
        let vec = CGVector(dx: abs(dx) / dx, dy: abs(dy) / dy)
        (enemy as? WalkingSprite)?.setDirection(vec)
        if let lastWonder = enemy.userData?["lastWonder"] as? Date, lastWonder.timeIntervalSinceNow > -2 {
            
        } else {
            enemy.userData?["lastWonder"] = Date()
            let dir = Direction.allCases.randomElement()!.vector
            enemy.physicsBody?.velocity = CGVector(dx: 100 * dir.dx, dy: 100 * dir.dy)
        }
        
        if let lastFire = enemy.userData?["nextFire"] as? Date, lastFire.timeIntervalSinceNow > 0 {
            
        } else {
            enemy.userData?["nextFire"] = Date(timeIntervalSinceNow: TimeInterval(3 + (0..<3).randomElement()!))
            (self as? ProjectileFiring)?.fireProjectile(from: enemy, vector: vec, true)
        }
    }
}
