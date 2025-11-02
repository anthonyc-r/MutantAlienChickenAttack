//
//  ContentView.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 02/11/2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var direction: CGSize = .zero
    @State var actionPressed: Bool = false
    
    var body: some View {
        ZStack {
            SpriteView(scene: CoupScene.newGameScene())
            VStack {
                Spacer()
                HStack {
                    Joystick(direction: $direction)
                    Spacer()
                    ActionButton(isPressed: $actionPressed)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
