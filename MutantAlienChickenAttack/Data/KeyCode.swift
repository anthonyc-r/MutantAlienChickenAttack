//
//  KeyCode.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SwiftUI

enum KeyCode: UInt16 {
    case space = 49
    case leftArrow = 123
    case rightArrow = 124
    case downArrow = 125
    case upArrow = 126
    
    init?(_ keyEquivalent: KeyEquivalent?) {
        switch keyEquivalent {
        case KeyEquivalent.downArrow:
            self = .downArrow
        case KeyEquivalent.upArrow:
            self = .upArrow
        case KeyEquivalent.leftArrow:
            self = .leftArrow
        case KeyEquivalent.rightArrow:
            self = .rightArrow
        case KeyEquivalent.space:
            self = .space
        default:
            return nil
        }
    }
}
