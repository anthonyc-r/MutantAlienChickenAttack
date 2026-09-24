//
//  PlayerSprite.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 07/11/2025.
//

import SpriteKit

class PlayerSprite: SKSpriteNode {
    private(set) var camera: SKCameraNode?
    private var currentDirection: Direction?
    
    convenience init(_ healthContainer: SKNode?) {
        self.init(imageNamed: "Chicken_Walk_Left_0001")
        
        if let healthContainer = healthContainer {
            let camera = SKCameraNode()
            addChild(camera)
            healthContainer.removeFromParent()
            camera.addChild(healthContainer)
            self.camera = camera
        }
        
        userData = ["type": "player", "hp": 3]
        size = Dimension.tileSize
        position = .zero
        
        physicsBody = SKPhysicsBody(rectangleOf: Dimension.tileSize.applying(.identity.scaledBy(x: 0.1, y: 0.8)))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.building
        physicsBody?.contactTestBitMask = PhysicsCategory.building
        
        
    }
    
    
    func setDirection(_ vector: CGVector) {
        physicsBody?.velocity = CGVector(dx: 200 * vector.dx, dy: 200 * vector.dy)

        let direction = Direction(vector: vector)
        guard direction != currentDirection else { return }
        currentDirection = direction
        switch direction {
        case .north:
            setSprite(basename: "Chicken_Walk_Up")
        case .east:
            setSprite(basename: "Chicken_Walk_Right")
        case .west:
            setSprite(basename: "Chicken_Walk_Left")
        case .south:
            setSprite(basename: "Chicken_Walk_Down")
        default:
            break
        }
    }
    
    private func setSprite(basename: String) {
        run(SKAction.repeatForever(SKAction.animate(with: (0...13).map { i in
            return getTexture(name: "\(basename)_\(String(format: "%04d", i))")
        }, timePerFrame: 0.2)))
    }
    
    private func getTexture(name: String) -> SKTexture {
        let tex = SKTexture(imageNamed: name)
        tex.filteringMode = .nearest
        return tex
    }
}
