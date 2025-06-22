//
//  KeyCode.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import UIKit

enum KeyCode: UInt16 {
    case space = 49
    case leftArrow = 123
    case rightArrow = 124
    case downArrow = 125
    case upArrow = 126
    
    init?(uiKeyCode: UIKeyboardHIDUsage) {
        switch uiKeyCode {
        case .keyboardSpacebar:
            self = .space
        case .keyboardLeftArrow:
            self = .leftArrow
        case .keyboardDownArrow:
            self = .downArrow
        case .keyboardRightArrow:
            self = .rightArrow
        case .keyboardUpArrow:
            self = .upArrow
        default:
            return nil
        }
    }
}
