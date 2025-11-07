//
//  Textures.swift
//  MutantAlientChickenAttack
//
//  Created by Anthony Cohn-Richardby on 14/06/2025.
//
import SpriteKit

class Textures {
    static let instance = Textures()
    
    public var tileSet: SKTileSet!
    public var atlas: SKTextureAtlas!
    
    
    private init() {
        atlas = SKTextureAtlas(named: "Sprites")
        tileSet = SKTileSet(tileGroups: [
            chicken,
            grass
        ], tileSetType: .grid)
        
    }
    
    var chicken: SKTileGroup {
        return SKTileGroup(tileDefinition: SKTileDefinition(texture: atlas.textureNamed("Chicken"), size: CGSize(width: 128, height: 128)))
    }
    
    var grass: SKTileGroup {
        return SKTileGroup(tileDefinition: SKTileDefinition(texture: atlas.textureNamed("Grass"), size: CGSize(width: 128, height: 128)))
    }
}
