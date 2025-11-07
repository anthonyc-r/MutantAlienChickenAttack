//
//  Extensions.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 02/11/2025.
//

import SpriteKit

extension SKNode {
    func descendant(withName name: String) -> SKNode? {
        // Breadth-first search for this sprite
        var level = 0
        var map: [[SKNode]]
        
        map = [[self]]
        
        while !map[level].isEmpty {
            for item in map[level] {
                if item.name == name {
                    return item
                }
                if map.count < level + 2 {
                    map.append([])
                }
                map[level + 1].append(contentsOf: item.children)
            }
            level += 1
        }
        return nil
    }
}
