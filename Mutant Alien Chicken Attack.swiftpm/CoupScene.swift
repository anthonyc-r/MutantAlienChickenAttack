import SpriteKit

class CoupScene: SKScene {
    private var backgroundMap: SKTileMapNode!
    private var mainCamera: SKCameraNode!
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        mainCamera = SKCameraNode()
        mainCamera.xScale = 64 * 16
        mainCamera.yScale = 64 * 8
        camera = mainCamera
        backgroundMap = createBackground()
        addChild(backgroundMap)
    }
    
    private func createBackground() -> SKTileMapNode {        
        let grassDef1 = SKTileDefinition(texture: SKTexture(imageNamed: "Grass"), size: CGSize(width: 64, height: 64))
        let grassDef2 = SKTileDefinition(texture: SKTexture(imageNamed: "Grass"), size: CGSize(width: 64, height: 64))
        grassDef2.rotation = .rotation90
        let grassDef3 = SKTileDefinition(texture: SKTexture(imageNamed: "Grass"), size: CGSize(width: 64, height: 64))
        grassDef3.rotation = .rotation180
        
        let grassTile = SKTileGroup(rules: [
            .init(adjacency: .adjacencyAll, tileDefinitions: [
                grassDef1,
                grassDef2,
                grassDef3
            ]),
        ])
        let tileSet = SKTileSet(tileGroups: [
            grassTile
        ])
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: 16, rows: 8, tileSize: CGSize(width: 64, height: 64), fillWith: grassTile)
        tileMap.position = .zero
        return tileMap
    }
}
