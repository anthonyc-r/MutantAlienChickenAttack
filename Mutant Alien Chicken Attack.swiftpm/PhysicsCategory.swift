//
//  PhysicsCategory.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//

enum PhysicsCategory {
    static let building: UInt32 = 0b0001
    static let player: UInt32 = 0b0010
    static let playerProjectile: UInt32 = 0b0100
    static let enemy: UInt32 = 0b1000
    static let enemyProjectile: UInt32 = 0b10000
}
