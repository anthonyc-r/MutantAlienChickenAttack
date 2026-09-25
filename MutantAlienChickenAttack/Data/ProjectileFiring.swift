//
//  ProjectileFiring.swift
//  MutantAlienChickenAttack
//
//  Created by Anthony Cohn-Richardby on 25/09/2026.
//
import SpriteKit

protocol ProjectileFiring where Self: SKScene {
    
}

extension ProjectileFiring {
    func fireProjectile(from source: SKNode, vector: CGVector, _ enemy: Bool = false) {
        let node = SKSpriteNode(imageNamed: "Egg")
        node.userData = ["type": "Egg", "enemy": enemy]
        node.size = Dimension.tileSize
        node.position = source.position
        node.physicsBody = physicsBody()
        node.setScale(0.5)
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

        node.physicsBody?.velocity = CGVector(dx: 500 * vector.dx, dy: 500 * vector.dy)

        addChild(node)
    }
    
    private func physicsBody() -> SKPhysicsBody {
        return SKPhysicsBody(rectangleOf: Dimension.tileSize.applying(.identity.scaledBy(x: 0.8, y: 0.8)))
    }
}
