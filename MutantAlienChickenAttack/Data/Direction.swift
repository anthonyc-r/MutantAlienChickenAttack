//
//  Direction.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//

import CoreGraphics

enum Direction: Int, CaseIterable {
    case north
    case north_east
    case east
    case south_east
    case south
    case south_west
    case west
    case north_west
    
    init?(vector: CGVector) {
        if vector.dx > 0 {
            self = .east
        } else if vector.dx < 0 {
            self = .west
        } else if vector.dy > 0 {
            self = .north
        } else if vector.dy < 0 {
            self = .south
        } else {
            self = .north
        }
    }
    
    init?(fromKeys keys: Set<KeyCode>) {
        switch (keys.contains(.upArrow), keys.contains(.downArrow), keys.contains(.leftArrow), keys.contains(.rightArrow)) {
        case (true, false, false, false):
            self = .north
        case (true, false, false, true):
            self = .north_east
        case (false, true, false, false):
            self = .south
        case (false, false, true, false):
            self = .west
        case (false, false, false, true):
            self = .east
        case (false, true, false, true):
            self = .south_east
        case (false, true, true, false):
            self = .south_west
        case (true, false, true, false):
            self = .north_west
        default:
            return nil
        }
    }
    
    var vector: CGVector {
        switch self {
        case .north:
            return CGVector(dx: 0, dy: 1)
        case .north_east:
            return CGVector(dx: 1, dy: 1)
        case .east:
            return CGVector(dx: 1, dy: 0)
        case .south_east:
            return CGVector(dx: 1, dy: -1)
        case .south:
            return CGVector(dx: 0, dy: -1)
        case .south_west:
            return CGVector(dx: -1, dy: -1)
        case .west:
            return CGVector(dx: -1, dy: 0)
        case .north_west:
            return CGVector(dx: -1, dy: 1)
        }
    }
}
