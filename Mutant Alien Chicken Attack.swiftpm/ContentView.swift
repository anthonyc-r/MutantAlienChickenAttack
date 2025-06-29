import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var direction: CGSize = .zero
    @State var actionPressed: Bool = false
    
    private let currentScene = CoupScene()
    
    var body: some View {
        ZStack {
            SpriteView(scene: currentScene)
            VStack {
                Spacer()
                HStack {
                    Joystick(direction: $direction)
                    Spacer()
                    ActionButton(isPressed: $actionPressed)
                }
            }.onChange(of: direction) { oldValue, newValue in
                currentScene.setDirection(newValue)
            }.onChange(of: actionPressed) { oldValue, newValue in
                currentScene.setActionPressed(newValue)
            }
        }
    }
}
