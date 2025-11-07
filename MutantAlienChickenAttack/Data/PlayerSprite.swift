//
//  PlayerSprite.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 07/11/2025.
//

import SpriteKit

class PlayerSprite: SKSpriteNode {
    private(set) var camera: SKCameraNode!
    private var currentDirection: Direction?
    
    convenience init(_ healthContainer: SKNode) {
        self.init(imageNamed: "chicken_left_1")
        
        let camera = SKCameraNode()
        addChild(camera)
        healthContainer.removeFromParent()
        camera.addChild(healthContainer)
        self.camera = camera
        
        userData = ["type": "player", "hp": 3]
        size = Dimension.tileSize
        position = .zero
        
        physicsBody = SKPhysicsBody(rectangleOf: Dimension.tileSize)
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
            setSprite(basename: "chicken_up")
        case .east:
            setSprite(basename: "chicken_right")
        case .west:
            setSprite(basename: "chicken_left")
        case .south:
            setSprite(basename: "chicken_down")
        default:
            break
        }
    }
    
    private func setSprite(basename: String) {
        run(SKAction.repeatForever(SKAction.animate(with: [
            getTexture(name: "\(basename)_1"),
            getTexture(name: "\(basename)_2")
        ], timePerFrame: 0.2)))
    }
    
    private func getTexture(name: String) -> SKTexture {
        let tex = SKTexture(imageNamed: name)
        tex.filteringMode = .nearest
        return tex
    }
}
