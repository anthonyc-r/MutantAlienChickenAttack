//
//  DirectionalSprite.swift
//  MutantAlienChickenAttack
//
//  Created by Anthony Cohn-Richardby on 25/09/2026.
//
import SpriteKit

class WalkingSprite: SKSpriteNode {
    var imageBase = ""
    var frameCount = 14
    private var currentDirection: Direction?
    
    convenience init(_ healthContainer: SKNode?) {
        self.init(imageNamed: "")
        self.setSprite(basename: "\(imageBase)_Left_0000")
    }
    
    
    func setDirection(_ vector: CGVector, speed: CGFloat? = nil) {
        physicsBody?.velocity = CGVector(dx: 200 * vector.dx, dy: 200 * vector.dy)

        let direction = Direction(vector: vector)
        guard direction != currentDirection else { return }
        currentDirection = direction
        switch direction {
        case .north:
            setSprite(basename: "\(imageBase)_Up", speed: speed)
        case .east:
            setSprite(basename: "\(imageBase)_Right", speed: speed)
        case .west:
            setSprite(basename: "\(imageBase)_Left", speed: speed)
        case .south:
            setSprite(basename: "\(imageBase)_Down", speed: speed)
        default:
            break
        }
    }
    
    private func setSprite(basename: String, speed: CGFloat? = nil) {
        var actualSpeed = speed
        if let speed = speed {
            actualSpeed = speed / 200
        }
        
        run(SKAction.repeatForever(SKAction.animate(with: (0..<frameCount).map { i in
            return getTexture(name: "\(basename)_\(String(format: "%04d", i))")
        }, timePerFrame: actualSpeed ?? 0.2)))
    }
    
    private func getTexture(name: String) -> SKTexture {
        let tex = SKTexture(imageNamed: name)
        tex.filteringMode = .nearest
        return tex
    }
}
